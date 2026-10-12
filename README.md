# printer-sdk-ios

NETUM Printer SDK 的 iOS 在线预览包，版本 **0.2.0-preview.3**。核心 SDK 0.2.0，C ABI 2/r10。
Framework 内部 Bundle ID 统一为 `com.netumscan.printersdk.core`；公共 `import PrinterSDK`
及 C 模块 `CPrinterSDK` 保持不变。此前预览版标签和附件继续保留。

[客户指南](docs/README.md) 提供权限、API 生命周期、纸张配置、错误码、兼容诊断、迁移和安全反馈。
可运行工程见 [Quick Start / Full Demo](https://github.com/netumscan/printer-sdk-samples)。

在 Xcode 的 Package Dependencies 中添加：

```text
https://github.com/netumscan/printer-sdk-ios
```

版本规则选择 Exact Version：`0.2.0-preview.3`，将 `PrinterSDK` 产品链接到 App target。
SwiftPM 工程可使用：

```swift
.package(url: "https://github.com/netumscan/printer-sdk-ios", exact: "0.2.0-preview.3")
```

要求 iOS 15+、Swift 5.9+。二进制包含 iOS arm64 与 iOS Simulator arm64/x86_64。
Swift 包装层及 C 头文件供集成使用，C++ 核心仅以 XCFramework 二进制分发。
下载地址：[https://github.com/netumscan/printer-sdk-ios/releases/download/v0.2.0-preview.3/PrinterSDK.xcframework.zip](https://github.com/netumscan/printer-sdk-ios/releases/download/v0.2.0-preview.3/PrinterSDK.xcframework.zip)。无需访问私有开发仓库。

## 接入示例

先在 App 的 `Info.plist` 中配置 `NSBluetoothAlwaysUsageDescription`，例如“连接蓝牙打印机并打印”。
扫描和连接需要手机蓝牙打开及用户授权；Simulator 用于编译和模拟验证，真机用于蓝牙联调。

```swift
import Foundation
import PrinterSDK

let scanner = BLEScanner()
scanner.scan(seconds: 10) { result in
    // 保留 scanner；从 .success(devices) 选择用户实际要连接的 identifier。
    // .failure(error) 表示权限、蓝牙状态、取消或其他扫描错误。
}

// identifier 来自扫描；pageHeightBudgetDots 是调用方的页高预算，不代表型号能力。
// 调用方需依据实际纸张和固件验证该预算，并保留 printer 至打印结束。
func makeLabelPrinter(identifier: UUID, pageHeightBudgetDots: UInt32) throws -> MobilePrinter {
    let profile = try CpclProfile(dpi: 203, widthDots: 864,
                                  maxLabelHeightDots: pageHeightBudgetDots, form: true)
    return try MobilePrinter(bleIdentifier: identifier,
                             options: M90Profile.bleOptions(), profile: profile)
}
```

`connect()` / `disconnect()` 应在后台队列调用；`submitGray8()` 校验并入队后返回 `PrintOperation`。
使用 `operation.snapshot()` 读取结果，结束后调用 `operation.close()`；释放设备时调用 `printer.close()`。
取消不撤回已经发送的数据。
数据传输完成不代表物理打印完成；连接中断后需显式重新连接，不会自动重放任务。

`feature(_:)` 返回 `FeatureSupport` 的实现、设备支持和证据三字段。`isImplemented`
不证明硬件支持；`isSupported=false` 也可能表示未知，须检查 `deviceSupport`。
详见 [FeatureSupport](docs/api-lifecycle.md#featuresupport)。

## 隐私与许可

SDK 不包含分析、广告或遥测上传，打印内容通过所选打印机传输发送。
SwiftPM 包含 `PrivacyInfo.xcprivacy`，对应用内超时计时使用的系统启动时间 API 声明 `35F9.1`。
应用仍需根据自身的权限、数据处理和发布方式完成隐私披露。
Apple API 依据：[NSPrivacyAccessedAPITypeReasons](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitypereasons)。

见 [LICENSE](LICENSE)。允许商业应用免费集成及随应用再分发；SDK 为闭源软件，公开源码仅供 SDK 集成及 API 使用。

## 预览限制

这是开发预览版，`hardware_verified=false`。已验证分发包完整性及独立工程的编译链接；
完整固件/机型/无线/纸张故障矩阵与手机峰值内存验收仍在进行中。不得据此声明硬件已全面认证。
当前 Swift 包装支持 BLE CPCL 标签及 ESC/POS 小票图像路径，具体能力以所选配置和固件为准。
当前 M90 真机联调中，取消任务后重新连接可能打印短斜痕，此问题仍待解决。
ESC/POS 路径尚未完成真机硬件验收。
