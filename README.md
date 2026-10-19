# printer-sdk-ios

NETUM Printer SDK iOS 开发预览 **0.3.0-preview.2**：核心 SDK 0.3.0，C ABI 3/r1。
冻结契约状态为 `candidate`；文档本身不作为在线发布或硬件认证证明。
Framework Bundle ID 为 `com.netumscan.printersdk.core`；Swift 模块为 `PrinterSDK`，C 模块为 `CPrinterSDK`。
ABI 3 仅包含 `printer_sdk.h`，与 ABI 2 二进制不兼容；旧版标签及历史附件保持不变。

[客户指南](docs/README.md) 包含权限、生命周期、操作配置、错误码、迁移和 API 清单。
[Samples](https://github.com/netumscan/printer-sdk-samples) 提供 Quick Start、Full Demo 及共享 App 示例；
使用时核对 SDK 版本锁，旧 ABI2 示例不能直接混用本版库。

## 本地集成与候选分发

要求 iOS 15+、Swift 5.9+。XCFramework 包含 iOS arm64 以及 iOS Simulator arm64/x86_64。
Swift 包装源码与 C 头供集成使用，C++ 核心只以二进制分发。
准备目录中的 `Package.swift` 记录将来的精确版本 URL 和校验和；上传前该 URL 可能不存在。
本地独立 Consumer 验证会把 binary target 临时改为本地 XCFramework 路径，不需要远端依赖。

发布经单独授权并验证后，Xcode Package Dependencies 才可选择以下仓库及 Exact Version `0.3.0-preview.2`：

```swift
.package(url: "https://github.com/netumscan/printer-sdk-ios", exact: "0.3.0-preview.2")
```

候选二进制 URL：[https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.2/PrinterSDK.xcframework.zip](https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.2/PrinterSDK.xcframework.zip)。这段配置本身不是在线可用性证明。

## App 生命周期

App `Info.plist` 须设置 `NSBluetoothAlwaysUsageDescription`。蓝牙 UUID、写入方式和 Profile
由调用方依据固件及纸张验证后传入；SDK 不推断机型或 UUID。

```swift
import Foundation
import PrinterSDK

func connect(manager: PrinterManager, identifier: UUID,
             options: BLEOptions) async throws -> MobilePrinter {
    let printer = try manager.printer(bleIdentifier: identifier, options: options)
    try await manager.connect(printer)
    return printer // manager owns this borrowed device
}

// Run image processing and submission on an App worker. Retain the returned operation.
func submit(printer: MobilePrinter, pixels: Data,
            profile: CpclProfile) throws -> PrintOperation {
    let operation = try printer.submitGray8(pixels, width: 8, height: 1, profile: profile)
    try operation.onComplete { result in // main queue by default; one copied terminal result
        print(result.snapshot.errorCode, result.snapshot.bytesSent)
    }
    return operation
}
```

通过 `printer.observeState { snapshot in ... }` 订阅连接、工作和队列状态，保留返回的
`ObservationSubscription`，离开页面时调用 `cancel()`；硬件状态目前为未知。
取消任务用 `try operation.cancel()`。`operation.close()` 释放调用方访问权，已经注册的完成回调仍会兑现；
退订回调用订阅 token 的 `cancel()`，不会取消打印任务。结束时 `await manager.release(printer)`，
或由独占 manager 的拥有者 `await manager.close()`。关闭 manager 后不能复用。
App 还需用自己的页面/设备代次隔离过期回调，避免后台提交和页面关闭竞态。

每次打印明确传入 Profile。`PrinterImage` 像素创建时复制一次，`PrintJob` 构建后不可变并共享图像存储。
同一设备所有 IO 由 SDK 队列串行执行。数据传输完成不代表物理打印完成；取消不能撤回已发数据。
连接中断后需显式重连，不自动续打或重放。`PrinterSDK.info()` 返回运行库身份；
能力的实现标记不等于硬件支持，须同时检查设备支持和证据。

## 隐私与许可

SDK 不包含分析、广告或遥测上传。SwiftPM 包含 `PrivacyInfo.xcprivacy`，对超时计时使用的系统启动时间
API 声明 `35F9.1`。App 需根据自身权限、数据处理和分发方式完成隐私披露。
见 [LICENSE](LICENSE)；允许商业应用免费集成及随应用再分发。

本包 `hardware_verified=false`。本地无签名构建及独立工程编译链接只能证明软件分发路径，
不包含手机安装、蓝牙联调、固件/机型/纸张故障矩阵或真机峰值内存验收。
