# 迁移到 Manager

[返回指南](README.md) · 适用版本 `0.3.0-preview.5`

当前移动 API 以 `PrinterManager` 作为唯一控制入口。这是 Java/Swift API 的不兼容迁移，
C ABI 仍为 native `0.3.0` / ABI `3/r2`；既有 r1/r2 C 消费者不会因移动类型隐藏而失去导出入口。
旧在线制品、公开样例、候选快照和历史证明继续保留。

1. 通过构造器为业务所有者创建独立 Manager；连接只传通信目标，每次打印显式提供 Profile。
2. 将图片解码和渲染放入 `preparation`，检查取消上下文并返回 `PreparedPrint` 数据描述；
   不再向应用公开或传递 native image/job/operation 句柄。
3. 以请求标识和完成回调管理每次操作，读取 `ManagerResult` 的 outcome/code/completion；
   删除应用自己的 SDK 任务轮询和 IO 队列，不向用户展示内部阶段、队列或资源快照。
4. 取消调用 `manager.cancel(requestID)`；断开和永久关闭使用各自异步完成回调。
   页面退出只解除自己的 UI 绑定，共享 Manager 由应用级所有者决定何时关闭。
5. 区分 dataSent 与 deviceConfirmed，硬件状态未验证时显示未知；遇到断连、超时或取消不自动重放。

Raw、介质、走纸和查询同样经过 Manager 进入 native 设备队列，不增加旁路 IO。
完整编译声明与数据 DTO 见 [Java API](android-java-api.md) 和 [Swift API](ios-swift-api.md)，
经过编译检查的应用会话代码见[接入](integration.md)。
