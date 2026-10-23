#!/usr/bin/env python3
"""Compile the exact Swift candidate with Xcode 16.4 and the published .15 C binary."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import plistlib
import re
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "Compatibility/Consumer.xcodeproj"
EXPECTED_DEVELOPER = "/Applications/Xcode_16.4.app/Contents/Developer"
ARCHITECTURES = (("iphoneos", "arm64"), ("iphonesimulator", "arm64"), ("iphonesimulator", "x86_64"))


def sha(data):
    return hashlib.sha256(data).hexdigest()


def snapshot():
    raw = subprocess.check_output(["git", "ls-files", "-z", "--cached"], cwd=ROOT)
    names = sorted({os.fsdecode(name) for name in raw.split(b"\0") if name})
    files = {}
    for name in names:
        path = ROOT / name
        if path.is_symlink() or not path.is_file():
            raise RuntimeError("Missing or symlinked compatibility source: " + name)
        files[name] = sha(path.read_bytes())
    return {"commit": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
            "files_sha256": files}


def build_command(output, sdk, arch):
    return ["xcodebuild", "-project", str(PROJECT), "-scheme", "Consumer", "-configuration", "Release",
            "-sdk", sdk, "-destination", "generic/platform=iOS" if sdk == "iphoneos" else "generic/platform=iOS Simulator",
            "-derivedDataPath", str(output / f"derived-{sdk}-{arch}"),
            "-packageCachePath", str(output / "package-cache"),
            "-clonedSourcePackagesDirPath", str(output / "source-packages"),
            "-disablePackageRepositoryCache", f"ARCHS={arch}", "ONLY_ACTIVE_ARCH=NO", "CODE_SIGNING_ALLOWED=NO",
            "SWIFT_VERSION=5.0", "SWIFT_OPTIMIZATION_LEVEL=-O", "SWIFT_COMPILATION_MODE=wholemodule", "build"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--plan", action="store_true")
    args = parser.parse_args()
    output = args.output.resolve()
    if output == ROOT or ROOT in output.parents:
        parser.error("Keep generated compatibility evidence outside the candidate source checkout")
    commands = [build_command(output, sdk, arch) for sdk, arch in ARCHITECTURES]
    if args.plan:
        print(json.dumps({"scope": "compile_compatibility_only", "developer_dir": EXPECTED_DEVELOPER,
                          "runner_architecture": "arm64", "commands": commands}, indent=2))
        return 0
    if output.exists():
        parser.error("Compatibility output must be a new directory")
    evidence = output / "evidence"
    logs = evidence / "logs"
    logs.mkdir(parents=True)
    context = json.loads((ROOT / "Compatibility/context.json").read_text())
    report = {"schema": 1, "scope": context["scope"], "success": False, "context": context,
              "architectures": [], "commands": [], "runtime_verified": False, "hardware_verified": False,
              "final_preview16_artifact_verified": False, "native_binary_version": "0.3.0-preview.15"}
    sequence = 0
    before = None

    def run(command, timeout=900):
        nonlocal sequence
        sequence += 1
        name = f"{sequence:02d}.log"
        log = logs / name
        print("+ " + " ".join(map(str, command)), flush=True)
        with log.open("w") as stream:
            result = subprocess.run(list(map(str, command)), cwd=ROOT, text=True,
                                    stdout=stream, stderr=subprocess.STDOUT, timeout=timeout)
        report["commands"].append({"command": list(map(str, command)), "log": "logs/" + name,
                                   "exit_code": result.returncode, "log_sha256": sha(log.read_bytes())})
        if result.returncode:
            print(log.read_text()[-15000:])
            raise RuntimeError("Compatibility command failed: " + str(command[0]))
        return log.read_text()

    started = time.monotonic()
    try:
        before = snapshot()
        report["source_before"] = before
        if platform.machine() != "arm64" or os.environ.get("DEVELOPER_DIR") != EXPECTED_DEVELOPER:
            raise RuntimeError("Require arm64 runner and the exact Xcode 16.4 DEVELOPER_DIR")
        report["xcode_version"] = run(["xcodebuild", "-version"])
        if not report["xcode_version"].startswith("Xcode 16.4\n"):
            raise RuntimeError("Compatibility check requires Xcode 16.4")
        report["swift_version"] = run(["xcrun", "swift", "--version"])
        package = (ROOT / "Package.swift").read_text()
        if context["native_binary_url"] not in package or context["native_binary_sha256"] not in package:
            raise RuntimeError("Compile preflight must use the exact published .15 native binary")
        if sha((ROOT / context["modified_source"]).read_bytes()) != context["modified_source_sha256"]:
            raise RuntimeError("The reviewed Swift initializer fix differs")
        for (sdk, arch), command in zip(ARCHITECTURES, commands):
            build_log = run(command)
            sdk_commands = [line for line in build_log.splitlines() if "-module-name XLPrinterSDK" in line]
            if not any("-whole-module-optimization" in line
                       and re.search(r"(?:^|\s)-swift-version 5(?:\s|$)", line)
                       and re.search(r"(?:^|\s)-O(?:\s|$)", line) for line in sdk_commands):
                raise RuntimeError("SDK compiler invocation must use Swift 5, -O and whole-module optimization")
            app = output / f"derived-{sdk}-{arch}/Build/Products/Release-{sdk}/Consumer.app"
            native = app / "Frameworks/CPrinterSDK.framework"
            info = plistlib.loads((native / "Info.plist").read_bytes())
            if info.get("CFBundleIdentifier") != "com.netumscan.printersdk.core":
                raise RuntimeError("Unexpected native framework identity")
            run(["xcrun", "lipo", "-verify_arch", arch, app / "Consumer"])
            run(["xcrun", "lipo", "-verify_arch", arch, native / "CPrinterSDK"])
            report["architectures"].append({"sdk": sdk, "architecture": arch, "release_build_passed": True,
                                             "swift_language_mode": "5", "whole_module_optimization": True,
                                             "native_binary_version": "0.3.0-preview.15"})
        report["source_after"] = snapshot()
        report["source_unchanged"] = before == report["source_after"]
        if not report["source_unchanged"]:
            raise RuntimeError("Candidate sources changed during compatibility checks")
        report["success"] = True
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        report["error"] = str(error)
        print(str(error), file=sys.stderr)
    finally:
        report["duration_seconds"] = round(time.monotonic() - started, 3)
        (evidence / "result.json").write_text(json.dumps(report, indent=2) + "\n")
    return 0 if report["success"] else 1


if __name__ == "__main__":
    sys.exit(main())
