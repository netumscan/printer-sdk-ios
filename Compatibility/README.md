# Xcode 16.4 compile compatibility preflight

This branch validates the six-line internal `PrinterCapabilities` initializer fix before the independent iOS `0.3.0-preview.16` release. It is based on the exact public `.15` source tree, with only that Swift fix and these compatibility checks added.

The root `Package.swift`, podspec and release metadata intentionally remain the published `.15` inputs. SwiftPM downloads the already published `.15` `CPrinterSDK` ZIP using its exact SHA-256. No native source is present, no tag or Release is created, and this tree must never be published as the final `.16` package.

The workflow runs only on `codex/ios-compat-*` push branches. It requires the `macos-15` arm64 runner and `/Applications/Xcode_16.4.app/Contents/Developer`. A fresh, independent consumer builds the complete Swift wrapper in Release, Swift 5 language mode, `-O` and whole-module optimization for device arm64 and simulator arm64/x86_64. Each app and native framework architecture is checked. No app is launched; no printer, simulator or physical device is accessed.

A successful `result.json` proves compilation compatibility for this exact candidate source plus the `.15` native binary. It does **not** prove the final `.16` native artifact, final package consumption, runtime behavior, CocoaPods consumption, printer IO or hardware acceptance. Final `.16` packaging and release gates remain required.

```sh
# Show the exact plan without probing Xcode or writing files.
python3 -B Compatibility/check.py --output /absolute/path/to/new-evidence --plan

# Actual CI invocation; Xcode 16.4 is mandatory.
DEVELOPER_DIR=/Applications/Xcode_16.4.app/Contents/Developer \
  python3 -B Compatibility/check.py --output /absolute/path/to/new-evidence
```

Evidence contains the exact candidate Git commit, complete tracked source inventory, Xcode/Swift versions, all commands and logs, and separate results for all three architectures. The input inventory must remain unchanged during the check.
