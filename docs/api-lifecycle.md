# API 与生命周期

[返回指南](README.md) · 适用版本 `0.3.0-preview.4`

通过构造器创建独立 `PrinterManager`，每个实例至多管理一个连接，不使用共享单例。
连接参数只描述通信；每次打印单独提供经确认的 Profile 和 `PreparedPrint`。
输入描述不持有可操作的 native 句柄，应用无需释放 image/job/operation 或维护 SDK 订阅。

连接、扫描、打印、控制、查询、断开和关闭立即返回请求标识，并异步在主线程完成一次回调。
参数、状态、准备、准入及执行失败均从同一 `ManagerResult` 通道返回。
数据对象的构造器校验错误仍由应用处理，回调参数须有效；不要阻塞主线程等待完成。

打印的 `preparation` 在 SDK 后台执行。耗时解码、渲染和分块准备应检查 `CancellationContext`，
返回纯数据 `PreparedPrint`；不要自行创建打印 IO 队列或轮询器。Manager 按请求顺序进行准备和准入，
实际设备 IO 仍由同一个 native FIFO 串行执行。总超时覆盖等待、准备、准入及执行，不在开始发送时重置。
最多接纳 64 个未完成业务请求，超过限制通过完成回调返回 `1008`。

`ManagerResult` 包含请求标识、成功/失败/取消、稳定错误码、消息、完成证据、
`outputMayHaveOccurred` 和可选业务值。`dataSent` 仅证明传输完成；只有协议提供明确证据时才有
`deviceConfirmed`。移动 API 不公开阶段、队列快照、native operation ID、epoch 或资源快照。

| 动作 | 生命周期效果 |
| --- | --- |
| `manager.cancel(requestID)` | 请求取消等待、准备、准入或执行中的本实例请求；外部实例或已完成标识无效。 |
| `manager.disconnect(completion)` | 结束本会话请求并释放设备；清理完成后可显式连接另一台设备。 |
| `manager.close(completion)` | 幂等地永久关闭 Manager；清理完成后业务请求返回 InvalidState。 |

断开和关闭的完成回调在本会话请求终态安排交付、设备和扫描资源释放后交付。
清理不依赖应用准备函数合作返回；迟到的准备结果不会再次准入。意外断连仅通知所属连接，
旧连接事件不能影响后续连接。SDK 不自动重连、续打、重试或重放。

Swift 回调为 `@Sendable`；主队列派发不等于 closure 静态属于 MainActor，UI 更新使用
`Task { @MainActor in ... }`。应用无需 `@preconcurrency import`，也不应给未同步的可变对象
添加 `unchecked Sendable` 来压制诊断。

共享会话由应用级所有者持有；页面离开仅解除自己的 UI 回调，不默认取消共享工作或关闭设备。
独占页面结束时由其所有者调用异步 close，避免把自己的清理责任转移给其他页面。
