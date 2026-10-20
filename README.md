# printer-sdk-ios

NETUM Printer SDK iOS 开发预览 **0.3.0-preview.4**：核心 SDK 0.3.0，C ABI 3/r2。
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

发布经单独授权并验证后，Xcode Package Dependencies 才可选择以下仓库及 Exact Version `0.3.0-preview.4`：

```swift
.package(url: "https://github.com/netumscan/printer-sdk-ios", exact: "0.3.0-preview.4")
```

候选二进制 URL：[https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.4/PrinterSDK.xcframework.zip](https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.4/PrinterSDK.xcframework.zip)。这段配置本身不是在线可用性证明。

## App 生命周期

App `Info.plist` 须设置 `NSBluetoothAlwaysUsageDescription`。蓝牙 UUID、写入方式和 Profile
由调用方依据固件及纸张验证后传入；SDK 不推断机型或 UUID。

```swift
import Foundation
import PrinterSDK

func connect(manager: PrinterManager, identifier: UUID, options: BLEOptions) {
    manager.connect(bleIdentifier: identifier, options: options, completion: { result in
        print("connect:", result.code)
    }, onDisconnected: { result in
        print("disconnected:", result.code)
    })
}

func submit(manager: PrinterManager, pixels: Data, profile: CpclProfile) -> RequestID {
    manager.print(profile: profile, preparation: { cancellation in
        try cancellation.checkCancellation()
        return PreparedPrint(label: LabelJobOptions(widthDots: profile.widthDots,
            heightDots: 1, dpi: profile.dpi),
            elements: [.image(Pixels(data: pixels, width: 8, height: 1))])
    }, completion: { result in
        print(result.code, result.completion, result.outputMayHaveOccurred)
    })
}
```

每次请求通过方法参数回调异步交付主线程，只返回纯 `RequestID`，不公开设备、operation 或订阅对象。
取消使用 `manager.cancel(requestID)`。`manager.disconnect { result in ... }` 完成后可以显式连接另一台设备；
结束所有权时调用 `manager.close { result in ... }`，关闭后不能复用。
一个 Manager 同时拥有一台设备，多设备使用多个实例。页面退出只解除应用自己的 UI 通知。

每次打印明确传入 Profile。准备闭包在后台生成原始像素描述，原生导入复制一次，后续共享只读存储。
同一设备所有 IO 由 SDK 队列串行执行。数据传输完成不代表物理打印完成；取消不能撤回已发数据。
连接中断后需显式重连，不自动续打或重放。`manager.sdkInfo { result in ... }` 返回运行库身份；
能力的实现标记不等于硬件支持，须同时检查设备支持和证据。

## 隐私与许可

SDK 不包含分析、广告或遥测上传。SwiftPM 包含 `PrivacyInfo.xcprivacy`，对超时计时使用的系统启动时间
API 声明 `35F9.1`。App 需根据自身权限、数据处理和分发方式完成隐私披露。
见 [LICENSE](LICENSE)；允许商业应用免费集成及随应用再分发。

本包 `hardware_verified=false`。本地无签名构建及独立工程编译链接只能证明软件分发路径，
不包含手机安装、蓝牙联调、固件/机型/纸张故障矩阵或真机峰值内存验收。
