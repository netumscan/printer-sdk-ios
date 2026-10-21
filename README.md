# NETUM Printer SDK for iOS

开发预览 **`0.3.0-preview.10`**，原生 SDK **`0.3.0`**、C ABI **`3/r2`**。
冻结契约状态为 `candidate`；候选声明本身不证明已经签名、上传或线上发布。
Swift 模块为 `PrinterSDK`，原生模块为 `CPrinterSDK`，Framework Bundle ID 为 `com.netumscan.printersdk.core`。

[客户指南](docs/README.md) 包含权限、连接、图片、回调、错误码与完整公开 API。
本版移动 API 需要迁移和重新编译；C ABI 3/r2 保持 27 个 C 导出，不兼容 ABI 2。
Swift 包装源码和 C 头随包提供，C++ 核心只以二进制分发。许可和第三方声明见 [LICENSE](LICENSE) 与 [LICENSE-NOTICE.md](LICENSE-NOTICE.md)。

## 集成

要求 iOS 15+、Swift 5.9+。XCFramework 包含设备 arm64 和 Simulator arm64/x86_64。
实际发布后使用精确 SwiftPM 版本：

```swift
.package(url: "https://github.com/netumscan/printer-sdk-ios", exact: "0.3.0-preview.10")
```

候选二进制 URL：[https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.10/XLPrinterSDK.xcframework.zip](https://github.com/netumscan/printer-sdk-ios/releases/download/v0.3.0-preview.10/XLPrinterSDK.xcframework.zip)。准备目录的 `Package.swift` 包含此 URL 与制品校验和；上传前 URL 可能尚不可用。本地独立消费者通过本地 XCFramework 路径验证。
[Samples](https://github.com/netumscan/printer-sdk-samples) 提供精确版本示例，集成时核对对应 SDK 锁。

## BLE连接与图片

App `Info.plist` 配置 `NSBluetoothAlwaysUsageDescription`。每个 `PrinterManager()` 同时管理一台 BLE 设备；`scanBLE` 返回 `DiscoveredPrinter`。iOS 不提供经典蓝牙 SPP 或系统已配对列表。

原设备名可推荐内置 `PrinterModel`；改名的已收录设备可以显式选型号，未知型号不得按 M90 猜测。无可匹配原名（包括只有 UUID、没有名称的目标）且未显式选择已收录型号时，连接回调报告 1004。服务、特征及流控参数由 SDK 内部管理。以下代码适用于调用方已确认属于 LT-M90 的设备：

```swift
import Foundation
import PrinterSDK

func connectAndPrint(manager: PrinterManager, device: DiscoveredPrinter, pngJpeg: Data) {
    manager.connectBle(device: device, model: .ltM90, completion: { connection in
        guard connection.isSuccess else { return }
        manager.printEncodedImage(pngJpeg, widthMm: 50, heightMm: 50, completion: { result in
            print(result.code, result.completion, result.outputMayHaveOccurred)
        })
    }, onDisconnected: { result in
        print("disconnected:", result.code)
    })
}
```

`printEncodedImage` 接收完整 PNG/JPEG `Data`，编码上限 32 MiB；大图推荐此入口，以便后台按页面目标采样。已有非动画、CGImage 支持的 `UIImage` 时直接使用 `printImage(_:widthMm:heightMm:completion:)`，其源像素 `bytesPerRow × height` 上限为 16 MiB。动画或没有 `cgImage` 的 CI-only／矢量等图片报告 1001；调用方可先渲染为 CGImage 支持的图片，或提供 PNG/JPEG Data。资源超限报告 1008。页面宽高为毫米，按已采用型号的精确点密度换算，不使用图片 DPI 或 `UIImage.scale` 决定纸面尺寸。

两入口返回前取得稳定输入快照，复制期间调用方不得并发修改输入。解码、方向修正、透明白底和缩放在有界后台执行；固定一份、阈值 128、不反色，等比缩小并居中补白，不放大、不裁剪，不隐式 FORM、切纸或下一标签定位。文本、条码等先由 App 绘制成图片。

`setPaperType` 独立采用 `.gapLabel`／`.blackMark`／`.continuous`，不隐式校准或持久化；`locateNextLabel` 独立定位。连接后空闲时可 `setPrinterModel`，以成功回调的 `ConnectionInfo` 为准；型号选择不是硬件认证。

## 请求与生命周期

异步操作立即返回 `RequestID`，完成与意外断连闭包均为 `@MainActor @Sendable`，主线程只交付一次终态。取消使用 `manager.cancel(requestID)`；`manager.disconnect { result in ... }` 清理完成后可显式重连，所有者结束时 `manager.close { result in ... }`，关闭后不能复用。不要同步等待主线程回调。

所有设备 IO 共用原 FIFO，SDK 不自动重连、续打或重放。取消和失败可能已有输出；`dataSent` 仅证明数据传输完成。能力为三态，缺纸／开盖／纸将尽／切刀错误为可空布尔，未知不能解释为正常。`sdkInfo` 从实际链接的库返回版本和可选构建标识。

Flutter 的 PNG/JPEG `Uint8List` 经标准 codec 转为 `FlutterStandardTypedData.data` 后直接交给编码入口，不使用 Base64 或裸 RGBA。文件授权、缓存、页面绑定和后台策略由 App／插件负责。

## 隐私与验证范围

SDK 不包含分析、广告或遥测上传。SwiftPM 保留 `PrivacyInfo.xcprivacy`，系统启动时间 API 声明 `35F9.1`；App 仍按自身行为完成隐私披露。

`hardware_verified=false`。源码编译、制品消费者与模拟器检查不等于真实无线、纸面或手机峰值内存验收；旧在线版本报告不替代本版验证。SDK 不公开底层作业、图片准备对象、平台句柄或队列控制接口。
