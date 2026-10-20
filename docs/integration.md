# Android/iOS App 接入

[返回指南](README.md) · 适用版本 `0.3.0-preview.5` · native `0.3.0` · ABI `3/r2`

Android 最低 API 21、Java 8；iOS 最低 iOS 15。当前未发布开发版使用本地 SDK 工程或本地制品，
不要用线上旧版本替代。只有对应版本实际发布后，才可使用精确 Maven 坐标或 SwiftPM exact version；
SDK 的分发身份、校验和与运行库身份必须相符。

App 负责权限、选择设备及必要的配对；iOS 配置 `NSBluetoothAlwaysUsageDescription`。
BLE 服务、特征、流控和打印 Profile 必须来自已确认配置，不从设备名推断。
连接只建立通信，每次打印另外提供协议、DPI、宽度与纸张参数。

以下代码直接取自持续编译检查的 `LabelSession.java` 和 `AppPrinter.swift`。
Android 与当前 SDK 按 Java 8 编译，iOS 与新编译的 SDK module 按 iOS 15、Swift 5/6 类型检查。
编译验证不表示真机打印通过。

## Android 会话

将代码保存为 App 源码 `LabelSession.java`，按工程添加 package，由页面或应用所有者持有。
构造时提供应用 Context、地址、明确 Profile 与 Ui；BleOptions 为 null 选择 SPP，否则选择 BLE。
连接结果从 `Ui.connection(ManagerResult)` 返回，以 outcome/code 判断成功；意外断连走 `Ui.disconnected`。
`print(preparation, timeoutMs)` 的 preparation 在 SDK 后台运行，检查取消并返回 `PreparedPrint`，
终态从 `Ui.completed` 交付，调用方不需要管理 SDK 任务句柄或订阅。

```java
import android.content.Context;
import com.netumscan.printersdk.*;

/** App-only notification target. All actual control stays on the Manager. */
public final class LabelSession implements AutoCloseable {
    public interface Ui {
        void connection(ManagerResult<Void> result);
        void disconnected(ManagerResult<Void> result);
        void completed(ManagerResult<Void> result);
    }
    private final PrinterManager manager;
    private final CpclProfile profile;
    private volatile Ui ui;
    private RequestId active;
    public LabelSession(Context context, String address, BleOptions ble, CpclProfile profile, int timeoutMs, Ui ui) {
        manager = new PrinterManager(context); this.profile = profile; this.ui = ui;
        manager.connect(ble == null ? ConnectionOptions.spp(address) : ConnectionOptions.ble(address, ble), timeoutMs,
            result -> { Ui target = this.ui; if (target != null) target.connection(result); },
            result -> { Ui target = this.ui; if (target != null) target.disconnected(result); });
    }
    /** The preparation callback runs in the SDK background coordinator. */
    public void print(PrinterManager.Preparation preparation, int timeoutMs) {
        active = manager.print(profile, new PrintOptions(timeoutMs), preparation, result -> {
            Ui target = ui; if (target != null) target.completed(result);
        });
    }
    public void cancel() { manager.cancel(active); }
    @Override public void close() { ui = null; manager.close(result -> { }); }
}
```

像素应为 GRAY8 原始数组，长度等于 width*height；PNG/JPEG 先在 preparation 解码。
从交给请求到终态期间保持数组只读。`cancel()` 取消最近一次请求；需要管理多个请求时，
应用所有者自行保存 RequestId 集合。页面结束调用 close，它解除 UI 目标并异步关闭独占 Manager。

## iOS 会话

由 ViewModel 持有 `AppPrinter`，在 MainActor 上设置 showConnection、showResult 与 disconnected。
`connect` 和 `printGray8` 立即返回 RequestID；连接、打印、断开和关闭通过 completion 报告，
不使用 async/await 控制重载。示例直接 `import PrinterSDK`，`@Sendable` 回调通过 MainActor 更新 UI。

```swift
import Foundation
import PrinterSDK

// An App/ViewModel owner. Only the Manager controls the printer or owns SDK work.
@MainActor
final class AppPrinter {
    private let manager: PrinterManager
    private var requests: Set<RequestID> = []
    var showConnection: (ManagerResult<Void>) -> Void = { _ in }
    var showResult: (ManagerResult<Void>) -> Void = { _ in }
    var disconnected: (ManagerResult<Void>) -> Void = { _ in }

    init(manager: PrinterManager = PrinterManager()) { self.manager = manager }

    @discardableResult
    func connect(identifier: UUID, options: BLEOptions) -> RequestID {
        manager.connect(bleIdentifier: identifier, options: options, completion: { [weak self] result in
            self?.showConnection(result)
        }, onDisconnected: { [weak self] result in
            self?.disconnected(result)
        })
    }

    @discardableResult
    func printGray8(_ pixels: Data, width: UInt32, height: UInt32, profile: CpclProfile) -> RequestID {
        let id = manager.print(profile: profile, preparation: { cancellation in
            try cancellation.checkCancellation()
            let image = Pixels(data: pixels, width: width, height: height)
            return PreparedPrint(label: LabelJobOptions(widthDots: profile.widthDots,
                heightDots: height, dpi: profile.dpi, originXDots: Int32(profile.xOffsetDots),
                form: profile.form), elements: [.image(image)])
        }, completion: { [weak self] result in
            guard let self else { return }
            requests.remove(result.requestID)
            showResult(result) // dataSent is transport completion, not paper completion.
        })
        requests.insert(id)
        return id
    }

    func cancel(_ id: RequestID) { manager.cancel(id) }
    func cancelPrint() { for id in requests { manager.cancel(id) } }
    func disconnect(_ completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void = { _ in }) {
        manager.disconnect(completion: completion)
    }
    func close(_ completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void = { _ in }) {
        manager.close(completion: completion)
    }
}
```

像素为 GRAY8 原始 Data；每次 printGray8 显式提供 Profile。
`cancel(requestID)` 取消指定请求，cancelPrint 取消当前保存的打印请求；disconnect 完成后可显式重连，
close 永久结束独占所有权。不要在主线程同步等待这些完成回调。

共享 Manager 应由应用级所有者持有，页面离开仅解除 UI 绑定，不默认取消共享任务或关闭设备。
`DATA_SENT` 只表示发送完成，取消和失败可能已有部分输出；SDK 不自动重连、续打或重放。
