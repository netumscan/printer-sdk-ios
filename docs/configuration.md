# 连接与打印配置

[返回指南](README.md) · 适用版本 `0.3.0-preview.5`

连接只拥有通信通道；协议 Profile 在每次打印、介质设置或走纸时单独传入。
Android SPP 使用经典蓝牙 RFCOMM，BLE 需明确提供服务、写特征和流控配置；
iOS 使用 BLE 外设 UUID。设备名、扫描名称或开发 preset 都不构成硬件验证。

## 当前移动端支持矩阵

| 能力 | Android | iOS |
| --- | --- | --- |
| 最低编译／部署目标 | API21、Java8 | iOS15、Swift5/6 |
| 经典蓝牙连接 | SPP/RFCOMM | 不提供 |
| 系统已配对蓝牙设备枚举 | `bondedDevices` | 同名方法回调 1004 |
| BLE 连接／扫描 | 显式配置、`scanBle` | 显式配置、`scanBLE` |
| 未配对经典设备主动搜索 | Manager 不提供，交由 App／系统配对 | 不提供 |
| TCP／USB／串口 | 无移动 Manager 入口 | 无移动 Manager 入口 |
| CPCL／ESC-POS 光栅及 Raw | 已实现，均进入同一设备 FIFO | 同 Android |
| 介质／下一标签定位 | CPCL tracking 配置与定位；其他字段按能力拒绝 | 同 Android |
| 结构化切纸／硬件状态查询 | 不支持；状态查询回调 1004，不发送猜测指令 | 同 Android |
| 固件、SN、电量读回 | 不提供；sdkInfo 只表示 SDK 身份 | 同 Android |
| 解码、权限／配对界面 | App/plugin 负责 | App/plugin 负责 |
| 后台打印、自动重连／续打／重放 | 不提供 | 不提供 |

此矩阵描述软件实现，不表示最低系统运行、具体型号、实际 Flutter engine 或峰值内存已验收。
表中 1004 指参数和生命周期检查通过后的能力拒绝，不覆盖未连接或已关闭等错误。
Android `bondedDevices` 不按经典蓝牙／BLE 类型过滤；设备出现在列表中不表示其支持 SPP/RFCOMM。
未知硬件状态保持未知；验收范围随精确版本证据交付，`hardware_verified=false`。

Profile 描述明确的协议、DPI、宽度、页高及相关策略。`PreparedPrint` 描述标签或小票布局，
像素元素和空白顺序构建后固定；图像解码由应用在 Manager 的 preparation 中完成。
Android 的像素数组从交给请求到终态期间保持只读；Swift 使用只读 Data。
同一像素对象可在多个元素中复用，SDK 只导入一次 native 图像。
光栅条带与传输分块独立，应用不用保存完整的最终打印命令缓冲区。

`manager.capabilities` 异步返回只读能力值；分别检查 implementation、deviceSupport、evidence、
known 和 geometry 的有效字段。未知不等于支持、就绪或无限。标签页高是单页/单份限制，
小票 maxTotalLength 是所有副本和结束留白的整单预算，不能替换使用。

当前源载荷预算为单图 16MiB、每作业逻辑图片 32MiB、Raw 1MiB、活动与等待载荷 64MiB，
native 未终态 operation 最多 64 个，copies 为 1..100；Manager 另外限制 64 个未完成业务请求。
这些是接纳预算，不是手机 RSS 上限；资源不足应缩减输入或未完成工作，不通过轮询预留容量。

介质 DTO 可以表达完整字段，但不代表硬件支持。当前明确 CPCL Profile 只实现已确认的 tracking
设置，其他字段或持久化要求按能力校验返回不支持，不静默忽略。
当前未经验证的硬件查询通过 Manager 完成回调返回 `1004`，不发送猜测指令。
展示应用自己维护的连接状态与请求结果；不得把缓存连接成功解释为纸张正常、设备就绪或机械打印完成。
