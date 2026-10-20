# iOS Swift API 参考

发布候选版本 **0.3.0-preview.5**；原生 SDK **0.3.0**；C ABI **3/r2**。

本页逐项覆盖审定的编译器公共 API 基线，共 **275** 个文档条目。
声明、JVM descriptor、常量、枚举和编译器关系均来自基线，说明按稳定文档 ID 维护。
机器可读的完整基线与说明见 [api-reference.json](api-reference.json)；运行
`python3 tools/check-api-reference.py` 可检查覆盖范围、审定 SHA-256 和本页字节一致性。

基线 SHA-256：`affaba2490e4db54029a34867b9774917b0cb07e928276742609533e9ccd9169`

运行约束与错误处理见 [API 与生命周期](api-lifecycle.md) 和 [错误码与排障](errors-troubleshooting.md)。
本页是未发布的发布候选契约，不代表发布制品或公开历史证明。硬件验收仍暂缓，`hardware_verified=false`。

## 类型导航

- [BLECreditFlowControl](#api-cf29222de3a9439ea9d9)
- [BLEOptions](#api-5407994e1f7a0684ecd6)
- [CancellationContext](#api-1bc8aaf9370f29dafae0)
- [CompletionLevel](#api-7027c38eacd1e136b879)
- [CpclProfile](#api-d94c01c25a5ac00d3af5)
- [CutMode](#api-ca87677d19e3423fb23c)
- [DiscoveredPrinter](#api-e7eba043862754865338)
- [FeatureSupport](#api-63244971bb8665f0438c)
- [FinishScope](#api-8da32930540a97e6bfd9)
- [ImageAlgorithm](#api-41361c67b37b815a38ae)
- [LabelJobOptions](#api-9cd007436b5a242686f9)
- [M90Profile](#api-c09da0bc38ed43e7aef2)
- [ManagerOutcome](#api-625d7c79302095211bcb)
- [ManagerResult](#api-d5c711f55a02b7703b81)
- [MediaMode](#api-e9f6609ce460a51cc89f)
- [MediaPersistencePolicy](#api-443778f8722036fd1c08)
- [MediaRequirement](#api-623f02309548c44d0ebb)
- [MediaSettings](#api-a2a66f93bc7ef29553ce)
- [MediaVerificationPolicy](#api-afcd3a74fc08e909f85d)
- [PixelFormat](#api-145004af19a837676c99)
- [Pixels](#api-6bb193bc6a8b988482be)
- [PreparedPrint](#api-1c60054e629e6db79dd6)
- [PrintElement](#api-bc94fceab7b905f1b496)
- [PrintOptions](#api-7ef50076423442cb8f07)
- [PrinterCapabilities](#api-51947abf7e628a2d3bc3)
- [PrinterConstraint](#api-1f9f816f9d0db63d9e95)
- [PrinterFeature](#api-67c88d53ad46bc6679a5)
- [PrinterGeometry](#api-b511b313f54808d516b6)
- [PrinterManager](#api-1d5ad0ccf40ef0036743)
- [PrinterProtocol](#api-7c7a9dd0ee08114f96bd)
- [PrinterSDKError](#api-7eade5ddc7d13cb74d9a)
- [ReceiptFinishOptions](#api-7a656acf1cbdc7b0f7ad)
- [ReceiptJobOptions](#api-082376dfdfb0bb2ec7b4)
- [ReceiptProfile](#api-8a4489e38f48eaabb599)
- [RequestID](#api-98f79d03f589f3f1383b)
- [SDKInfo](#api-313c383cb33723929d18)
- [ScalarConstraint](#api-5c2f7f6243349bf78f99)
- [StatusQueryConfiguration](#api-4b76054d7c5874efb333)
- [StatusResult](#api-498d0aa8573deb1c5df3)

公共模块为 `PrinterSDK`，C 桥接模块为 `CPrinterSDK`。
本基线使用 iOS 15 arm64；符号附带的 Foundation 可用性不表示其他平台已完成分发或验收。
未单列 availability 的符号以 SDK 的最低 iOS 版本 15 为接入前提。

<a id="api-cf29222de3a9439ea9d9"></a>

## BLECreditFlowControl

<a id="api-6524be748f6e725d4fc5"></a>

### BLECreditFlowControl

同一服务中 Data Transmission V1.2 的通知特征配置。

```swift
struct BLECreditFlowControl
```

保存 `dataOut` 和 `dataFC` UUID；通过 `BLEOptions.creditFlowControl` 启用，写入特征由 `BLEOptions` 单独配置。只有与固件协议匹配时使用，不自动探测或认证设备。构造本身不订阅通知或进行 IO。

文档 ID：`apple:symbol:s:10PrinterSDK20BLECreditFlowControlV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-8eb334e5f5223bd3125b"></a>

### BLECreditFlowControl.dataFC

提供 V1.2 接收 Credit 和包长信息的通知特征 UUID。

```swift
let dataFC: UUID
```

传输根据有效流控信息限制发送，没有可用 Credit 时等待，等待受取消和总截止时间约束。它只管理接收容量，不是打印完成确认。与 Data Out、写入特征的互异条件由 `BLEOptions` 校验。

文档 ID：`apple:symbol:s:10PrinterSDK20BLECreditFlowControlV6dataFC10Foundation4UUIDVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-875e230d2b4289113cc0"></a>

### BLECreditFlowControl.dataOut

选定服务中的 Data Out 通知特征 UUID。

```swift
let dataOut: UUID
```

用于启用 V1.2 要求的通知路径。当前适配器不把此特征通知作为公开状态、读回或打印完成结果；不能以收到通知证明标签已打印。与写入、Data FC 特征的互异条件由 `BLEOptions` 校验。

文档 ID：`apple:symbol:s:10PrinterSDK20BLECreditFlowControlV7dataOut10Foundation4UUIDVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-2d3b7593669608215aae"></a>

### BLECreditFlowControl.init(dataOut:dataFC:)

保存 Data Out 和 Data FC 通知特征 UUID。

```swift
init(dataOut: UUID, dataFC: UUID)
```

两个参数均必填、无默认值；本初始化不抛出异常。与写入特征互异及只允许无响应写入的条件在 `BLEOptions` 初始化时校验。连接时还必须确认特征存在且具有所需通知能力。

文档 ID：`apple:symbol:s:10PrinterSDK20BLECreditFlowControlV7dataOut0F2FCAC10Foundation4UUIDV_AHtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-5407994e1f7a0684ecd6"></a>

## BLEOptions

<a id="api-77d41a22c85fa7300778"></a>

### BLEOptions

不可变的 BLE 服务、写入方式和可选流控配置。

```swift
struct BLEOptions
```

应用显式配置与目标固件一致的服务和特征；这些值不自动识别型号，也不构成硬件验证。所有字段在初始化时保存，通过 `PrinterManager.connect` 使用。当前前台 BLE 传输不提供平台原生句柄，权限和前后台策略由应用负责。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-5ed7463fa203f0207e35"></a>

### BLEOptions.creditFlowControl

可选的 Data Transmission V1.2 Credit 流控配置。

```swift
let creditFlowControl: BLECreditFlowControl?
```

默认 `nil` 表示未启用该流控；非空时使用 Data Out/Data FC 通知，并要求无响应写入及三个互异特征。Credit 表示接收容量，不是应用层逐包 ACK、纸张状态或打印完成确认。其等待受原操作超时及取消约束；不把通知载荷作为公开状态结果。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV17creditFlowControlAA09BLECrediteF0VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| BLECreditFlowControl | `s:10PrinterSDK20BLECreditFlowControlV` |

<a id="api-52654e007a72061d6748"></a>

### BLEOptions.init(service:writeCharacteristic:withResponse:maxWriteBytes:creditFlowControl:)

校验并构造明确的 BLE 写入配置。

```swift
init(service: UUID, writeCharacteristic: UUID, withResponse: Bool, maxWriteBytes: Int, creditFlowControl: BLECreditFlowControl? = nil) throws
```

`service` 为包含各目标特征的服务 UUID，`writeCharacteristic` 为写入特征 UUID；`withResponse` 选择 GATT 有响应/无响应写入，无默认值。`maxWriteBytes` 为每次平台写入的应用上限，单位字节，必须在 1…512；实际单包长度还受系统写入上限和启用流控时固件通知的独立 `packetLimit` 限制。Credit 单独控制剩余发送次数，每发送一包消耗 1 个，不表示可发送字节数。`creditFlowControl` 默认 `nil`；非空时仅允许 `withResponse == false`，且写入、Data Out 和 Data FC 三个特征 UUID 必须互不相同。上述条件不满足时，初始化同步抛出 1001。初始化只校验配置，不发现服务、不连接、不确认固件支持；特征能力在连接时验证，不支持时通过连接完成回调异步返回 1004。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV7service19writeCharacteristic12withResponse13maxWriteBytes17creditFlowControlAC10Foundation4UUIDV_AKSbSiAA09BLECreditmN0VSgtKcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| BLECreditFlowControl | `s:10PrinterSDK20BLECreditFlowControlV` |
| Bool | `s:Sb` |
| Int | `s:Si` |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-4aafe93560df3b56ca06"></a>

### BLEOptions.maxWriteBytes

每次 BLE 平台写入的应用载荷上限。

```swift
let maxWriteBytes: Int
```

单位字节，初始化接受 1…512。实际包长取应用上限、平台最大写入长度，以及启用 Credit 时固件公告包长等约束的最小值；此值不是协商 MTU，也不表示每次都会写满，不应从型号名称推断。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV13maxWriteBytesSivp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-a69cec0ede2b2be6566e"></a>

### BLEOptions.service

连接后查找目标写入与流控特征的服务 UUID。

```swift
let service: UUID
```

由初始化参数明确提供，无隐式型号默认值。配置正确性仍须由实际服务发现和目标固件确认；发现广播中未列出此服务不等于连接后不存在。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV7service10Foundation4UUIDVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-ab9670d691ab1ad3b3c0"></a>

### BLEOptions.withResponse

选择是否使用 GATT 有响应写入。

```swift
let withResponse: Bool
```

true 请求 `.withResponse`，false 请求 `.withoutResponse`。使用 Credit 流控时必须为 false；构造器拒绝相冲突配置。有响应写入的完成回调只表示该层写入完成，不能推断打印机已解析命令或机械打印完成。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV12withResponseSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-0e1e809f584a36f95939"></a>

### BLEOptions.writeCharacteristic

用于发送打印载荷的 BLE 特征 UUID。

```swift
let writeCharacteristic: UUID
```

该特征位于配置的 `service` 中，须支持 `withResponse` 所选写入方式。启用 Credit 时须与 `dataOut`、`dataFC` 不同。它不是读取状态或确认机械打印完成的接口。

文档 ID：`apple:symbol:s:10PrinterSDK10BLEOptionsV19writeCharacteristic10Foundation4UUIDVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-1bc8aaf9370f29dafae0"></a>

## CancellationContext

<a id="api-1ead2779d2b0900877ae"></a>

### CancellationContext

准备阶段的协作取消上下文。

```swift
final class CancellationContext
```

应用在耗时像素准备中检查取消并尽快返回；该对象不持有可操作的native资源。请求取消或清理后，迟到的准备结果不能重新提交打印。

文档 ID：`apple:symbol:s:10PrinterSDK19CancellationContextC`

符号种类：`swift.class`；访问级别：`public`。

<a id="api-232b8bbccdba27e88d2d"></a>

### CancellationContext.checkCancellation()

在准备函数中检查并抛出取消错误。

```swift
func checkCancellation() throws
```

请求已取消时抛出稳定取消错误，应用应中止准备；Manager仍独立防止迟到准备结果重新准入。

文档 ID：`apple:symbol:s:10PrinterSDK19CancellationContextC05checkC0yyKF`

符号种类：`swift.method`；访问级别：`public`。

<a id="api-92363ea759a1c58b22f1"></a>

### CancellationContext.isCancelled

检查准备是否已被取消。

```swift
var isCancelled: Bool { get }
```

应用在耗时准备的分块边界检查该值并尽早结束；仅用于协作取消，不提供native设备操作。

文档 ID：`apple:symbol:s:10PrinterSDK19CancellationContextC11isCancelledSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-7027c38eacd1e136b879"></a>

## CompletionLevel

<a id="api-b43551f1f08033ae6071"></a>

### CompletionLevel

打印完成证据级别。

```swift
enum CompletionLevel
```

none表示没有打印完成证据，dataSent表示传输完成，deviceConfirmed仅在协议提供明确设备确认时使用。

文档 ID：`apple:symbol:s:10PrinterSDK15CompletionLevelO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-17a429bc3fc72efaac8f"></a>

### CompletionLevel.!=(_:_:)

比较两个只读值是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

由编译器依据类型的Equatable语义合成；比较不访问设备，不创建打印请求。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK15CompletionLevelO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-405f6927c286f89ab363"></a>

### CompletionLevel.dataSent

仅数据发送完成。

```swift
case dataSent
```

该常量的精确名称、原始值或条件位属于本版本契约；完成证据不得被解释为强于实际协议可证明的级别。

文档 ID：`apple:symbol:s:10PrinterSDK15CompletionLevelO8dataSentyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-6b3a08b5989ebfa2d674"></a>

### CompletionLevel.deviceConfirmed

设备明确确认完成。

```swift
case deviceConfirmed
```

该常量的精确名称、原始值或条件位属于本版本契约；完成证据不得被解释为强于实际协议可证明的级别。

文档 ID：`apple:symbol:s:10PrinterSDK15CompletionLevelO15deviceConfirmedyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-a9f99ca50aa642e6ad0c"></a>

### CompletionLevel.hash(into:)

将只读值纳入哈希器。

```swift
func hash(into hasher: inout Hasher)
```

由类型的Hashable语义合成，供集合使用；哈希值不属于持久化协议或native请求标识。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK15CompletionLevelO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-ef6d11e5397b2497f5d4"></a>

### CompletionLevel.hashValue

读取只读值的进程内哈希。

```swift
var hashValue: Int { get }
```

由类型的Hashable语义合成；哈希不保证跨进程稳定，不用于设备身份或持久化请求恢复。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK15CompletionLevelO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-0329693e289810ecd80e"></a>

### CompletionLevel.init(rawValue:)

构造CompletionLevel只读数据。

```swift
init?(rawValue: UInt32)
```

none表示没有打印完成证据，dataSent表示传输完成，deviceConfirmed仅在协议提供明确设备确认时使用。

文档 ID：`apple:symbol:s:10PrinterSDK15CompletionLevelO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-823f156da66c4aac3a9b"></a>

### CompletionLevel.none

没有完成证据。

```swift
case none
```

该常量的精确名称、原始值或条件位属于本版本契约；完成证据不得被解释为强于实际协议可证明的级别。

文档 ID：`apple:symbol:s:10PrinterSDK15CompletionLevelO4noneyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-d94c01c25a5ac00d3af5"></a>

## CpclProfile

<a id="api-f5f076cac6d8b28c330d"></a>

### CpclProfile

不可变的 CPCL 标签几何和作业默认布局配置。

```swift
struct CpclProfile
```

明确描述应用为该设备选择的 DPI、可打印点宽及标签最大高度；不从型号、纸宽或名称推断能力。`form` 和 `xOffsetDots` 只是每次标签作业的默认值，不是设备设置，也不影响 Raw。初始化可拒绝无效参数，但不验证实际硬件。 可作为本次操作参数传入，不需要在连接时提供，也不会改变连接或其他操作。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-7b0add7dea80368c409e"></a>

### CpclProfile.dpi

应用明确配置的打印分辨率。

```swift
let dpi: UInt32
```

单位 dots per inch，由初始化参数保存且大于 0；用于标签横纵几何。未通过设备查询或纸面测量确认，选择正确值是应用和集成方的责任。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV3dpis6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-c36ad2dd66c8d6f10672"></a>

### CpclProfile.form

每个标签作业默认的结束定位策略。

```swift
let form: Bool
```

true 请求下一标签起点结束，false 请求内容结束；没有隐式默认值，初始化时必填。`submitGray8(form: nil)` 取此值，显式传 true/false 只覆盖当前作业。它不设置纸张类型、不做传感器校准，也不影响原始字节发送。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV4formSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-b6168f9850c4606d844d"></a>

### CpclProfile.init(dpi:widthDots:maxLabelHeightDots:form:xOffsetDots:)

校验并保存 CPCL 标签配置及作业默认值。

```swift
init(dpi: UInt32, widthDots: UInt32, maxLabelHeightDots: UInt32, form: Bool, xOffsetDots: UInt32 = 0) throws
```

`dpi` 必须大于 0，单位 dots per inch；`widthDots` 必须大于 0、不超过 7992 且为 8 的整数倍；`maxLabelHeightDots` 必须在 1…65535；两者单位为点。`form` 必填：true 默认请求下一标签起点结束，false 默认在内容结束。`xOffsetDots` 默认 0，须小于 `widthDots`。任一构造条件无效抛 1001；设备初始化还要求 DPI 可表示为正的 Int32，超出时抛 1001；不能将配置构造成功解释为硬件支持。初始化不发送设置或校准命令。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV3dpi9widthDots014maxLabelHeightG04form07xOffsetG0ACs6UInt32V_A2JSbAJtKcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |
| UInt32 | `s:s6UInt32V` |

<a id="api-5a360689d670c9a843a1"></a>

### CpclProfile.maxLabelHeightDots

配置的单张标签最大高度。

```swift
let maxLabelHeightDots: UInt32
```

单位为点，构造接受 1…65535；提交标签的图像高度加尾部留白不得超过此范围。该值由调用方显式指定，构造成功不代表固件已报告或硬件已验证这一长度能力。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV18maxLabelHeightDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-6a75981ab8bbcc72c055"></a>

### CpclProfile.widthDots

配置的设备可打印最大横向点宽。

```swift
let widthDots: UInt32
```

单位为点；构造要求 1…7992 且为 8 的整数倍。它不等于介质毫米宽，也不自动给出居中装纸的原点。标签作业的横向原点、画布和补齐到整字节的图像范围必须共同落在此宽度内。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV9widthDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-2f5362ff7cb84df701bf"></a>

### CpclProfile.xOffsetDots

每个标签作业默认的横向原点。

```swift
let xOffsetDots: UInt32
```

单位为点，构造参数默认 0，须小于配置打印宽度。`submitGray8(originXDots: nil)` 使用此值；每次提交独立保存原点，显式覆盖不会修改 profile。Raw 原样发送，不应用此偏移；SDK 不自动推断居中装纸位置。

文档 ID：`apple:symbol:s:10PrinterSDK11CpclProfileV11xOffsetDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-ca87677d19e3423fb23c"></a>

## CutMode

<a id="api-7d24b7168d872e491e4f"></a>

### CutMode

小票结束时请求的切纸方式。

```swift
enum CutMode
```

传给 `submitReceiptGray8(cut:)`；当前标准 ESC/POS 后端未实现切纸，非 `.none` 请求会在首次 IO 前拒绝，不会静默省略。枚举项是契约选项，不是设备具有切刀的证据。

文档 ID：`apple:symbol:s:10PrinterSDK7CutModeO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-a3eaff6517b3380de212"></a>

### CutMode.!=(_:_:)

比较两个 CutMode 值是否不相等。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift 标准库 `Equatable` 扩展为此类型提供的合成公开成员，不是独立 SDK 实现。参数 `lhs`、`rhs` 为两个值；枚举项不同时返回 true，否则 false。不抛出错误、不执行 IO，也不比较设备状态或诊断文案。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK7CutModeO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-1a062cca2ef105422cca"></a>

### CutMode.full

请求全切。

```swift
case full
```

当前标准后端未实现，提交时在 IO 前以 1004 拒绝；不会降级为不切或半切。目标设备存在切刀的事实需独立证据。

文档 ID：`apple:symbol:s:10PrinterSDK7CutModeO4fullyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-89a8df5865e8f99daaa7"></a>

### CutMode.hash(into:)

把 CutMode 的相等性相关值混入 Hasher。

```swift
func hash(into hasher: inout Hasher)
```

Swift 标准库为原始值枚举提供的合成成员，不是 SDK 实现。`hasher` 为调用方按 `inout` 传入的 `Hasher`，方法更新其状态，没有返回值且不抛出错误。用于 `Hashable` 集合语义，哈希结果不是跨进程稳定序列化格式，不涉及设备 IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK7CutModeO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-08952d6d2d79cdfc7946"></a>

### CutMode.hashValue

获取 CutMode 的进程内哈希值。

```swift
var hashValue: Int { get }
```

Swift 标准库为原始值枚举提供的合成 `Hashable` 成员，不是 SDK 稳定编号。用于集合/字典查找；不要持久化、传输、作为 API 原始值或在不同进程/版本间比较。需要契约数值时使用枚举原始值语义。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK7CutModeO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-b51c659cf65b513b98dd"></a>

### CutMode.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK7CutModeO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-88dbcfe1305b1c57a033"></a>

### CutMode.none

不请求切纸。

```swift
case none
```

为 `submitReceiptGray8` 的默认值；仍可根据 `trailingBlankDots` 与 `finishScope` 发送尾部留白。它不关闭设备，也不承诺自动撕纸位置。

文档 ID：`apple:symbol:s:10PrinterSDK7CutModeO4noneyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-91534bd27acdb707ecb9"></a>

### CutMode.partial

请求半切。

```swift
case partial
```

当前标准后端未实现，提交时在 IO 前以 1004 拒绝；不会降级为全切或不切。枚举项不构成硬件支持。

文档 ID：`apple:symbol:s:10PrinterSDK7CutModeO7partialyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-e7eba043862754865338"></a>

## DiscoveredPrinter

<a id="api-f8569a880ca35c2fbdc3"></a>

### DiscoveredPrinter

一次 BLE 发现窗口中合并后的外设描述。

```swift
struct DiscoveredPrinter
```

由 `PrinterManager.scanBLE` 的完成回调返回的不可变值；相同 `identifier` 的多次广播合并为一项，列表保留首次发现顺序。发现结果仅用于应用选择连接目标，不证明设备是打印机、支持某种协议或已完成硬件验收。没有公开初始化入口，也不包含 CoreBluetooth 原生句柄。

文档 ID：`apple:symbol:s:10PrinterSDK010DiscoveredA0V`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-0af7f41203b681bd0867"></a>

### DiscoveredPrinter.advertisedServices

扫描窗口中观察到的服务 UUID 字符串集合。

```swift
let advertisedServices: [String]
```

按首次出现顺序合并广播服务，忽略首尾空白和大小写造成的重复。它只表示广播信息，并不是连接后完整的 GATT 服务清单；空数组也不证明目标缺少所需服务。

文档 ID：`apple:symbol:s:10PrinterSDK010DiscoveredA0V18advertisedServicesSaySSGvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-33036fc5f14ef3b9bca2"></a>

### DiscoveredPrinter.identifier

CoreBluetooth 为外设提供的不透明标识符。

```swift
let identifier: UUID
```

传给 `PrinterManager.connect(bleIdentifier:options:timeoutMilliseconds:completion:onDisconnected:)` 的选择结果。它是 iOS 外设 UUID，不是 Android 蓝牙 MAC 地址，也不是跨平台设备序列号；连接前目标须已被 CoreBluetooth 识别。应用应把设备身份诊断按隐私要求处理。

文档 ID：`apple:symbol:s:10PrinterSDK010DiscoveredA0V10identifier10Foundation4UUIDVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UUID | `s:10Foundation4UUIDV` |

<a id="api-a00f5310f1770af3ec9e"></a>

### DiscoveredPrinter.name

广播或平台提供的可选外设名称。

```swift
let name: String?
```

名称会移除首尾空白；没有可用名称时为 `nil`。相同外设的后续有效名称更新该值，没有新名称时保留此前值。名称可以重复或变化，不用于判断协议、型号或硬件支持。

文档 ID：`apple:symbol:s:10PrinterSDK010DiscoveredA0V4nameSSSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-2a8c15042b6af9aba7d5"></a>

### DiscoveredPrinter.rssi

最近一次发现事件携带的接收信号强度。

```swift
let rssi: Int
```

单位为 dBm，直接保留平台最近读数；CoreBluetooth 以 `127` 表示 RSSI 不可用。不要把 `127` 当作有效信号强度，也不要由 RSSI 推断打印机就绪或连接稳定。

文档 ID：`apple:symbol:s:10PrinterSDK010DiscoveredA0V4rssiSivp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-63244971bb8665f0438c"></a>

## FeatureSupport

<a id="api-1e75e58e75779acbd3b1"></a>

### FeatureSupport

区分软件实现、设备支持和证据来源的功能描述。

```swift
struct FeatureSupport
```

由 `PrinterCapabilities.feature` 返回，无公开初始化入口。所有字段只读，读值不进行 IO；各字段是底层契约数值，避免把非零实现当作硬件认证。当前显式 BLE 配置可以已实现但设备支持未知。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-c4a446b320b944bde7b4"></a>

### FeatureSupport.!=(_:_:)

编译器提供的值不等比较。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

按该值类型的Equatable语义比较，返回布尔值，不执行设备IO。比较相同状态或结果不代表设备当前在线或机械打印完成。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK14FeatureSupportV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-583fbacd94ea963788cc"></a>

### FeatureSupport.deviceSupport

设备支持的三态数值。

```swift
let deviceSupport: UInt32
```

0 未知，1 明确不支持，2 明确支持。显式配置当前仍可能为 0，即使 SDK 已实现相关路径也不能提升为支持。`isSupported` 只有在 `implementation != 0` 且此值为 2 时为 true。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV06deviceD0s6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-d96ba7fde3cdfcaa76c8"></a>

### FeatureSupport.evidence

支持结论的来源标志位。

```swift
let evidence: UInt32
```

1 为配置声明，2 为设备报告，4 为硬件验证；标志可按位组合。当前显式 BLE 配置的配置声明不等同设备读回或真机验证，应用不得由预设名、广播名或构造成功补造证据。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV8evidences6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-1219985c6bef05a31c21"></a>

### FeatureSupport.implementation

SDK 对该功能采用的实现方式。

```swift
let implementation: UInt32
```

数值 0 表示未实现，1 表示协议原生实现，2 表示主机渲染。`isImplemented` 仅判断是否非零。它描述软件路径，不证明固件支持或硬件验收通过；未知未来数值应保留并谨慎处理。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV14implementations6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-5e4c669bce7781a5a963"></a>

### FeatureSupport.isImplemented

SDK 是否提供非零的实现方式。

```swift
var isImplemented: Bool { get }
```

当前判断等同 `implementation != 0`，不读取设备、不发送 IO。true 只证明存在软件实现；设备支持未知、实际参数不兼容或权限/连接失败仍可能导致调用失败。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV13isImplementedSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-49ce3c417a36013b07c6"></a>

### FeatureSupport.isSupported

是否同时具备 SDK 实现和已知设备支持。

```swift
var isSupported: Bool { get }
```

当前判断等同 `isImplemented && deviceSupport == 2`，不会把未知支持视为 true。false 包含未实现、未知和明确不支持多种情形，需结合原始字段区分；true 也不能替代参数校验或逐次操作结果。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV11isSupportedSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-cec17b5e240f3a9421b6"></a>

### FeatureSupport.knownFields

功能knownFields位集合。

```swift
let knownFields: UInt32
```

VALUES_KNOWN=1、REQUIRED_FIELDS_KNOWN=2、SUPPORTED_FIELDS_KNOWN=4，先查此位再解释对应字段，零不等于空集合。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV11knownFieldss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-4988ef01e31d9294c5c9"></a>

### FeatureSupport.requiredFields

功能requiredFields位集合。

```swift
let requiredFields: UInt32
```

MEDIA场景的必需字段mask；仅knownFields的REQUIRED_FIELDS_KNOWN有效时可解释。当前CPCL介质设置只支持tracking。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV14requiredFieldss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-c11ea825ce32570601d9"></a>

### FeatureSupport.supportedFields

功能supportedFields位集合。

```swift
let supportedFields: UInt32
```

MEDIA场景可接受的字段mask；仅SUPPORTED_FIELDS_KNOWN有效时可解释。未知不能推断全部可用。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV15supportedFieldss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-331e4f49e6471771ee44"></a>

### FeatureSupport.supportedValues

功能supportedValues位集合。

```swift
let supportedValues: UInt32
```

功能允许的枚举值mask，仅VALUES_KNOWN有效时可解释；CUT按FULL/PARTIAL位，IMAGE按算法值，MEDIA按tracking值。实现与硬件支持仍分开。

文档 ID：`apple:symbol:s:10PrinterSDK14FeatureSupportV15supportedValuess6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-8da32930540a97e6bfd9"></a>

## FinishScope

<a id="api-e4878aa730e1148172be"></a>

### FinishScope

小票结束留白和切纸请求的执行范围。

```swift
enum FinishScope
```

配合 `submitReceiptGray8(finishScope:)` 使用；范围影响整单长度预算与结束动作次数，不改变份数。不支持的策略组合在 IO 前明确拒绝，不能把多份拆为循环入队来替代一个原子队列条目。

文档 ID：`apple:symbol:s:10PrinterSDK11FinishScopeO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-176630565f0c8734e6d9"></a>

### FinishScope.!=(_:_:)

比较两个 FinishScope 值是否不相等。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift 标准库 `Equatable` 扩展为此类型提供的合成公开成员，不是独立 SDK 实现。参数 `lhs`、`rhs` 为两个值；枚举项不同时返回 true，否则 false。不抛出错误、不执行 IO，也不比较设备状态或诊断文案。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK11FinishScopeO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-139fcb246390b5ee8234"></a>

### FinishScope.eachCopy

每份内容后执行收尾留白及切纸请求。

```swift
case eachCopy
```

为默认值；整单预算包含每一份的 `trailingBlankDots`。同一操作包含所有份数，取消或失败后不自动补打剩余份。切纸仍受独立能力限制。

文档 ID：`apple:symbol:s:10PrinterSDK11FinishScopeO8eachCopyyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-289057185bc6f71d3ce4"></a>

### FinishScope.endOfJob

全部份数之后执行一次收尾动作。

```swift
case endOfJob
```

整单预算仅累加一次结束留白，但当前标准 ESC/POS 后端仅支持 `.eachCopy`，本选项即使只有一份也会在 IO 前抛 1004，不会静默改为逐份。

文档 ID：`apple:symbol:s:10PrinterSDK11FinishScopeO8endOfJobyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-a23c935c1ac70f053865"></a>

### FinishScope.hash(into:)

把 FinishScope 的相等性相关值混入 Hasher。

```swift
func hash(into hasher: inout Hasher)
```

Swift 标准库为原始值枚举提供的合成成员，不是 SDK 实现。`hasher` 为调用方按 `inout` 传入的 `Hasher`，方法更新其状态，没有返回值且不抛出错误。用于 `Hashable` 集合语义，哈希结果不是跨进程稳定序列化格式，不涉及设备 IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK11FinishScopeO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-e5ff4abeaf1932e95561"></a>

### FinishScope.hashValue

获取 FinishScope 的进程内哈希值。

```swift
var hashValue: Int { get }
```

Swift 标准库为原始值枚举提供的合成 `Hashable` 成员，不是 SDK 稳定编号。用于集合/字典查找；不要持久化、传输、作为 API 原始值或在不同进程/版本间比较。需要契约数值时使用枚举原始值语义。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK11FinishScopeO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-747ce5e305b31ea61b90"></a>

### FinishScope.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK11FinishScopeO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-41361c67b37b815a38ae"></a>

## ImageAlgorithm

<a id="api-eb40e0bf1994e99d4591"></a>

### ImageAlgorithm

图像二值化或抖动算法。

```swift
enum ImageAlgorithm
```

threshold=0、floydSteinberg=1、bayer4x4=2、bayer8x8=3；算法属于图像处理，不是打印机协议或硬件能力。

文档 ID：`apple:symbol:s:10PrinterSDK14ImageAlgorithmO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-8d19f4fbd2529fbb7278"></a>

### ImageAlgorithm.!=(_:_:)

编译器提供的值不等比较。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

按该值类型的Equatable语义比较，返回布尔值，不执行设备IO。比较相同状态或结果不代表设备当前在线或机械打印完成。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK14ImageAlgorithmO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-d6ec14ad4f4093b37d35"></a>

### ImageAlgorithm.bayer4x4

选择bayer4x4图像算法。

```swift
case bayer4x4
```

4×4 Bayer有序抖动。处理在SDK图像流水线执行，不发送型号专属命令。

文档 ID：`apple:symbol:s:10PrinterSDK14ImageAlgorithmO8bayer4x4yA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-6945005b41984b7b4eeb"></a>

### ImageAlgorithm.bayer8x8

选择bayer8x8图像算法。

```swift
case bayer8x8
```

8×8 Bayer有序抖动。处理在SDK图像流水线执行，不发送型号专属命令。

文档 ID：`apple:symbol:s:10PrinterSDK14ImageAlgorithmO8bayer8x8yA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-be0ae4ffc2dd3677f1f6"></a>

### ImageAlgorithm.floydSteinberg

选择floydSteinberg图像算法。

```swift
case floydSteinberg
```

Floyd–Steinberg误差扩散。处理在SDK图像流水线执行，不发送型号专属命令。

文档 ID：`apple:symbol:s:10PrinterSDK14ImageAlgorithmO14floydSteinbergyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-456c05d0e75fa3d9e20f"></a>

### ImageAlgorithm.hash(into:)

编译器提供的枚举散列。

```swift
func hash(into hasher: inout Hasher)
```

用于Swift集合与字典，按当前枚举raw值生成；散列不稳定，不能持久化为协议值、设备身份或跨进程标识，不执行IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK14ImageAlgorithmO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-3363ed8986a4951eb034"></a>

### ImageAlgorithm.hashValue

编译器提供的枚举散列。

```swift
var hashValue: Int { get }
```

用于Swift集合与字典，按当前枚举raw值生成；散列不稳定，不能持久化为协议值、设备身份或跨进程标识，不执行IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK14ImageAlgorithmO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-f728255c350011718d01"></a>

### ImageAlgorithm.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK14ImageAlgorithmO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-a85d93817ab96637e0b3"></a>

### ImageAlgorithm.threshold

选择threshold图像算法。

```swift
case threshold
```

阈值二值化，默认threshold=128。处理在SDK图像流水线执行，不发送型号专属命令。

文档 ID：`apple:symbol:s:10PrinterSDK14ImageAlgorithmO9thresholdyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-9cd007436b5a242686f9"></a>

## LabelJobOptions

<a id="api-34d851c149bbdf909c5c"></a>

### LabelJobOptions

标签作业的不可变布局选项。

```swift
struct LabelJobOptions
```

只保存参数，Manager构建和提交进行完整校验；宽高和DPI大于零，copies为1..100，原点非负，不自动裁剪。页面高度是一份输出，form描述本次结束位置。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-408f66dc4d26cc013ed6"></a>

### LabelJobOptions.copies

份数，默认1、范围1..100。

```swift
let copies: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV6copiess6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-0826e3485b67092d8ac7"></a>

### LabelJobOptions.dpi

标签横纵DPI。

```swift
let dpi: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV3dpis6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-a5681b14608ca076bac0"></a>

### LabelJobOptions.form

true请求下一标签起点结束；false在内容结束。

```swift
let form: Bool
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV4formSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-e6d70734b080512e93ec"></a>

### LabelJobOptions.heightDots

每份标签声明高度（点）。

```swift
let heightDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV10heightDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-4b761d5230ae97b83116"></a>

### LabelJobOptions.init(widthDots:heightDots:dpi:originXDots:originYDots:copies:form:)

保存LabelJobOptions的不可变作业参数。

```swift
init(widthDots: UInt32, heightDots: UInt32, dpi: UInt32, originXDots: Int32 = 0, originYDots: Int32 = 0, copies: UInt32 = 1, form: Bool = false)
```

只保存参数，Manager构建和提交进行完整校验；宽高和DPI大于零，copies为1..100，原点非负，不自动裁剪。页面高度是一份输出，form描述本次结束位置。 此初始化不执行IO，也不提前证明参数或硬件支持；实际校验在Manager准备后的native构建与准入进行。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV9widthDots06heightG03dpi11originXDots0J5YDots6copies4formACs6UInt32V_A2Ls5Int32VAnLSbtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |
| Int32 | `s:s5Int32V` |
| UInt32 | `s:s6UInt32V` |

<a id="api-8f8763f81d12828bc071"></a>

### LabelJobOptions.originXDots

非负横向原点（点）。

```swift
let originXDots: Int32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV11originXDotss5Int32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-33545797ae4117bfce58"></a>

### LabelJobOptions.originYDots

非负纵向原点（点）。

```swift
let originYDots: Int32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV11originYDotss5Int32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-cca1f2750f44dc7b35f8"></a>

### LabelJobOptions.widthDots

标签画布宽度（点）。

```swift
let widthDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK15LabelJobOptionsV9widthDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-c09da0bc38ed43e7aef2"></a>

## M90Profile

<a id="api-36e6668b567033ab4cff"></a>

### M90Profile

提供依据 M90 固件 V1.2 文档的 BLE 配置工厂。

```swift
enum M90Profile
```

该枚举用作静态命名空间，没有可供创建实例的公开枚举项。当前只提供 BLE 服务/写入/Credit 特征预设，DPI、点宽、标签高度及 FORM 仍由应用明确提供。选择此预设不表示 M90 或任意硬件已通过本 SDK 验收。

文档 ID：`apple:symbol:s:10PrinterSDK10M90ProfileO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-5f602b8f4d618a37f4f0"></a>

### M90Profile.bleOptions(maxWriteBytes:)

生成 M90 文档 V1.2 的无响应写入和 Credit 配置。

```swift
static func bleOptions(maxWriteBytes: Int = 512) throws -> BLEOptions
```

`maxWriteBytes` 默认 `512`，单位字节，接受 1…512，否则抛 1001。返回服务 FF00、写入 FF02、Data Out FF01、Data FC FF03 对应的标准 Bluetooth Base UUID，并启用无响应写入及 Credit；完整 UUID 形式为 `0000xxxx-0000-1000-8000-00805F9B34FB`。实际发送包长仍由系统写入容量、固件公告与应用上限共同限制。工厂不进行扫描、连接或 IO，不预置固定初始 Credit，不确认机械打印能力。

文档 ID：`apple:symbol:s:10PrinterSDK10M90ProfileO10bleOptions13maxWriteBytesAA10BLEOptionsVSi_tKFZ`

符号种类：`swift.type.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| BLEOptions | `s:10PrinterSDK10BLEOptionsV` |
| Int | `s:Si` |

<a id="api-625d7c79302095211bcb"></a>

## ManagerOutcome

<a id="api-3c6f85967ca0141b6cfb"></a>

### ManagerOutcome

请求的终态分类。

```swift
enum ManagerOutcome
```

success、failure和cancelled分别表示成功、失败及取消；同时检查稳定code和输出证据以决定应用提示。

文档 ID：`apple:symbol:s:10PrinterSDK14ManagerOutcomeO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-e03191c4ce4d20764463"></a>

### ManagerOutcome.!=(_:_:)

比较两个只读值是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

由编译器依据类型的Equatable语义合成；比较不访问设备，不创建打印请求。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK14ManagerOutcomeO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-e0724738dd1226b09583"></a>

### ManagerOutcome.cancelled

请求取消。

```swift
case cancelled
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`apple:symbol:s:10PrinterSDK14ManagerOutcomeO9cancelledyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-acb0001b23a99a7238a0"></a>

### ManagerOutcome.failure

请求失败。

```swift
case failure
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`apple:symbol:s:10PrinterSDK14ManagerOutcomeO7failureyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-863a858c6e9dc3938409"></a>

### ManagerOutcome.success

请求成功。

```swift
case success
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`apple:symbol:s:10PrinterSDK14ManagerOutcomeO7successyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-d5c711f55a02b7703b81"></a>

## ManagerResult

<a id="api-d56d334dd7a53c7814e9"></a>

### ManagerResult

单次请求的不可变完成结果。

```swift
struct ManagerResult<Value> where Value : Sendable
```

包含请求标识、成功/失败/取消、稳定错误码、辅助消息、完成证据、可能已输出标记及可选业务值。主线程回调恰好完成一次；dataSent仅证明数据发送完成，不证明纸张已打印。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV`

符号种类：`swift.struct`；访问级别：`public`。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Value","rhs":"Sendable","rhsPrecise":"s:s8SendableP"}],"parameters":[{"depth":0,"index":0,"name":"Value"}]}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Sendable | `s:s8SendableP` |

<a id="api-cb62e9deec0766a167ff"></a>

### ManagerResult.code

稳定SDK错误码。

```swift
let code: Int32
```

0表示成功，其他值按SDK错误契约解释；不要依赖可读message进行程序分支。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV4codes5Int32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-82c678c43ee69cf97faf"></a>

### ManagerResult.completion

打印完成证据级别。

```swift
let completion: CompletionLevel
```

none表示没有打印完成证据，dataSent表示传输完成，deviceConfirmed仅在协议提供明确设备确认时使用。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV10completionAA15CompletionLevelOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CompletionLevel | `s:10PrinterSDK15CompletionLevelO` |

<a id="api-f78e30aca271cd8f90c4"></a>

### ManagerResult.isSuccess

是否属于成功终态。

```swift
var isSuccess: Bool { get }
```

按outcome == success计算；仍需单独读取completion分辨数据发送与设备确认。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV9isSuccessSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-b6ff4bc88b3b1789c28e"></a>

### ManagerResult.message

可读的辅助错误消息。

```swift
let message: String
```

用于集成诊断和界面提示；程序逻辑以稳定code为主，不解析该文本。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV7messageSSvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-7e6703d4eaf50b7c6138"></a>

### ManagerResult.outcome

请求成功、失败或取消的分类。

```swift
let outcome: ManagerOutcome
```

与稳定code及完成证据一起读取；取消或失败不自动表示设备没有产生部分输出。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV7outcomeAA0C7OutcomeOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| ManagerOutcome | `s:10PrinterSDK14ManagerOutcomeO` |

<a id="api-8884170bc72ef1c2ea76"></a>

### ManagerResult.outputMayHaveOccurred

是否可能已发送了不可撤回的输出。

```swift
let outputMayHaveOccurred: Bool
```

true时设备可能已经收到部分命令或像素；应用不得据此自动重试或重放，需自行决定提示和后续人工操作。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV21outputMayHaveOccurredSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-c9a074ae453b91eb03fe"></a>

### ManagerResult.requestID

请求标识。

```swift
let requestID: RequestID
```

仅能由创建该标识的Manager识别；用于关联完成结果和发送取消意图。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV9requestIDAA07RequestF0Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| RequestID | `s:10PrinterSDK9RequestIDV` |

<a id="api-3593583350ae830705d0"></a>

### ManagerResult.value

成功结果的可选业务值。

```swift
let value: Value?
```

用于设备列表、能力、身份和状态查询；没有返回值的请求为Void/null，失败时不要假定业务值存在。

文档 ID：`apple:symbol:s:10PrinterSDK13ManagerResultV5valuexSgvp`

符号种类：`swift.property`；访问级别：`public`。

<a id="api-e9f6609ce460a51cc89f"></a>

## MediaMode

<a id="api-16bbe8e3b5e45eac13b0"></a>

### MediaMode

与打印语言独立的介质跟踪模式。

```swift
enum MediaMode
```

传给 `setMediaMode`；当前只有 CPCL 标签设备提供对应编码，不能因为枚举项存在就推断其他后端或固件支持。设置发送不确认已应用，不设置标签图像尺寸或执行传感器校准。

文档 ID：`apple:symbol:s:10PrinterSDK9MediaModeO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-2b58768b3d9fd4906ea0"></a>

### MediaMode.!=(_:_:)

比较两个 MediaMode 值是否不相等。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift 标准库 `Equatable` 扩展为此类型提供的合成公开成员，不是独立 SDK 实现。参数 `lhs`、`rhs` 为两个值；枚举项不同时返回 true，否则 false。不抛出错误、不执行 IO，也不比较设备状态或诊断文案。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK9MediaModeO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-453392472f7fd260ebae"></a>

### MediaMode.blackMark

请求按黑标跟踪介质。

```swift
case blackMark
```

用于实际具备相应传感与固件支持的黑标纸；不设置标记长度/偏移，不执行校准或读回。发送成功不能证明检测到黑标。

文档 ID：`apple:symbol:s:10PrinterSDK9MediaModeO9blackMarkyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-a395d1df3275fc067674"></a>

### MediaMode.continuous

请求连续纸介质模式。

```swift
case continuous
```

不依赖间隙/黑标定位的模式设置请求；它与标签作业的 `form` 结束策略、画布尺寸是独立参数，不自动改写已有作业或推断纸长。

文档 ID：`apple:symbol:s:10PrinterSDK9MediaModeO10continuousyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-65190e7c3660ac4b065e"></a>

### MediaMode.gap

请求按间隙跟踪介质。

```swift
case gap
```

用于具有相应传感与固件支持的标签介质；不设置间隙毫米尺寸，不执行校准或验证装纸。是否实际应用需设备/硬件证据。

文档 ID：`apple:symbol:s:10PrinterSDK9MediaModeO3gapyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-aee116a2c72751661c7a"></a>

### MediaMode.hash(into:)

把 MediaMode 的相等性相关值混入 Hasher。

```swift
func hash(into hasher: inout Hasher)
```

Swift 标准库为原始值枚举提供的合成成员，不是 SDK 实现。`hasher` 为调用方按 `inout` 传入的 `Hasher`，方法更新其状态，没有返回值且不抛出错误。用于 `Hashable` 集合语义，哈希结果不是跨进程稳定序列化格式，不涉及设备 IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK9MediaModeO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-af5ef87066699f13cab7"></a>

### MediaMode.hashValue

获取 MediaMode 的进程内哈希值。

```swift
var hashValue: Int { get }
```

Swift 标准库为原始值枚举提供的合成 `Hashable` 成员，不是 SDK 稳定编号。用于集合/字典查找；不要持久化、传输、作为 API 原始值或在不同进程/版本间比较。需要契约数值时使用枚举原始值语义。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK9MediaModeO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-ca7c6cc262ae54bb1700"></a>

### MediaMode.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK9MediaModeO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-443778f8722036fd1c08"></a>

## MediaPersistencePolicy

<a id="api-96adc8ca41123b93cf2a"></a>

### MediaPersistencePolicy

介质设置的持久化许可。

```swift
enum MediaPersistencePolicy
```

volatileOnly要求仅临时设置；allowPersistent仅允许明确profile已支持的持久化行为，不新增硬件能力或自动执行持久写入。

文档 ID：`apple:symbol:s:10PrinterSDK22MediaPersistencePolicyO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-67310e80954e5f9fbbd8"></a>

### MediaPersistencePolicy.!=(_:_:)

比较两个只读值是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

由编译器依据类型的Equatable语义合成；比较不访问设备，不创建打印请求。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK22MediaPersistencePolicyO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-9547492309a59c1bbcce"></a>

### MediaPersistencePolicy.allowPersistent

允许明确支持的持久化介质设置。

```swift
case allowPersistent
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`apple:symbol:s:10PrinterSDK22MediaPersistencePolicyO15allowPersistentyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-16d45508326bf388964f"></a>

### MediaPersistencePolicy.hash(into:)

将只读值纳入哈希器。

```swift
func hash(into hasher: inout Hasher)
```

由类型的Hashable语义合成，供集合使用；哈希值不属于持久化协议或native请求标识。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK22MediaPersistencePolicyO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-bd93d1a16820c119d534"></a>

### MediaPersistencePolicy.hashValue

读取只读值的进程内哈希。

```swift
var hashValue: Int { get }
```

由类型的Hashable语义合成；哈希不保证跨进程稳定，不用于设备身份或持久化请求恢复。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK22MediaPersistencePolicyO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-ebb59f9a2b2a09ee3581"></a>

### MediaPersistencePolicy.init(rawValue:)

构造MediaPersistencePolicy只读数据。

```swift
init?(rawValue: UInt32)
```

volatileOnly要求仅临时设置；allowPersistent仅允许明确profile已支持的持久化行为，不新增硬件能力或自动执行持久写入。

文档 ID：`apple:symbol:s:10PrinterSDK22MediaPersistencePolicyO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-b44950f897b1364c8141"></a>

### MediaPersistencePolicy.volatileOnly

只允许临时介质设置。

```swift
case volatileOnly
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`apple:symbol:s:10PrinterSDK22MediaPersistencePolicyO12volatileOnlyyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-623f02309548c44d0ebb"></a>

## MediaRequirement

<a id="api-6ab82cb7819671ca0578"></a>

### MediaRequirement

显式介质前置要求。

```swift
struct MediaRequirement
```

设为nil表示没有前置要求；提供值时tracking必须存在，其他nil字段未指定。只允许已有发送证据或明确读回；当前仅CPCL tracking+allowLastSent可提交，其他字段/读回要求1004拒绝且零IO。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-bc320e05f07d87edf3d4"></a>

### MediaRequirement.gapLengthMicrometers

可选间隙长度（微米），仅gap模式。

```swift
let gapLengthMicrometers: UInt32?
```

nil表示未指定，不能当作设备报告；存在的宽度/长度须为正并与tracking匹配。当前后端只支持tracking及allowLastSent，其他要求明确拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV20gapLengthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-c1b0df34326b9632e0a7"></a>

### MediaRequirement.init(tracking:widthMicrometers:labelLengthMicrometers:gapLengthMicrometers:markLengthMicrometers:markOffsetMicrometers:verification:)

保存MediaRequirement的不可变作业参数。

```swift
init(tracking: MediaMode? = nil, widthMicrometers: UInt32? = nil, labelLengthMicrometers: UInt32? = nil, gapLengthMicrometers: UInt32? = nil, markLengthMicrometers: UInt32? = nil, markOffsetMicrometers: Int32? = nil, verification: MediaVerificationPolicy = .allowLastSent)
```

设为nil表示没有前置要求；提供值时tracking必须存在，其他nil字段未指定。只允许已有发送证据或明确读回；当前仅CPCL tracking+allowLastSent可提交，其他字段/读回要求1004拒绝且零IO。 此初始化不执行IO，也不提前证明参数或硬件支持；实际校验在Manager准备后的native构建与准入进行。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV8tracking16widthMicrometers011labelLengthG003gapiG004markiG00k6OffsetG012verificationAcA0C4ModeOSg_s6UInt32VSgA3Ps5Int32VSgAA0C18VerificationPolicyOtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |
| MediaMode | `s:10PrinterSDK9MediaModeO` |
| MediaVerificationPolicy | `s:10PrinterSDK23MediaVerificationPolicyO` |
| UInt32 | `s:s6UInt32V` |

<a id="api-57f722d1d95fdba39e10"></a>

### MediaRequirement.labelLengthMicrometers

可选标签长度（微米）。

```swift
let labelLengthMicrometers: UInt32?
```

nil表示未指定，不能当作设备报告；存在的宽度/长度须为正并与tracking匹配。当前后端只支持tracking及allowLastSent，其他要求明确拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV22labelLengthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-864e525223aa04aa5fba"></a>

### MediaRequirement.markLengthMicrometers

可选黑标长度（微米），仅blackMark模式。

```swift
let markLengthMicrometers: UInt32?
```

nil表示未指定，不能当作设备报告；存在的宽度/长度须为正并与tracking匹配。当前后端只支持tracking及allowLastSent，其他要求明确拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV21markLengthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-9b19f3b49b288586aaed"></a>

### MediaRequirement.markOffsetMicrometers

可选黑标偏移（微米），仅blackMark模式。

```swift
let markOffsetMicrometers: Int32?
```

nil表示未指定，不能当作设备报告；存在的宽度/长度须为正并与tracking匹配。当前后端只支持tracking及allowLastSent，其他要求明确拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV21markOffsetMicrometerss5Int32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-25bd0ab9dda5cd9b9143"></a>

### MediaRequirement.tracking

必需的介质跟踪模式。

```swift
let tracking: MediaMode?
```

nil表示未指定，不能当作设备报告；存在的宽度/长度须为正并与tracking匹配。当前后端只支持tracking及allowLastSent，其他要求明确拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV8trackingAA0C4ModeOSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MediaMode | `s:10PrinterSDK9MediaModeO` |

<a id="api-2b13f60eeae1024f115a"></a>

### MediaRequirement.verification

介质证据策略，默认allowLastSent。

```swift
let verification: MediaVerificationPolicy
```

allowLastSent只使用当前协议最近成功发送的介质记录，不是读回；requireReadback当前不支持，提交前1004拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV12verificationAA0C18VerificationPolicyOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MediaVerificationPolicy | `s:10PrinterSDK23MediaVerificationPolicyO` |

<a id="api-f14b9a4722aaa2d3a61f"></a>

### MediaRequirement.widthMicrometers

可选介质宽度（微米）。

```swift
let widthMicrometers: UInt32?
```

nil表示未指定，不能当作设备报告；存在的宽度/长度须为正并与tracking匹配。当前后端只支持tracking及allowLastSent，其他要求明确拒绝。

文档 ID：`apple:symbol:s:10PrinterSDK16MediaRequirementV16widthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-a2a66f93bc7ef29553ce"></a>

## MediaSettings

<a id="api-a36e11d072d00fccc51b"></a>

### MediaSettings

完整的只读介质请求。

```swift
struct MediaSettings
```

可选字段描述跟踪、宽度、标签长度、间隙、黑标及偏移，并显式给出持久化策略。字段存在不表示设备支持；当前明确profile只实现已确认的tracking能力，其他字段经准入返回Unsupported。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-e77c9e28520d52015d59"></a>

### MediaSettings.gapLengthMicrometers

可选间隙长度。

```swift
let gapLengthMicrometers: UInt32?
```

单位为微米；nil表示不设置，数值在请求准入时校验。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV20gapLengthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-9b9f4a97383f54daa816"></a>

### MediaSettings.init(tracking:widthMicrometers:labelLengthMicrometers:gapLengthMicrometers:markLengthMicrometers:markOffsetMicrometers:persistence:)

构造MediaSettings只读数据。

```swift
init(tracking: MediaMode? = nil, widthMicrometers: UInt32? = nil, labelLengthMicrometers: UInt32? = nil, gapLengthMicrometers: UInt32? = nil, markLengthMicrometers: UInt32? = nil, markOffsetMicrometers: Int32? = nil, persistence: MediaPersistencePolicy = .volatileOnly)
```

可选字段描述跟踪、宽度、标签长度、间隙、黑标及偏移，并显式给出持久化策略。字段存在不表示设备支持；当前明确profile只实现已确认的tracking能力，其他字段经准入返回Unsupported。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV8tracking16widthMicrometers011labelLengthG003gapiG004markiG00k6OffsetG011persistenceAcA0C4ModeOSg_s6UInt32VSgA3Ps5Int32VSgAA0C17PersistencePolicyOtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |
| MediaMode | `s:10PrinterSDK9MediaModeO` |
| MediaPersistencePolicy | `s:10PrinterSDK22MediaPersistencePolicyO` |
| UInt32 | `s:s6UInt32V` |

<a id="api-d4efdf90e7956710dd4a"></a>

### MediaSettings.labelLengthMicrometers

可选标签长度。

```swift
let labelLengthMicrometers: UInt32?
```

单位为微米；nil表示不设置，不支持的字段通过完成回调返回Unsupported。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV22labelLengthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-89ff0770d5c642a64c7d"></a>

### MediaSettings.markLengthMicrometers

可选黑标长度。

```swift
let markLengthMicrometers: UInt32?
```

单位为微米；nil表示不设置，数值和设备支持在请求准入时校验。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV21markLengthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-1d0f42021625e6395401"></a>

### MediaSettings.markOffsetMicrometers

可选黑标有符号偏移。

```swift
let markOffsetMicrometers: Int32?
```

单位为微米；nil表示不设置，不支持的字段通过完成回调返回Unsupported。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV21markOffsetMicrometerss5Int32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-9ccf1c6c0048384c6459"></a>

### MediaSettings.persistence

介质持久化许可。

```swift
let persistence: MediaPersistencePolicy
```

默认volatileOnly；allowPersistent仅对profile明确支持的持久化行为授权，不保证硬件会接受持久配置。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV11persistenceAA0C17PersistencePolicyOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MediaPersistencePolicy | `s:10PrinterSDK22MediaPersistencePolicyO` |

<a id="api-d1771b3bfb5d94837818"></a>

### MediaSettings.tracking

可选介质跟踪模式。

```swift
let tracking: MediaMode?
```

nil表示本请求不设置该字段；当前可用能力以profile声明和准入结果为准。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV8trackingAA0C4ModeOSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MediaMode | `s:10PrinterSDK9MediaModeO` |

<a id="api-d81e8df1c83adcbc3ccb"></a>

### MediaSettings.widthMicrometers

可选介质宽度。

```swift
let widthMicrometers: UInt32?
```

单位为微米；nil表示不设置，字段存在不代表当前profile已实现此能力。

文档 ID：`apple:symbol:s:10PrinterSDK13MediaSettingsV16widthMicrometerss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-afcd3a74fc08e909f85d"></a>

## MediaVerificationPolicy

<a id="api-e07fc2708245563b7f0b"></a>

### MediaVerificationPolicy

介质前置条件的证据选择。

```swift
enum MediaVerificationPolicy
```

allowLastSent=1允许SDK已成功发送的记录；requireReadback=2要求受支持的设备读回。策略不触发自动设置或猜测状态。

文档 ID：`apple:symbol:s:10PrinterSDK23MediaVerificationPolicyO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-1cd83842b55b9ab5d029"></a>

### MediaVerificationPolicy.!=(_:_:)

编译器提供的值不等比较。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

按该值类型的Equatable语义比较，返回布尔值，不执行设备IO。比较相同状态或结果不代表设备当前在线或机械打印完成。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK23MediaVerificationPolicyO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-aeab64eaf6f4a90e1bbb"></a>

### MediaVerificationPolicy.allowLastSent

允许匹配最近发送的介质记录。

```swift
case allowLastSent
```

只描述本次协议对应的SDK缓存证据，不证明固件实际配置，不能跨协议借用记录。

文档 ID：`apple:symbol:s:10PrinterSDK23MediaVerificationPolicyO13allowLastSentyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-49891c4cb429ecf760e9"></a>

### MediaVerificationPolicy.hash(into:)

编译器提供的枚举散列。

```swift
func hash(into hasher: inout Hasher)
```

用于Swift集合与字典，按当前枚举raw值生成；散列不稳定，不能持久化为协议值、设备身份或跨进程标识，不执行IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK23MediaVerificationPolicyO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-ad19059c6d7670b6ce57"></a>

### MediaVerificationPolicy.hashValue

编译器提供的枚举散列。

```swift
var hashValue: Int { get }
```

用于Swift集合与字典，按当前枚举raw值生成；散列不稳定，不能持久化为协议值、设备身份或跨进程标识，不执行IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK23MediaVerificationPolicyO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-1a1a37ae0f2ef3ee9b57"></a>

### MediaVerificationPolicy.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK23MediaVerificationPolicyO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-7bacf537b3274c2275ea"></a>

### MediaVerificationPolicy.requireReadback

要求设备读回介质证据。

```swift
case requireReadback
```

当前标准后端未验证介质读回，提交返回1004且零IO；不能自动降级为最近发送记录。

文档 ID：`apple:symbol:s:10PrinterSDK23MediaVerificationPolicyO15requireReadbackyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-145004af19a837676c99"></a>

## PixelFormat

<a id="api-ef118e5e76594eff95ed"></a>

### PixelFormat

紧密排列的源像素格式。

```swift
enum PixelFormat
```

GRAY8=1、RGB24=2、RGBA32=3；行内和行间均无padding，Data长度必须恰等于width*height*每像素字节数。平台图像须先转换为这些字节格式。

文档 ID：`apple:symbol:s:10PrinterSDK11PixelFormatO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-4e4eaf4a6a6274b5ee13"></a>

### PixelFormat.!=(_:_:)

编译器提供的值不等比较。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

按该值类型的Equatable语义比较，返回布尔值，不执行设备IO。比较相同状态或结果不代表设备当前在线或机械打印完成。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK11PixelFormatO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-201fc189ec6a92750c71"></a>

### PixelFormat.gray8

选择gray8源像素。

```swift
case gray8
```

每像素1字节灰度，0黑、255白，rawValue=1。不执行解码或打印IO。

文档 ID：`apple:symbol:s:10PrinterSDK11PixelFormatO5gray8yA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-736be9763b56a01a1d07"></a>

### PixelFormat.hash(into:)

编译器提供的枚举散列。

```swift
func hash(into hasher: inout Hasher)
```

用于Swift集合与字典，按当前枚举raw值生成；散列不稳定，不能持久化为协议值、设备身份或跨进程标识，不执行IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK11PixelFormatO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-f1432bd35a1bd5bbfb7e"></a>

### PixelFormat.hashValue

编译器提供的枚举散列。

```swift
var hashValue: Int { get }
```

用于Swift集合与字典，按当前枚举raw值生成；散列不稳定，不能持久化为协议值、设备身份或跨进程标识，不执行IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK11PixelFormatO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-6e6ab1e42778179f800f"></a>

### PixelFormat.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK11PixelFormatO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-ed0fa655c10b949327d6"></a>

### PixelFormat.rgb24

选择rgb24源像素。

```swift
case rgb24
```

每像素3字节，顺序R/G/B，rawValue=2。不执行解码或打印IO。

文档 ID：`apple:symbol:s:10PrinterSDK11PixelFormatO5rgb24yA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-3d42babddc39cfe2b52b"></a>

### PixelFormat.rgba32

选择rgba32源像素。

```swift
case rgba32
```

每像素4字节，顺序R/G/B/A，rawValue=3；Alpha按图像流水线规则合成。不执行解码或打印IO。

文档 ID：`apple:symbol:s:10PrinterSDK11PixelFormatO6rgba32yA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-6bb193bc6a8b988482be"></a>

## Pixels

<a id="api-966c9a14c6177a1a4168"></a>

### Pixels

原始像素及图像处理参数。

```swift
final class Pixels
```

保存只读Data与尺寸、像素格式、二值化和缩放设置；编码图片解码由应用准备函数负责。同一Pixels对象在多个元素中复用时只进行一次native导入。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC`

符号种类：`swift.class`；访问级别：`public`。

<a id="api-5a0f23a2779b0cc774b3"></a>

### Pixels.algorithm

二值化算法。

```swift
let algorithm: ImageAlgorithm
```

选择阈值、Floyd-Steinberg或Bayer算法；图像处理独立于协议编码。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC9algorithmAA14ImageAlgorithmOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| ImageAlgorithm | `s:10PrinterSDK14ImageAlgorithmO` |

<a id="api-e38f8659593948041741"></a>

### Pixels.data

只读原始像素数据。

```swift
let data: Data
```

内容格式由format决定；不支持直接传PNG/JPEG编码数据，解码在应用准备函数完成。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC4data10Foundation4DataVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Data | `s:10Foundation4DataV` |

<a id="api-4c755b350085ddeadeff"></a>

### Pixels.fitWidth

是否按目标宽度适配。

```swift
let fitWidth: Bool
```

与targetWidthDots一起传给图像处理层，缩放独立于设备传输分块。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC8fitWidthSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-a17443a4ac8d81afc77a"></a>

### Pixels.format

原始像素格式。

```swift
let format: PixelFormat
```

选择GRAY8、RGB24或RGBA32；输入数据长度与宽高须一致。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC6formatAA11PixelFormatOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| PixelFormat | `s:10PrinterSDK11PixelFormatO` |

<a id="api-809721b4c966cc0a9c6d"></a>

### Pixels.height

原图高度。

```swift
let height: UInt32
```

单位为像素；大图按SDK图像/协议流水线分块处理，不要求完整最终打印缓冲区。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC6heights6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-234f32a4f3a1dc0cbd7a"></a>

### Pixels.init(data:width:height:format:algorithm:threshold:invert:fitWidth:targetWidthDots:)

构造Pixels只读数据。

```swift
init(data: Data, width: UInt32, height: UInt32, format: PixelFormat = .gray8, algorithm: ImageAlgorithm = .threshold, threshold: UInt32 = 128, invert: Bool = false, fitWidth: Bool = false, targetWidthDots: UInt32 = 0)
```

保存只读Data与尺寸、像素格式、二值化和缩放设置；编码图片解码由应用准备函数负责。同一Pixels对象在多个元素中复用时只进行一次native导入。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC4data5width6height6format9algorithm9threshold6invert8fitWidth06targetL4DotsAC10Foundation4DataV_s6UInt32VAqA11PixelFormatOAA14ImageAlgorithmOAQS2bAQtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |
| Data | `s:10Foundation4DataV` |
| ImageAlgorithm | `s:10PrinterSDK14ImageAlgorithmO` |
| PixelFormat | `s:10PrinterSDK11PixelFormatO` |
| UInt32 | `s:s6UInt32V` |

<a id="api-8cea43daf445bd9790ad"></a>

### Pixels.invert

是否反转输出黑白。

```swift
let invert: Bool
```

只改变图像处理配置，不修改输入像素对象。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC6invertSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-1a206c7916dfe62e37c3"></a>

### Pixels.targetWidthDots

缩放目标宽度。

```swift
let targetWidthDots: UInt32
```

单位为打印dots；默认0表示不提供显式目标宽度，实际行为遵循图像适配配置。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC15targetWidthDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-0ffc27772418fb164d4f"></a>

### Pixels.threshold

二值化阈值。

```swift
let threshold: UInt32
```

有效范围按图像契约校验，默认128；不改变原始像素格式。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC9thresholds6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-eb98831d97555eb1fdf6"></a>

### Pixels.width

原图宽度。

```swift
let width: UInt32
```

单位为像素，与height和format共同确定输入数据布局；不等同于传输分块大小。

文档 ID：`apple:symbol:s:10PrinterSDK6PixelsC5widths6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-1c60054e629e6db79dd6"></a>

## PreparedPrint

<a id="api-398d9a825d01f1959605"></a>

### PreparedPrint

准备阶段产生的不可变打印描述。

```swift
struct PreparedPrint
```

描述标签或小票布局、图片/空白元素及可选介质要求；不持有native任务或图像句柄。Manager在后台导入像素并构建native job，重复引用同一像素对象只导入一次。

文档 ID：`apple:symbol:s:10PrinterSDK13PreparedPrintV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-427f21a7cf1e5d6153e0"></a>

### PreparedPrint.init(label:elements:mediaRequirement:)

构造PreparedPrint只读数据。

```swift
init(label: LabelJobOptions, elements: [PrintElement], mediaRequirement: MediaRequirement? = nil)
```

描述标签或小票布局、图片/空白元素及可选介质要求；不持有native任务或图像句柄。Manager在后台导入像素并构建native job，重复引用同一像素对象只导入一次。

文档 ID：`apple:symbol:s:10PrinterSDK13PreparedPrintV5label8elements16mediaRequirementAcA15LabelJobOptionsV_SayAA0D7ElementOGAA05MediaH0VSgtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| LabelJobOptions | `s:10PrinterSDK15LabelJobOptionsV` |
| MediaRequirement | `s:10PrinterSDK16MediaRequirementV` |
| PrintElement | `s:10PrinterSDK12PrintElementO` |

<a id="api-d4e2d8ad30b36f605176"></a>

### PreparedPrint.init(receipt:elements:finish:mediaRequirement:)

构造PreparedPrint只读数据。

```swift
init(receipt: ReceiptJobOptions, elements: [PrintElement], finish: ReceiptFinishOptions = ReceiptFinishOptions(), mediaRequirement: MediaRequirement? = nil)
```

描述标签或小票布局、图片/空白元素及可选介质要求；不持有native任务或图像句柄。Manager在后台导入像素并构建native job，重复引用同一像素对象只导入一次。

文档 ID：`apple:symbol:s:10PrinterSDK13PreparedPrintV7receipt8elements6finish16mediaRequirementAcA17ReceiptJobOptionsV_SayAA0D7ElementOGAA0j6FinishL0VAA05MediaI0VSgtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MediaRequirement | `s:10PrinterSDK16MediaRequirementV` |
| PrintElement | `s:10PrinterSDK12PrintElementO` |
| ReceiptFinishOptions | `s:10PrinterSDK20ReceiptFinishOptionsV` |
| ReceiptJobOptions | `s:10PrinterSDK17ReceiptJobOptionsV` |

<a id="api-bc94fceab7b905f1b496"></a>

## PrintElement

<a id="api-426f707123e1ef20eb3f"></a>

### PrintElement

打印描述中的图片或空白元素。

```swift
enum PrintElement
```

image指定原始像素及标签坐标；blank用于小票留白。元素只保存数据，Manager负责后续native任务构建和设备队列提交。

文档 ID：`apple:symbol:s:10PrinterSDK12PrintElementO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-8f7b8270bb5a33c56bd9"></a>

### PrintElement.blank(dots:)

添加小票空白元素。

```swift
case blank(dots: UInt32)
```

dots为纵向空白长度；不执行设备IO，后续由Manager构建任务并在native队列串行发送。

文档 ID：`apple:symbol:s:10PrinterSDK12PrintElementO5blankyACs6UInt32V_tcACmF`

符号种类：`swift.enum.case`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-4a1b87f6a9048baa13fa"></a>

### PrintElement.image(_:x:y:)

添加图片元素。

```swift
case image(Pixels, x: Int32 = 0, y: Int32 = 0)
```

引用Pixels并提供以dots计的标签坐标；小票图像顺序由元素顺序确定，native图像由Manager后台导入。

文档 ID：`apple:symbol:s:10PrinterSDK12PrintElementO5imageyAcA6PixelsC_s5Int32VAHtcACmF`

符号种类：`swift.enum.case`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |
| Pixels | `s:10PrinterSDK6PixelsC` |

<a id="api-7ef50076423442cb8f07"></a>

## PrintOptions

<a id="api-ee75d72f883da56965db"></a>

### PrintOptions

请求总超时配置。

```swift
struct PrintOptions
```

超时预算覆盖等待、应用准备、native准入和执行阶段；timeoutMs/timeoutMilliseconds使用毫秒，必须为有效正值。

文档 ID：`apple:symbol:s:10PrinterSDK12PrintOptionsV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-f0182f20c26582a9237f"></a>

### PrintOptions.init(timeoutMilliseconds:)

构造PrintOptions只读数据。

```swift
init(timeoutMilliseconds: UInt32 = 120000)
```

超时预算覆盖等待、应用准备、native准入和执行阶段；timeoutMs/timeoutMilliseconds使用毫秒，必须为有效正值。

文档 ID：`apple:symbol:s:10PrinterSDK12PrintOptionsV19timeoutMillisecondsACs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-6cf5b05e278a1d6086e4"></a>

### PrintOptions.timeoutMilliseconds

请求总超时配置。

```swift
let timeoutMilliseconds: UInt32
```

超时预算覆盖等待、应用准备、native准入和执行阶段；timeoutMs/timeoutMilliseconds使用毫秒，必须为有效正值。

文档 ID：`apple:symbol:s:10PrinterSDK12PrintOptionsV19timeoutMillisecondss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-51947abf7e628a2d3bc3"></a>

## PrinterCapabilities

<a id="api-04cc2e358bdb700591f5"></a>

### PrinterCapabilities

聚合且相互独立的能力观察值。

```swift
struct PrinterCapabilities
```

由PrinterManager.capabilities完成回调返回，包含features、constraints和geometry；不存在整体“已验证”布尔值，必须按各成员known/deviceSupport/evidence判断。此对象不包含平台原生句柄。

文档 ID：`apple:symbol:s:10PrinterSDK0A12CapabilitiesV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-a21bf93f74a28bda67ff"></a>

### PrinterCapabilities.constraints

按参数枚举索引的四项范围约束。

```swift
let constraints: [PrinterConstraint : ScalarConstraint]
```

copies和源载荷预算属于SDK接纳规则；介质间隙没有硬件证据时known为false。观察不预留额度，提交结果才是接纳权威。

文档 ID：`apple:symbol:s:10PrinterSDK0A12CapabilitiesV11constraintsSDyAA0A10ConstraintOAA06ScalarE0VGvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| PrinterConstraint | `s:10PrinterSDK0A10ConstraintO` |
| ScalarConstraint | `s:10PrinterSDK16ScalarConstraintV` |

<a id="api-354f2eeb9045ebcb43d0"></a>

### PrinterCapabilities.features

按功能枚举索引的八项能力。

```swift
let features: [PrinterFeature : FeatureSupport]
```

每项分别保存SDK实现、设备支持、证据和已知位掩码。当前状态与切纸未实现，其他实现可用不代表硬件支持；没有型号证据时deviceSupport保持unknown。

文档 ID：`apple:symbol:s:10PrinterSDK0A12CapabilitiesV8featuresSDyAA0A7FeatureOAA0E7SupportVGvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| FeatureSupport | `s:10PrinterSDK14FeatureSupportV` |
| PrinterFeature | `s:10PrinterSDK0A7FeatureO` |

<a id="api-af5f287d707c793db940"></a>

### PrinterCapabilities.geometry

有存在位依据的可选打印几何。

```swift
let geometry: PrinterGeometry
```

各未知数值转换为nil，不使用零或最近一次Profile冒充已知能力。当前通信设备不绑定打印配置，所有几何字段未知。

文档 ID：`apple:symbol:s:10PrinterSDK0A12CapabilitiesV8geometryAA0A8GeometryVvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| PrinterGeometry | `s:10PrinterSDK0A8GeometryV` |

<a id="api-1f9f816f9d0db63d9e95"></a>

## PrinterConstraint

<a id="api-ea37902c12ef0d4b96c4"></a>

### PrinterConstraint

标量约束的查询参数。

```swift
enum PrinterConstraint
```

不可变 UInt32 原始值枚举；分类不表示经过验证的硬件支持，未知原始值不能猜测映射。

文档 ID：`apple:symbol:s:10PrinterSDK0A10ConstraintO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-ddb66ae3be01f1dd5dd7"></a>

### PrinterConstraint.!=(_:_:)

按值比较两个 PrinterConstraint 是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift Equatable 提供的比较，不执行 IO、不刷新状态。比较本次值或枚举，不能把相等的快照当作设备仍在线、硬件正常或纸面打印完成的证明。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A10ConstraintO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-3d4fa4e842fdf2855bac"></a>

### PrinterConstraint.copies

份数约束，值 1，单位份。

```swift
case copies
```

固定公共枚举值；其含义仅限本查询参数、来源分类或协议选择，不能据此推断设备当前状态或纸面完成。

文档 ID：`apple:symbol:s:10PrinterSDK0A10ConstraintO6copiesyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-7f300210109826fe0e28"></a>

### PrinterConstraint.hash(into:)

把枚举值加入 Swift 哈希器。

```swift
func hash(into hasher: inout Hasher)
```

Swift Hashable 合成操作，不执行 IO；哈希结果不保证跨进程一致，持久化时使用已文档化的 rawValue。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK0A10ConstraintO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-6ccd3f3e850120d8bbd6"></a>

### PrinterConstraint.hashValue

枚举的进程内哈希值。

```swift
var hashValue: Int { get }
```

Swift Hashable 合成值，用于当前进程集合，不是稳定协议值、持久标识或设备 ID；协议值读取 rawValue。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK0A10ConstraintO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-30fba607314bd3559116"></a>

### PrinterConstraint.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK0A10ConstraintO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-0647aa2da183a5553240"></a>

### PrinterConstraint.jobImageBytes

单作业图像源载荷，值 3，单位字节。

```swift
case jobImageBytes
```

固定公共枚举值；其含义仅限本查询参数、来源分类或协议选择，不能据此推断设备当前状态或纸面完成。

文档 ID：`apple:symbol:s:10PrinterSDK0A10ConstraintO13jobImageBytesyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-bbc3b5bb6f5a53fe0ddf"></a>

### PrinterConstraint.mediaGapMicrometers

介质间隙约束，值 2，单位微米。

```swift
case mediaGapMicrometers
```

固定公共枚举值；其含义仅限本查询参数、来源分类或协议选择，不能据此推断设备当前状态或纸面完成。

文档 ID：`apple:symbol:s:10PrinterSDK0A10ConstraintO19mediaGapMicrometersyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-d95f145203c6ec6479ae"></a>

### PrinterConstraint.pendingPayloadBytes

设备未终态源载荷，值 4，单位字节。

```swift
case pendingPayloadBytes
```

固定公共枚举值；其含义仅限本查询参数、来源分类或协议选择，不能据此推断设备当前状态或纸面完成。

文档 ID：`apple:symbol:s:10PrinterSDK0A10ConstraintO19pendingPayloadBytesyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-67c88d53ad46bc6679a5"></a>

## PrinterFeature

<a id="api-e03f0b77f68138fbd004"></a>

### PrinterFeature

可供能力查询选择的功能标识。

```swift
enum PrinterFeature
```

传给 `PrinterCapabilities.feature`，选择要读取的软件实现、设备支持及证据。枚举项存在不表示功能已实现或硬件支持；以返回的 `FeatureSupport` 为准。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-2a266904387af010fa70"></a>

### PrinterFeature.!=(_:_:)

比较两个 PrinterFeature 值是否不相等。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift 标准库 `Equatable` 扩展为此类型提供的合成公开成员，不是独立 SDK 实现。参数 `lhs`、`rhs` 为两个值；枚举项不同时返回 true，否则 false。不抛出错误、不执行 IO，也不比较设备状态或诊断文案。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A7FeatureO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-ed8320a141e822e9838f"></a>

### PrinterFeature.cut

查询切纸功能。

```swift
case cut
```

当前标准后端未实现切纸。此项与小票打印功能分开；不要以 ESC/POS 协议名或小票配置推断机器存在切刀。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO3cutyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-0f03e7d7e9c7eaacfc34"></a>

### PrinterFeature.feedToNextLabel

查询下一标签起点定位功能。

```swift
case feedToNextLabel
```

当前 CPCL 标签设备提供定位命令，小票设备不提供。调用方负责合适介质配置，能力和发送成功均不证明纸张已实际定位。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO15feedToNextLabelyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-a5485c5b38516b40782d"></a>

### PrinterFeature.hash(into:)

把 PrinterFeature 的相等性相关值混入 Hasher。

```swift
func hash(into hasher: inout Hasher)
```

Swift 标准库为原始值枚举提供的合成成员，不是 SDK 实现。`hasher` 为调用方按 `inout` 传入的 `Hasher`，方法更新其状态，没有返回值且不抛出错误。用于 `Hashable` 集合语义，哈希结果不是跨进程稳定序列化格式，不涉及设备 IO。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK0A7FeatureO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-3106913662603703972d"></a>

### PrinterFeature.hashValue

获取 PrinterFeature 的进程内哈希值。

```swift
var hashValue: Int { get }
```

Swift 标准库为原始值枚举提供的合成 `Hashable` 成员，不是 SDK 稳定编号。用于集合/字典查找；不要持久化、传输、作为 API 原始值或在不同进程/版本间比较。需要契约数值时使用枚举原始值语义。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK0A7FeatureO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-543fb5685df7584ecfc2"></a>

### PrinterFeature.image

查询主机图像处理与发送功能。

```swift
case image
```

描述图像路径的软件实现；当前使用主机渲染。可用算法和源载荷资源限制仍独立，不能据此推断目标设备所有像素尺寸都可接纳。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO5imageyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-fc7bddb2fbc60c0085ae"></a>

### PrinterFeature.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-a7c224117407dc06c54c"></a>

### PrinterFeature.label

查询固定标签打印功能。

```swift
case label
```

判断当前配置是否提供标签作业路径；当前标签设备具备软件实现，小票设备不提供。实现支持与硬件支持证据独立，须读取 `FeatureSupport`。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO5labelyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-da8aea00014fb7c0bc4d"></a>

### PrinterFeature.media

查询介质模式设置功能。

```swift
case media
```

当前 CPCL 标签设备提供介质跟踪设置，小票设备拒绝。设置发送成功仍不是设备读回或硬件确认，且不改变每个图像作业的几何。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO5mediayA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-a8e4a139bc0c500db441"></a>

### PrinterFeature.raw

查询原始字节发送功能。

```swift
case raw
```

原样发送仍通过设备同一串行队列；功能实现不校验载荷的协议语义，也不保证任意 Raw 命令在设备上安全或受支持。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO3rawyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-7b4cb6ec046e34c9fe5b"></a>

### PrinterFeature.receipt

查询小票打印功能。

```swift
case receipt
```

判断当前配置是否提供小票作业路径；当前小票设备具备软件实现，标签设备不提供。设备页长与切刀仍是独立能力，不能由小票功能推断。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO7receiptyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-d82541532c85edfb8283"></a>

### PrinterFeature.status

查询打印机状态读取功能。

```swift
case status
```

当前标准 CPCL/ESC/POS 后端未实现状态查询。通过参数和生命周期校验后，`queryStatus` 因该能力不受支持而拒绝时，通过主线程完成回调异步返回 1004 UNSUPPORTED_OPERATION，不执行打印机 IO；未连接、已关闭或参数非法等情况仍返回相应校验错误。该能力项不代表可读取缺纸、开盖或就绪状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7FeatureO6statusyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-b511b313f54808d516b6"></a>

## PrinterGeometry

<a id="api-850e4163c3320f338599"></a>

### PrinterGeometry

以nil表示未知的打印几何。

```swift
struct PrinterGeometry
```

从本地能力观察返回，不发送IO；值只有在相应存在位有效时才非nil。单页上限与小票跨副本的累计长度预算分开。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-12a1be9bdde743deeae9"></a>

### PrinterGeometry.!=(_:_:)

编译器提供的值不等比较。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

按该值类型的Equatable语义比较，返回布尔值，不执行设备IO。比较相同状态或结果不代表设备当前在线或机械打印完成。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A8GeometryV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-0c1b4d883c4741237970"></a>

### PrinterGeometry.dpiX

横向DPI的可选值。

```swift
let dpiX: UInt32?
```

nil表示未知，不能解释为零、无限或不支持。当前纯通信设备没有硬件几何证据，因此返回nil。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV4dpiXs6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-b08f8570db8cc04b75ff"></a>

### PrinterGeometry.dpiY

纵向DPI的可选值。

```swift
let dpiY: UInt32?
```

nil表示未知，不能解释为零、无限或不支持。当前纯通信设备没有硬件几何证据，因此返回nil。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV4dpiYs6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-78b2f9a426e1788f3d27"></a>

### PrinterGeometry.evidence

打印几何证据位。

```swift
let evidence: UInt32
```

PROFILE_DECLARED=1、DEVICE_REPORTED=2、HARDWARE_VERIFIED=4；各位描述来源，零表示没有相应证据。不能由软件构建通过提升为硬件验证。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV8evidences6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-f95ae36feed3348d378e"></a>

### PrinterGeometry.maxPageLengthDots

一页或一份输出的最大长度（点）的可选值。

```swift
let maxPageLengthDots: UInt32?
```

nil表示未知，不能解释为零、无限或不支持。此值不乘copies，不是ReceiptJobOptions.maxTotalLengthDots整单预算。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV17maxPageLengthDotss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-c1efa55a22dad33d90d2"></a>

### PrinterGeometry.minCutBlankDots

切纸前最小留白（点）的可选值。

```swift
let minCutBlankDots: UInt32?
```

nil表示未知，不能解释为零、无限或不支持。当前纯通信设备没有硬件几何证据，因此返回nil。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV15minCutBlankDotss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-d294829e2a935b9b07ff"></a>

### PrinterGeometry.printableWidthDots

可打印宽度（点）的可选值。

```swift
let printableWidthDots: UInt32?
```

nil表示未知，不能解释为零、无限或不支持。当前纯通信设备没有硬件几何证据，因此返回nil。

文档 ID：`apple:symbol:s:10PrinterSDK0A8GeometryV18printableWidthDotss6UInt32VSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-1d5ad0ccf40ef0036743"></a>

## PrinterManager

<a id="api-03e4d1448ba1e8315656"></a>

### PrinterManager

独立的单设备打印会话。

```swift
final class PrinterManager
```

通过构造器创建独立实例；连接、发现、打印、控制、查询和清理均由此入口管理。请求立即返回标识，完成结果异步投递到主线程；准备与准入保持请求顺序，打印机IO始终由native设备队列串行执行，不自动重连、重放或重试。 只有完成及意外断连闭包隔离到 `@MainActor`；Manager 本身可从非主执行器调用，准备闭包继续在后台执行。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC`

符号种类：`swift.class`；访问级别：`public`。

<a id="api-17fa147346962a6d9ca4"></a>

### PrinterManager.bondedDevices(completion:)

请求枚举系统已配对蓝牙设备（iOS 不支持）。

```swift
@discardableResult func bondedDevices(completion: @escaping @MainActor @Sendable (ManagerResult<[DiscoveredPrinter]>) -> Void) -> RequestID
```

当前 iOS 不提供系统已配对蓝牙设备枚举。通过 Manager 生命周期校验后，通过主线程完成回调异步返回 1004 UNSUPPORTED_OPERATION；已关闭等情况仍返回相应生命周期错误。不发起隐式配对，也不将 BLE 扫描结果当作已配对设备列表。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC13bondedDevices10completionAA9RequestIDVyAA0C6ResultVySayAA010DiscoveredA0VGGYbScMYcc_tF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| DiscoveredPrinter | `s:10PrinterSDK010DiscoveredA0V` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| Void | `s:s4Voida` |

<a id="api-8e997bbe3a79436294af"></a>

### PrinterManager.cancel(_:)

请求取消本Manager拥有的请求。

```swift
func cancel(_ requestID: RequestID)
```

取消意图覆盖等待、准备、准入与native执行阶段；外部Manager的标识和已完成请求不改变设备。取消本身不证明没有输出，最终结果的outputMayHaveOccurred用于提示可能已部分发送。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC6cancelyyAA9RequestIDVF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| RequestID | `s:10PrinterSDK9RequestIDV` |

<a id="api-de266a4346e17581587d"></a>

### PrinterManager.capabilities(completion:)

读取当前设备的能力描述。

```swift
@discardableResult func capabilities(completion: @escaping @MainActor @Sendable (ManagerResult<PrinterCapabilities>) -> Void) -> RequestID
```

异步交付PrinterCapabilities；未知或不支持的能力应按描述处理，能力查询不执行自动打印探测，也不替代每次请求的准入校验。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC12capabilities10completionAA9RequestIDVyAA0C6ResultVyAA0A12CapabilitiesVGYbScMYcc_tF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| PrinterCapabilities | `s:10PrinterSDK0A12CapabilitiesV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| Void | `s:s4Voida` |

<a id="api-e260c729de54e181e4e5"></a>

### PrinterManager.close(completion:)

永久关闭Manager并释放其连接资源。

```swift
@discardableResult func close(completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

这是幂等的异步清理屏障；所有属于该会话的请求终态先交付，清理完成后再交付close回调。关闭后业务请求异步返回InvalidState。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC5close10completionAA9RequestIDVyAA0C6ResultVyytGYbScMYcc_tF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| Void | `s:s4Voida` |

<a id="api-2d85ca74f1741c0a6a2f"></a>

### PrinterManager.connect(bleIdentifier:options:timeoutMilliseconds:completion:onDisconnected:)

连接指定设备。

```swift
@discardableResult func connect(bleIdentifier: UUID, options: BLEOptions, timeoutMilliseconds: UInt32 = 5000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void, onDisconnected: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void = { _ in }) -> RequestID
```

立即返回请求标识；连接成功或失败通过主线程完成回调交付。每个Manager至多拥有一个设备连接，意外断连通过本次连接的onDisconnected通知，不自动重连。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。 `onDisconnected` 同样使用 `@MainActor @Sendable`；显式保存闭包时须保留该隔离类型。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC7connect13bleIdentifier7options19timeoutMilliseconds10completion14onDisconnectedAA9RequestIDV10Foundation4UUIDV_AA10BLEOptionsVs6UInt32VyAA0C6ResultVyytGYbScMYccyAUYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| BLEOptions | `s:10PrinterSDK10BLEOptionsV` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| UInt32 | `s:s6UInt32V` |
| UUID | `s:10Foundation4UUIDV` |
| Void | `s:s4Voida` |

<a id="api-87b5c726b74156715212"></a>

### PrinterManager.disconnect(completion:)

关闭当前连接并结束本会话请求。

```swift
@discardableResult func disconnect(completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

尽快取消等待、准备和native任务并异步释放资源；清理完成后才可显式连接新设备。不合作的准备代码可以迟到返回，但结果不会再次准入。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC10disconnect10completionAA9RequestIDVyAA0C6ResultVyytGYbScMYcc_tF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| Void | `s:s4Voida` |

<a id="api-422035c4c1c41c4d2d04"></a>

### PrinterManager.feedToNextLabel(profile:timeoutMilliseconds:completion:)

提交定位下一张标签请求。

```swift
@discardableResult func feedToNextLabel(profile: CpclProfile, timeoutMilliseconds: UInt32 = 120000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

指定CpclProfile并在同一native设备队列执行；仅在设备profile声明支持时可用，不自行猜测定位命令。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC15feedToNextLabel7profile19timeoutMilliseconds10completionAA9RequestIDVAA11CpclProfileV_s6UInt32VyAA0C6ResultVyytGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CpclProfile | `s:10PrinterSDK11CpclProfileV` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| UInt32 | `s:s6UInt32V` |
| Void | `s:s4Voida` |

<a id="api-d35ade3a5258fcd64664"></a>

### PrinterManager.init()

创建独立Manager实例。

```swift
init()
```

每个实例至多管理一个连接；不使用共享单例。应用按页面或业务所有权保存实例，并在结束时调用异步close释放资源。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerCACycfc`

符号种类：`swift.init`；访问级别：`public`。

<a id="api-928bc48731dc66ed41b9"></a>

### PrinterManager.print(profile:options:preparation:completion:)

准备并提交一次标签或小票打印请求。

```swift
@discardableResult func print(profile: CpclProfile, options: PrintOptions = PrintOptions(), preparation: @escaping @Sendable (CancellationContext) throws -> PreparedPrint, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

profile选择本次编码协议；preparation在后台产生PreparedPrint，options限制总超时。调用顺序决定准备准入顺序，完成回调区分dataSent与deviceConfirmed；任何失败都不自动重试或重放。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC5print7profile7options11preparation10completionAA9RequestIDVAA11CpclProfileV_AA12PrintOptionsVAA08PreparedM0VAA19CancellationContextCYbKcyAA0C6ResultVyytGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CancellationContext | `s:10PrinterSDK19CancellationContextC` |
| CpclProfile | `s:10PrinterSDK11CpclProfileV` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| PreparedPrint | `s:10PrinterSDK13PreparedPrintV` |
| PrintOptions | `s:10PrinterSDK12PrintOptionsV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| Void | `s:s4Voida` |

<a id="api-8c64dfac9316f06f20e2"></a>

### PrinterManager.print(profile:options:preparation:completion:)

准备并提交一次标签或小票打印请求。

```swift
@discardableResult func print(profile: ReceiptProfile, options: PrintOptions = PrintOptions(), preparation: @escaping @Sendable (CancellationContext) throws -> PreparedPrint, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

profile选择本次编码协议；preparation在后台产生PreparedPrint，options限制总超时。调用顺序决定准备准入顺序，完成回调区分dataSent与deviceConfirmed；任何失败都不自动重试或重放。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC5print7profile7options11preparation10completionAA9RequestIDVAA14ReceiptProfileV_AA12PrintOptionsVAA08PreparedM0VAA19CancellationContextCYbKcyAA0C6ResultVyytGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CancellationContext | `s:10PrinterSDK19CancellationContextC` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| PreparedPrint | `s:10PrinterSDK13PreparedPrintV` |
| PrintOptions | `s:10PrinterSDK12PrintOptionsV` |
| ReceiptProfile | `s:10PrinterSDK14ReceiptProfileV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| Void | `s:s4Voida` |

<a id="api-26753b61bd282f8b23ef"></a>

### PrinterManager.queryStatus(configuration:timeoutMilliseconds:completion:)

提交硬件状态查询请求。

```swift
@discardableResult func queryStatus(configuration: StatusQueryConfiguration, timeoutMilliseconds: UInt32 = 5000, completion: @escaping @MainActor @Sendable (ManagerResult<StatusResult>) -> Void) -> RequestID
```

配置明确协议请求、响应和超时；请求/响应事务占用同一设备队列。结果通过StatusResult报告已知位与活动位，不支持查询时异步失败。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC11queryStatus13configuration19timeoutMilliseconds10completionAA9RequestIDVAA0E18QueryConfigurationV_s6UInt32VyAA0C6ResultVyAA0eO0VGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| StatusQueryConfiguration | `s:10PrinterSDK24StatusQueryConfigurationV` |
| StatusResult | `s:10PrinterSDK12StatusResultV` |
| UInt32 | `s:s6UInt32V` |
| Void | `s:s4Voida` |

<a id="api-f8b99ae9c4ce71b52e8f"></a>

### PrinterManager.scanBLE(seconds:service:completion:)

枚举一段时间内发现的BLE设备。

```swift
@discardableResult func scanBLE(seconds: TimeInterval = 10, service: UUID? = nil, completion: @escaping @MainActor @Sendable (ManagerResult<[DiscoveredPrinter]>) -> Void) -> RequestID
```

服务过滤和扫描时长由请求给定，结果只含只读DiscoveredPrinter数据；扫描由Manager持有并可按请求标识取消。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC7scanBLE7seconds7service10completionAA9RequestIDVSd_10Foundation4UUIDVSgyAA0C6ResultVySayAA010DiscoveredA0VGGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| DiscoveredPrinter | `s:10PrinterSDK010DiscoveredA0V` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| TimeInterval | `c:@T@NSTimeInterval` |
| UUID | `s:10Foundation4UUIDV` |
| Void | `s:s4Voida` |

<a id="api-b2b88a9b9daf0fc19e3c"></a>

### PrinterManager.sdkInfo(completion:)

读取已加载SDK的身份信息。

```swift
@discardableResult func sdkInfo(completion: @escaping @MainActor @Sendable (ManagerResult<SDKInfo>) -> Void) -> RequestID
```

异步交付分发版本、native版本及ABI版本/修订，用于本地集成诊断；该值不等同于硬件验证证明。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC7sdkInfo10completionAA9RequestIDVyAA0C6ResultVyAA7SDKInfoVGYbScMYcc_tF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| SDKInfo | `s:10PrinterSDK7SDKInfoV` |
| Void | `s:s4Voida` |

<a id="api-a9dcca909185f4ada8e0"></a>

### PrinterManager.sendRaw(_:copies:timeoutMilliseconds:completion:)

发送显式原始命令请求。

```swift
@discardableResult func sendRaw(_ bytes: Data, copies: UInt32 = 1, timeoutMilliseconds: UInt32 = 120000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

原始字节在返回前制作有界快照，大小上限为1MiB；copies和超时在准入时校验。请求仍经过同一native设备队列，与普通打印及查询保持串行顺序。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC7sendRaw_6copies19timeoutMilliseconds10completionAA9RequestIDV10Foundation4DataV_s6UInt32VANyAA0C6ResultVyytGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Data | `s:10Foundation4DataV` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| UInt32 | `s:s6UInt32V` |
| Void | `s:s4Voida` |

<a id="api-d2f77c3c618503d332d6"></a>

### PrinterManager.setMedia(_:profile:timeoutMilliseconds:completion:)

提交介质设置控制请求。

```swift
@discardableResult func setMedia(_ settings: MediaSettings, profile: CpclProfile, timeoutMilliseconds: UInt32 = 120000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

使用MediaSettings和明确CpclProfile描述设置，能力与参数经校验后在同一设备队列执行；不支持的字段返回稳定错误，不依据型号猜测支持。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC8setMedia_7profile19timeoutMilliseconds10completionAA9RequestIDVAA0E8SettingsV_AA11CpclProfileVs6UInt32VyAA0C6ResultVyytGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CpclProfile | `s:10PrinterSDK11CpclProfileV` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| MediaSettings | `s:10PrinterSDK13MediaSettingsV` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| UInt32 | `s:s6UInt32V` |
| Void | `s:s4Voida` |

<a id="api-88bd74674482fbece62d"></a>

### PrinterManager.setMediaMode(_:profile:timeoutMilliseconds:completion:)

提交介质跟踪模式控制请求。

```swift
@discardableResult func setMediaMode(_ mode: MediaMode, profile: CpclProfile, timeoutMilliseconds: UInt32 = 120000, completion: @escaping @MainActor @Sendable (ManagerResult<Void>) -> Void) -> RequestID
```

使用显式MediaMode和CpclProfile；能力与参数经校验后在同一设备队列执行，不支持时通过完成回调返回稳定错误。 完成闭包声明为 `@escaping @MainActor @Sendable`，异步在主执行器交付；可直接访问 `@MainActor` UI 状态。

文档 ID：`apple:symbol:s:10PrinterSDK0A7ManagerC12setMediaMode_7profile19timeoutMilliseconds10completionAA9RequestIDVAA0eF0O_AA11CpclProfileVs6UInt32VyAA0C6ResultVyytGYbScMYcctF`

符号种类：`swift.method`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CpclProfile | `s:10PrinterSDK11CpclProfileV` |
| MainActor | `s:ScM` |
| ManagerResult | `s:10PrinterSDK13ManagerResultV` |
| MediaMode | `s:10PrinterSDK9MediaModeO` |
| RequestID | `s:10PrinterSDK9RequestIDV` |
| UInt32 | `s:s6UInt32V` |
| Void | `s:s4Voida` |

<a id="api-7c7a9dd0ee08114f96bd"></a>

## PrinterProtocol

<a id="api-ee78c2a7b2ae3e430847"></a>

### PrinterProtocol

状态查询使用的协议标识。

```swift
enum PrinterProtocol
```

不可变 UInt32 原始值枚举；分类不表示经过验证的硬件支持，未知原始值不能猜测映射。

文档 ID：`apple:symbol:s:10PrinterSDK0A8ProtocolO`

符号种类：`swift.enum`；访问级别：`public`。

<a id="api-e21ec72a9af0e560a42a"></a>

### PrinterProtocol.!=(_:_:)

按值比较两个 PrinterProtocol 是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift Equatable 提供的比较，不执行 IO、不刷新状态。比较本次值或枚举，不能把相等的快照当作设备仍在线、硬件正常或纸面打印完成的证明。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A8ProtocolO`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-34ca04cf50ed336494f8"></a>

### PrinterProtocol.cpcl

CPCL 协议，值 1。

```swift
case cpcl
```

固定公共枚举值；其含义仅限本查询参数、来源分类或协议选择，不能据此推断设备当前状态或纸面完成。

文档 ID：`apple:symbol:s:10PrinterSDK0A8ProtocolO4cpclyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-d293be9eeff309e50a88"></a>

### PrinterProtocol.escpos

ESC/POS 协议，值 2。

```swift
case escpos
```

固定公共枚举值；其含义仅限本查询参数、来源分类或协议选择，不能据此推断设备当前状态或纸面完成。

文档 ID：`apple:symbol:s:10PrinterSDK0A8ProtocolO6escposyA2CmF`

符号种类：`swift.enum.case`；访问级别：`public`。

<a id="api-6b9ae2c161eae60889a4"></a>

### PrinterProtocol.hash(into:)

把枚举值加入 Swift 哈希器。

```swift
func hash(into hasher: inout Hasher)
```

Swift Hashable 合成操作，不执行 IO；哈希结果不保证跨进程一致，持久化时使用已文档化的 rawValue。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK0A8ProtocolO`

符号种类：`swift.method`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

泛型约束（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}]}
```

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Hasher | `s:s6HasherV` |

<a id="api-31eab7428337d2d3cd1f"></a>

### PrinterProtocol.hashValue

枚举的进程内哈希值。

```swift
var hashValue: Int { get }
```

Swift Hashable 合成值，用于当前进程集合，不是稳定协议值、持久标识或设备 ID；协议值读取 rawValue。

文档 ID：`apple:symbol:s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK0A8ProtocolO`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"constraints":[{"kind":"conformance","lhs":"Self","rhs":"Hashable","rhsPrecise":"s:SH"},{"kind":"conformance","lhs":"Self.RawValue","rhs":"Hashable","rhsPrecise":"s:SH"}],"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int | `s:Si` |

<a id="api-79c7a249bf4dd30b8b12"></a>

### PrinterProtocol.init(rawValue:)

按已声明raw值构造枚举。

```swift
init?(rawValue: UInt32)
```

匹配本版枚举值时返回对应项，未知数值返回nil；不执行IO、不探测设备，也不自动接受未来枚举。精确raw值见本页编译器枚举表。

文档 ID：`apple:symbol:s:10PrinterSDK0A8ProtocolO8rawValueACSgs6UInt32V_tcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-7eade5ddc7d13cb74d9a"></a>

## PrinterSDKError

<a id="api-c92cbc522af8f71283af"></a>

### PrinterSDKError

以稳定数值错误码表示 SDK 调用失败的值。

```swift
struct PrinterSDKError
```

遵循 `LocalizedError` 与 `Equatable`。应用按 `code` 分支处理，面向人的英文描述用于诊断，不作为稳定解析协议。构造该值不执行 IO，也不会改变设备状态；不可变值可保存为诊断结果。`Equatable` 比较错误码，Foundation/Swift 扩展成员在参考中单列，不表示 SDK 额外执行了恢复或查询。

文档 ID：`apple:symbol:s:10PrinterSDK0A8SDKErrorV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-bbdf32fa79df5bb148b0"></a>

### PrinterSDKError.!=(_:_:)

比较两个 PrinterSDKError 值是否不相等。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift 标准库 `Equatable` 扩展为此类型提供的合成公开成员，不是独立 SDK 实现。参数 `lhs`、`rhs` 为两个值；所保存错误码不同时返回 true，否则 false。不抛出错误、不执行 IO，也不比较设备状态或诊断文案。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-0ca4770bef6f2a99fc82"></a>

### PrinterSDKError.==(_:_:)

按稳定错误码比较 SDK 异常。

```swift
static func == (lhs: PrinterSDKError, rhs: PrinterSDKError) -> Bool
```

保留既有 PrinterSDKError 仅按 code 相等的语义；附加诊断内容不同不改变错误分类比较，不执行 IO。

文档 ID：`apple:symbol:s:10PrinterSDK0A8SDKErrorV2eeoiySbAC_ACtFZ`

符号种类：`swift.func.op`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |
| PrinterSDKError | `s:10PrinterSDK0A8SDKErrorV` |

<a id="api-646e532f5b246d5fb619"></a>

### PrinterSDKError.code

可供程序判断的稳定 SDK 错误码。

```swift
let code: Int32
```

主要值：1000 内部错误，1001 参数无效，1002 状态无效，1003 SDK 未初始化，1004 不支持，1005 已取消，1006 ABI 不匹配，1007 输出缓冲区不足，1008 资源限制；2000 传输未打开，2001 超时，2002 连接丢失，2003 IO 错误，2004 无传输进展，3000 协议响应无效。取消或连接丢失不证明零字节交付；不得据错误码自动重放可能产生副作用的打印。

文档 ID：`apple:symbol:s:10PrinterSDK0A8SDKErrorV4codes5Int32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-a1633f493b15c6c59882"></a>

### PrinterSDKError.errorDescription

包含错误码的可读诊断消息。

```swift
var errorDescription: String? { get }
```

返回当前实现的英文说明加括号内数值；未知码也有说明。虽然类型为 `String?`，当前实现总会生成字符串。文案不承诺稳定或自动本地化，业务分支应使用 `code`，需要本地化时由应用映射。

文档 ID：`apple:symbol:s:10PrinterSDK0A8SDKErrorV16errorDescriptionSSSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-16ca14e3ec29f4e04bd0"></a>

### PrinterSDKError.failureReason

Foundation 提供的可选失败原因。

```swift
var failureReason: String? { get }
```

`LocalizedError` 的 Foundation 默认扩展成员，不是 SDK 额外查询的结果；当前 SDK 没有覆盖，默认 nil。主要错误诊断使用 `code` 和 `errorDescription`，业务不能依赖此字段一定存在。

文档 ID：`apple:symbol:s:10Foundation14LocalizedErrorPAAE13failureReasonSSSgvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

编译器 availability（保留基线原值）：

```json
[{"domain":"iOS","introduced":{"major":8,"minor":0}},{"domain":"macOS","introduced":{"major":10,"minor":10}},{"domain":"tvOS","introduced":{"major":9,"minor":0}},{"domain":"watchOS","introduced":{"major":2,"minor":0}}]
```

扩展来源（保留基线原值）：

```json
{"extendedModule":"Foundation","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-dd0dd15e4546e0d69b49"></a>

### PrinterSDKError.helpAnchor

Foundation 提供的可选错误帮助锚点。

```swift
var helpAnchor: String? { get }
```

`LocalizedError` 的 Foundation 默认扩展成员，不是 SDK 的独立实现；当前 SDK 没有提供专用帮助锚点，使用默认 nil。不要把它作为稳定文档 URL 或错误码替代。

文档 ID：`apple:symbol:s:10Foundation14LocalizedErrorPAAE10helpAnchorSSSgvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

编译器 availability（保留基线原值）：

```json
[{"domain":"iOS","introduced":{"major":8,"minor":0}},{"domain":"macOS","introduced":{"major":10,"minor":10}},{"domain":"tvOS","introduced":{"major":9,"minor":0}},{"domain":"watchOS","introduced":{"major":2,"minor":0}}]
```

扩展来源（保留基线原值）：

```json
{"extendedModule":"Foundation","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-14712022ed2f2e9e4922"></a>

### PrinterSDKError.init(_:)

用一个 SDK 数值错误码构造错误值。

```swift
init(_ code: Int32)
```

`code` 为 `Int32`，原样保存；不校验是否已定义，也不抛出异常。未知数值仍可保留，描述显示未知 SDK 错误并包含该数值，便于未来版本和原生错误诊断。构造本身不尝试恢复连接或重试打印。

文档 ID：`apple:symbol:s:10PrinterSDK0A8SDKErrorVyACs5Int32Vcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-a56515ad7a768803dd57"></a>

### PrinterSDKError.localizedDescription

Foundation 为 Error 提供的可读描述入口。

```swift
var localizedDescription: String { get }
```

来自 Foundation 的 `Error` 扩展，由系统桥接 `LocalizedError` 描述；不是 SDK 的另一套错误码或独立恢复逻辑。当前错误说明可经 `errorDescription` 获得，业务分支仍使用稳定 `code`。不要解析系统描述文本或假定它已按应用语言翻译。

文档 ID：`apple:symbol:s:s5ErrorP10FoundationE20localizedDescriptionSSvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

编译器 availability（保留基线原值）：

```json
[{"domain":"iOS","introduced":{"major":8,"minor":0}},{"domain":"macOS","introduced":{"major":10,"minor":10}},{"domain":"tvOS","introduced":{"major":9,"minor":0}},{"domain":"watchOS","introduced":{"major":2,"minor":0}}]
```

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-1072a2373d94dcac09c2"></a>

### PrinterSDKError.recoverySuggestion

Foundation 提供的可选恢复建议。

```swift
var recoverySuggestion: String? { get }
```

`LocalizedError` 的 Foundation 默认扩展成员，当前 SDK 没有覆盖，默认 nil；不表示 SDK 会恢复或重试打印。应用应按错误码、连接状态与副作用证据决定下一步，交付不明确时不得自动重放。

文档 ID：`apple:symbol:s:10Foundation14LocalizedErrorPAAE18recoverySuggestionSSSgvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV`

符号种类：`swift.property`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

编译器 availability（保留基线原值）：

```json
[{"domain":"iOS","introduced":{"major":8,"minor":0}},{"domain":"macOS","introduced":{"major":10,"minor":10}},{"domain":"tvOS","introduced":{"major":9,"minor":0}},{"domain":"watchOS","introduced":{"major":2,"minor":0}}]
```

扩展来源（保留基线原值）：

```json
{"extendedModule":"Foundation","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-7a656acf1cbdc7b0f7ad"></a>

## ReceiptFinishOptions

<a id="api-a4749e8b9f0e1acedc93"></a>

### ReceiptFinishOptions

小票结束留白、切纸与作用范围。

```swift
struct ReceiptFinishOptions
```

默认零留白、不切纸、eachCopy。只保存选项，Manager构建和提交判断有效性；当前切纸和endOfJob范围尚不支持，不能静默忽略。

文档 ID：`apple:symbol:s:10PrinterSDK20ReceiptFinishOptionsV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-146d593bdf6bbf7c6947"></a>

### ReceiptFinishOptions.cut

切纸方式，默认none；full/partial当前提交返回不支持。

```swift
let cut: CutMode
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK20ReceiptFinishOptionsV3cutAA7CutModeOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CutMode | `s:10PrinterSDK7CutModeO` |

<a id="api-e8935bf12ba754426517"></a>

### ReceiptFinishOptions.init(trailingBlankDots:cut:scope:)

保存ReceiptFinishOptions的不可变作业参数。

```swift
init(trailingBlankDots: UInt32 = 0, cut: CutMode = .none, scope: FinishScope = .eachCopy)
```

默认零留白、不切纸、eachCopy。只保存选项，Manager构建和提交判断有效性；当前切纸和endOfJob范围尚不支持，不能静默忽略。 此初始化不执行IO，也不提前证明参数或硬件支持；实际校验在Manager准备后的native构建与准入进行。

文档 ID：`apple:symbol:s:10PrinterSDK20ReceiptFinishOptionsV17trailingBlankDots3cut5scopeACs6UInt32V_AA7CutModeOAA0D5ScopeOtcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| CutMode | `s:10PrinterSDK7CutModeO` |
| FinishScope | `s:10PrinterSDK11FinishScopeO` |
| UInt32 | `s:s6UInt32V` |

<a id="api-e299c0399f12e84fa692"></a>

### ReceiptFinishOptions.scope

结束作用范围，默认eachCopy；endOfJob当前后端不支持。

```swift
let scope: FinishScope
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK20ReceiptFinishOptionsV5scopeAA0D5ScopeOvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| FinishScope | `s:10PrinterSDK11FinishScopeO` |

<a id="api-d04d8f4bdcdb75182b55"></a>

### ReceiptFinishOptions.trailingBlankDots

结束留白（点），默认0，计入整单预算。

```swift
let trailingBlankDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK20ReceiptFinishOptionsV17trailingBlankDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-082376dfdfb0bb2ec7b4"></a>

## ReceiptJobOptions

<a id="api-3fbbb8e14aedd2ed7caf"></a>

### ReceiptJobOptions

小票作业的不可变累计长度预算。

```swift
struct ReceiptJobOptions
```

只保存参数，Manager构建和提交校验；width/DPI/整单预算大于零，copies为1..100。maxTotalLengthDots包含全部副本和结束留白，不是设备单页上限；当前后端不支持非零边距。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-8d43204aab1591945c81"></a>

### ReceiptJobOptions.copies

份数，默认1、范围1..100。

```swift
let copies: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV6copiess6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-233a665f6be45d09017b"></a>

### ReceiptJobOptions.dpi

小票横纵DPI。

```swift
let dpi: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV3dpis6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-799061c2c571da06d642"></a>

### ReceiptJobOptions.init(widthDots:maxTotalLengthDots:dpi:copies:marginLeftDots:marginRightDots:)

保存ReceiptJobOptions的不可变作业参数。

```swift
init(widthDots: UInt32, maxTotalLengthDots: UInt32, dpi: UInt32, copies: UInt32 = 1, marginLeftDots: UInt32 = 0, marginRightDots: UInt32 = 0)
```

只保存参数，Manager构建和提交校验；width/DPI/整单预算大于零，copies为1..100。maxTotalLengthDots包含全部副本和结束留白，不是设备单页上限；当前后端不支持非零边距。 此初始化不执行IO，也不提前证明参数或硬件支持；实际校验在Manager准备后的native构建与准入进行。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV9widthDots014maxTotalLengthG03dpi6copies010marginLeftG00m5RightG0ACs6UInt32V_A5Ktcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-4a91c1efdeef2b1c3bfd"></a>

### ReceiptJobOptions.marginLeftDots

左边距（点），当前后端要求0。

```swift
let marginLeftDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV14marginLeftDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-351109631333ae6a55bd"></a>

### ReceiptJobOptions.marginRightDots

右边距（点），当前后端要求0。

```swift
let marginRightDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV15marginRightDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-4aaa73a85e092d7d72d7"></a>

### ReceiptJobOptions.maxTotalLengthDots

全部副本与结束留白的累计长度预算（点）。

```swift
let maxTotalLengthDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV18maxTotalLengthDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-385b6fe9d8c77250cadb"></a>

### ReceiptJobOptions.widthDots

小票打印宽度（点）。

```swift
let widthDots: UInt32
```

初始化后不可变；属于作业参数而非连接默认配置，最终有效性由Manager构建和提交校验。

文档 ID：`apple:symbol:s:10PrinterSDK17ReceiptJobOptionsV9widthDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-8a4489e38f48eaabb599"></a>

## ReceiptProfile

<a id="api-5a5eb09c3d6917fdc589"></a>

### ReceiptProfile

不可变的 ESC/POS 小票分辨率和版心点宽配置。

```swift
struct ReceiptProfile
```

由应用明确提供，硬件最大页长和切刀能力仍未知；不以小票毫米宽度推断打印点宽。整单长度预算在 `submitReceiptGray8(maxTotalLengthDots:)` 中独立提供。构造不进行连接、IO 或硬件认证。 可作为本次操作参数传入，不需要在连接时提供，也不会改变连接或其他操作。

文档 ID：`apple:symbol:s:10PrinterSDK14ReceiptProfileV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-83facab82caf055f4700"></a>

### ReceiptProfile.dpi

小票内容使用的明确分辨率。

```swift
let dpi: UInt32
```

单位 dots per inch，构造接受 1…255。该值来自调用方而非设备读回，应用须按实际打印头参数配置。

文档 ID：`apple:symbol:s:10PrinterSDK14ReceiptProfileV3dpis6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-02f3341679870e3a5030"></a>

### ReceiptProfile.init(dpi:widthDots:)

校验并保存显式小票配置。

```swift
init(dpi: UInt32, widthDots: UInt32) throws
```

`dpi` 为 1…255，单位 dots per inch；`widthDots` 大于 0、不超过 7992 且为 8 的整数倍，单位点。无默认参数；违反条件抛 1001。只保存配置，不自动检测纸宽、页长、协议或切刀；设备初始化和实际提交仍有独立校验。

文档 ID：`apple:symbol:s:10PrinterSDK14ReceiptProfileV3dpi9widthDotsACs6UInt32V_AGtKcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-03511eb7a7b8b538d8f8"></a>

### ReceiptProfile.widthDots

小票作业的可打印版心宽度。

```swift
let widthDots: UInt32
```

单位为点；构造要求 1…7992 且为 8 的整数倍。当前图像以此作为横向边界，不静默缩放或裁剪超宽输入。它不代表介质毫米宽度、每份最大长度或切刀能力。

文档 ID：`apple:symbol:s:10PrinterSDK14ReceiptProfileV9widthDotss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-98f79d03f589f3f1383b"></a>

## RequestID

<a id="api-1f4163eebc83ddaebea0"></a>

### RequestID

仅由原Manager识别的不透明请求标识。

```swift
struct RequestID
```

将该值交给返回它的Manager.cancel请求取消；标识本身不持有native任务句柄，也不提供独立打印控制入口。

文档 ID：`apple:symbol:s:10PrinterSDK9RequestIDV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-27a4a4298443bc685dd7"></a>

### RequestID.!=(_:_:)

比较两个只读值是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

由编译器依据类型的Equatable语义合成；比较不访问设备，不创建打印请求。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK9RequestIDV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-313c383cb33723929d18"></a>

## SDKInfo

<a id="api-b963dd90e312ec5418c9"></a>

### SDKInfo

实际加载原生运行库的身份。

```swift
struct SDKInfo
```

由原生 C ABI 返回版本和构建身份，与 Demo BuildConfig 独立。生产 CMake 将原生版本、分发 VERSION 和源输入 SHA-256 编入库；缺失构建身份明确未知。该信息不证明签名、发布或硬件兼容。

文档 ID：`apple:symbol:s:10PrinterSDK7SDKInfoV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-3640fc8aa15d95ee1c79"></a>

### SDKInfo.!=(_:_:)

按值比较两个 SDKInfo 是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift Equatable 提供的比较，不执行 IO、不刷新状态。比较本次值或枚举，不能把相等的快照当作设备仍在线、硬件正常或纸面打印完成的证明。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK7SDKInfoV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-9babe8011e2c916ddfaa"></a>

### SDKInfo.abiRevision

实际加载库的ABI修订号。

```swift
let abiRevision: UInt32
```

当前包装要求ABI3且修订至少1；版本来自实际加载库，不是Demo资源。

文档 ID：`apple:symbol:s:10PrinterSDK7SDKInfoV11abiRevisions6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-d86873128ef22ecdf11c"></a>

### SDKInfo.abiVersion

实际加载库的ABI主版本。

```swift
let abiVersion: UInt32
```

当前为3，须与本包装一致；ABI2不能混用，必须成套更换头、库和平台包装。

文档 ID：`apple:symbol:s:10PrinterSDK7SDKInfoV10abiVersions6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-00f428edf3dc4b9c681e"></a>

### SDKInfo.buildID

可选原生源构建 SHA-256 标识。

```swift
let buildID: String?
```

未知时为 nil。生产 CMake 对受审定原生源和构建文件白名单计算，不包含 Git dirty、主机路径、环境或私有配置；不等同于完整二进制哈希。

文档 ID：`apple:symbol:s:10PrinterSDK7SDKInfoV7buildIDSSSgvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-9fa418f7057af6a2344f"></a>

### SDKInfo.distributionVersion

构建库时嵌入的分发版本。

```swift
let distributionVersion: String
```

生产 CMake 来源于 VERSION；未嵌入时为空字符串，不猜测或继承 Demo 版本。

文档 ID：`apple:symbol:s:10PrinterSDK7SDKInfoV19distributionVersionSSvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-7a66a92b85f58e9fa84d"></a>

### SDKInfo.nativeVersion

实际加载原生SDK的语义版本。

```swift
let nativeVersion: String
```

生产CMake来源于PROJECT_VERSION，当前0.3.0；SwiftPM源码构建使用同版只读fallback。此值不表示已发布或硬件验收。

文档 ID：`apple:symbol:s:10PrinterSDK7SDKInfoV13nativeVersionSSvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| String | `s:SS` |

<a id="api-5c2f7f6243349bf78f99"></a>

## ScalarConstraint

<a id="api-4aa08db4f6b0bb842bd5"></a>

### ScalarConstraint

不可变标量约束及依据。

```swift
struct ScalarConstraint
```

parameterId 指定约束，known=false 表示未知，不能解释为无限制。源载荷约束来自 SDK 接纳策略；协议几何或硬件支持仍须使用相应配置和能力证据。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-f47a4d2402a65d0762e8"></a>

### ScalarConstraint.!=(_:_:)

按值比较两个 ScalarConstraint 是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift Equatable 提供的比较，不执行 IO、不刷新状态。比较本次值或枚举，不能把相等的快照当作设备仍在线、硬件正常或纸面打印完成的证明。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK16ScalarConstraintV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-350f4bf05e3c6634e8fd"></a>

### ScalarConstraint.evidence

范围的证据来源。

```swift
let evidence: UInt32
```

区分 SDK 接纳策略、协议定义及其他证据，不能把 SDK 限制解释为已验证硬件能力。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV8evidences6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-cbf34d5c1705b3a3f4b2"></a>

### ScalarConstraint.isKnown

此约束是否有可靠已知范围。

```swift
let isKnown: Bool
```

false 时 minimum、maximum、step 不能解释为无限制或硬件保证。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV7isKnownSbvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-7fd038757eba6b305b57"></a>

### ScalarConstraint.maximum

已知约束的闭区间最大值。

```swift
let maximum: Int32
```

单位由 parameterId 决定；仅 known=true 时有意义。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV7maximums5Int32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-0d3fcd23d2d40d84f9ae"></a>

### ScalarConstraint.minimum

已知约束的闭区间最小值。

```swift
let minimum: Int32
```

单位由 parameterId 决定；仅 known=true 时有意义。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV7minimums5Int32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Int32 | `s:s5Int32V` |

<a id="api-ea4f31b903b4fdfb80db"></a>

### ScalarConstraint.parameter

本快照的约束参数标识。

```swift
let parameter: PrinterConstraint
```

使用 COPIES、MEDIA_GAP_UM、JOB_IMAGE_BYTES 或 PENDING_PAYLOAD_BYTES 查询；未知标识返回已知位为 false 的约束。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV9parameterAA0aD0Ovp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| PrinterConstraint | `s:10PrinterSDK0A10ConstraintO` |

<a id="api-d26a0e2876b56d2d5331"></a>

### ScalarConstraint.step

已知约束的取值步长。

```swift
let step: UInt32
```

在 minimum 起点按此步长取值；仅 known=true 时有意义。

文档 ID：`apple:symbol:s:10PrinterSDK16ScalarConstraintV4steps6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-4b76054d7c5874efb333"></a>

## StatusQueryConfiguration

<a id="api-ae4e3d4063252a2520f5"></a>

### StatusQueryConfiguration

逐次硬件状态查询配置。

```swift
struct StatusQueryConfiguration
```

与打印几何、纸宽和 DPI 独立，接纳时复制，不改变连接默认值。通过参数和生命周期校验后，标准 CPCL/ESC/POS 后端因不支持状态查询而拒绝时，`queryStatus` 通过主线程完成回调异步返回 1004 UNSUPPORTED_OPERATION，不执行打印机 IO。未连接、已关闭或参数非法等情况仍返回相应校验错误；硬件状态仍未知。

文档 ID：`apple:symbol:s:10PrinterSDK24StatusQueryConfigurationV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-dab1f65c670e0e9b0329"></a>

### StatusQueryConfiguration.!=(_:_:)

按值比较两个 StatusQueryConfiguration 是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

Swift Equatable 提供的比较，不执行 IO、不刷新状态。比较本次值或枚举，不能把相等的快照当作设备仍在线、硬件正常或纸面打印完成的证明。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK24StatusQueryConfigurationV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-74892691e3057eed07a0"></a>

### StatusQueryConfiguration.init(printerProtocol:queryTimeoutMilliseconds:)

创建本次状态查询配置。

```swift
init(printerProtocol: PrinterProtocol, queryTimeoutMilliseconds: UInt32 = 5000) throws
```

printerProtocol 显式选择 .cpcl 或 .escpos；queryTimeoutMilliseconds 默认 5000 毫秒，须大于 0，零值抛 PrinterSDKError code 1001。构造不执行 IO，不要求打印几何；选择协议不证明目标固件支持状态命令。

文档 ID：`apple:symbol:s:10PrinterSDK24StatusQueryConfigurationV15printerProtocol24queryTimeoutMillisecondsAcA0aG0O_s6UInt32VtKcfc`

符号种类：`swift.init`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| PrinterProtocol | `s:10PrinterSDK0A8ProtocolO` |
| UInt32 | `s:s6UInt32V` |

<a id="api-db6c8f80b95aadcc9848"></a>

### StatusQueryConfiguration.printerProtocol

本次状态查询选择的协议。

```swift
let printerProtocol: PrinterProtocol
```

只接受 CPCL=1 或 ESC_POS=2；选择协议不证明目标固件支持状态读回。

文档 ID：`apple:symbol:s:10PrinterSDK24StatusQueryConfigurationV15printerProtocolAA0aG0Ovp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| PrinterProtocol | `s:10PrinterSDK0A8ProtocolO` |

<a id="api-34db23365fe06623acb1"></a>

### StatusQueryConfiguration.queryTimeoutMilliseconds

本次请求／响应事务的超时预算。

```swift
let queryTimeoutMilliseconds: UInt32
```

必须大于 0，单位毫秒；与 queryStatus 的排队及操作总预算分别设置，不能据此绕过总预算。

文档 ID：`apple:symbol:s:10PrinterSDK24StatusQueryConfigurationV24queryTimeoutMillisecondss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-498d0aa8573deb1c5df3"></a>

## StatusResult

<a id="api-29137902e8f73010baa0"></a>

### StatusResult

查询得到的硬件状态值。

```swift
struct StatusResult
```

knownConditions指明哪些状态位已知，activeConditions只在相应已知位内有意义；不得把未知位解释为正常，也不能从状态查询推断某次任务已打印完成。

文档 ID：`apple:symbol:s:10PrinterSDK12StatusResultV`

符号种类：`swift.struct`；访问级别：`public`。

<a id="api-0ade4684fd8aff05bb46"></a>

### StatusResult.!=(_:_:)

比较两个只读值是否不同。

```swift
static func != (lhs: borrowing Self, rhs: borrowing Self) -> Bool
```

由编译器依据类型的Equatable语义合成；比较不访问设备，不创建打印请求。

文档 ID：`apple:symbol:s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK12StatusResultV`

符号种类：`swift.func.op`；访问级别：`public`。

这是编译器为当前类型带入的协议扩展／合成公共成员。

扩展来源（保留基线原值）：

```json
{"extendedModule":"Swift","typeKind":"swift.protocol"}
```

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| Bool | `s:Sb` |

<a id="api-446dfe1371a118f39c0e"></a>

### StatusResult.activeConditions

已激活的硬件条件位。

```swift
let activeConditions: UInt32
```

与knownConditions组合读取，不能单独将零值解释为所有硬件条件正常。

文档 ID：`apple:symbol:s:10PrinterSDK12StatusResultV16activeConditionss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-23c61d3883ee5c091d8d"></a>

### StatusResult.evidence

状态值的证据类型。

```swift
let evidence: UInt32
```

遵循状态查询契约解释；不代表指定打印请求已设备确认完成。

文档 ID：`apple:symbol:s:10PrinterSDK12StatusResultV8evidences6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-59f03638dab29ef80c75"></a>

### StatusResult.knownConditions

硬件状态中已知的条件位。

```swift
let knownConditions: UInt32
```

只有对应位为已知时，才可解释activeConditions中的该状态；未知不是正常。

文档 ID：`apple:symbol:s:10PrinterSDK12StatusResultV15knownConditionss6UInt32Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt32 | `s:s6UInt32V` |

<a id="api-284c156755426b07f0df"></a>

### StatusResult.sampledMonotonicMilliseconds

状态采样的单调时钟毫秒值。

```swift
let sampledMonotonicMilliseconds: UInt64
```

仅用于同一时钟域内的相对先后或时效判断，不是UTC时间戳。

文档 ID：`apple:symbol:s:10PrinterSDK12StatusResultV28sampledMonotonicMillisecondss6UInt64Vvp`

符号种类：`swift.property`；访问级别：`public`。

声明引用的编译器标识：

| 名称 | precise identifier |
| --- | --- |
| UInt64 | `s:s6UInt64V` |

## 枚举声明顺序与 raw 值

顺序来自编译器 AST；raw 值保留符号、类型和值，不用展示顺序代替 raw 值。

### CompletionLevel

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `none` | `0` | `{"kind":"integer","negative":false,"value":"0"}` |
| 1 | `dataSent` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 2 | `deviceConfirmed` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |

### CutMode

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `none` | `0` | `{"kind":"integer","negative":false,"value":"0"}` |
| 1 | `full` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 2 | `partial` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |

### FinishScope

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `eachCopy` | `0` | `{"kind":"integer","negative":false,"value":"0"}` |
| 1 | `endOfJob` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |

### ImageAlgorithm

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `threshold` | `0` | `{"kind":"integer","negative":false,"value":"0"}` |
| 1 | `floydSteinberg` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 2 | `bayer4x4` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |
| 3 | `bayer8x8` | `3` | `{"kind":"integer","negative":false,"value":"3"}` |

### ManagerOutcome

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `success` | `无 raw 值` | `null` |
| 1 | `failure` | `无 raw 值` | `null` |
| 2 | `cancelled` | `无 raw 值` | `null` |

### MediaMode

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `gap` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 1 | `blackMark` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |
| 2 | `continuous` | `3` | `{"kind":"integer","negative":false,"value":"3"}` |

### MediaPersistencePolicy

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `volatileOnly` | `0` | `{"kind":"integer","negative":false,"value":"0"}` |
| 1 | `allowPersistent` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |

### MediaVerificationPolicy

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `allowLastSent` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 1 | `requireReadback` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |

### PixelFormat

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `gray8` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 1 | `rgb24` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |
| 2 | `rgba32` | `3` | `{"kind":"integer","negative":false,"value":"3"}` |

### PrintElement

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `image(_:x:y:)` | `无 raw 值` | `null` |
| 1 | `blank(dots:)` | `无 raw 值` | `null` |

### PrinterConstraint

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `copies` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 1 | `mediaGapMicrometers` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |
| 2 | `jobImageBytes` | `3` | `{"kind":"integer","negative":false,"value":"3"}` |
| 3 | `pendingPayloadBytes` | `4` | `{"kind":"integer","negative":false,"value":"4"}` |

### PrinterFeature

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `label` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 1 | `receipt` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |
| 2 | `status` | `3` | `{"kind":"integer","negative":false,"value":"3"}` |
| 3 | `media` | `4` | `{"kind":"integer","negative":false,"value":"4"}` |
| 4 | `cut` | `5` | `{"kind":"integer","negative":false,"value":"5"}` |
| 5 | `raw` | `6` | `{"kind":"integer","negative":false,"value":"6"}` |
| 6 | `image` | `7` | `{"kind":"integer","negative":false,"value":"7"}` |
| 7 | `feedToNextLabel` | `8` | `{"kind":"integer","negative":false,"value":"8"}` |

### PrinterProtocol

| 声明顺序（从 0 起） | case | raw 值 | 编译器原值 |
| --- | --- | --- | --- |
| 0 | `cpcl` | `1` | `{"kind":"integer","negative":false,"value":"1"}` |
| 1 | `escpos` | `2` | `{"kind":"integer","negative":false,"value":"2"}` |

## 编译器公共关系

完整保留 **359** 条继承、协议遵循、成员及合成关系；
source 和 target 使用精确编译器标识，外部 Swift/Foundation 类型也保持原值。

| kind | source | target | 其他编译器字段 |
| --- | --- | --- | --- |
| `conformsTo` | `s:10PrinterSDK010DiscoveredA0V` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK010DiscoveredA0V` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A10ConstraintO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A10ConstraintO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A10ConstraintO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A10ConstraintO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A10ConstraintO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A12CapabilitiesV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A12CapabilitiesV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7FeatureO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7FeatureO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7FeatureO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7FeatureO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7FeatureO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7ManagerC` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A7ManagerC` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8GeometryV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8GeometryV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8GeometryV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8ProtocolO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8ProtocolO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8ProtocolO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8ProtocolO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8ProtocolO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8SDKErrorV` | `s:10Foundation14LocalizedErrorP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8SDKErrorV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8SDKErrorV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8SDKErrorV` | `s:s5ErrorP` | `{}` |
| `conformsTo` | `s:10PrinterSDK0A8SDKErrorV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK10BLEOptionsV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK10BLEOptionsV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK11CpclProfileV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK11CpclProfileV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK11FinishScopeO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK11FinishScopeO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK11FinishScopeO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK11FinishScopeO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK11FinishScopeO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK11PixelFormatO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK11PixelFormatO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK11PixelFormatO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK11PixelFormatO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK11PixelFormatO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK12PrintElementO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK12PrintElementO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK12PrintOptionsV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK12PrintOptionsV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK12StatusResultV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK12StatusResultV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK12StatusResultV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK13ManagerResultV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK13ManagerResultV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK13MediaSettingsV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK13MediaSettingsV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK13PreparedPrintV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK13PreparedPrintV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14FeatureSupportV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK14FeatureSupportV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14FeatureSupportV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ImageAlgorithmO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ImageAlgorithmO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ImageAlgorithmO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ImageAlgorithmO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ImageAlgorithmO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ManagerOutcomeO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ManagerOutcomeO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ManagerOutcomeO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ManagerOutcomeO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ReceiptProfileV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK14ReceiptProfileV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK15CompletionLevelO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK15CompletionLevelO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK15CompletionLevelO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK15CompletionLevelO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK15CompletionLevelO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK15LabelJobOptionsV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK15LabelJobOptionsV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK16MediaRequirementV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK16MediaRequirementV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK16ScalarConstraintV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK16ScalarConstraintV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK16ScalarConstraintV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK17ReceiptJobOptionsV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK17ReceiptJobOptionsV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK19CancellationContextC` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK19CancellationContextC` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK20BLECreditFlowControlV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK20BLECreditFlowControlV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK20ReceiptFinishOptionsV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK20ReceiptFinishOptionsV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK22MediaPersistencePolicyO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK22MediaPersistencePolicyO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK22MediaPersistencePolicyO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK22MediaPersistencePolicyO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK22MediaPersistencePolicyO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK23MediaVerificationPolicyO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK23MediaVerificationPolicyO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK23MediaVerificationPolicyO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK23MediaVerificationPolicyO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK23MediaVerificationPolicyO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK24StatusQueryConfigurationV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK24StatusQueryConfigurationV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK24StatusQueryConfigurationV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK6PixelsC` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK6PixelsC` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK7CutModeO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK7CutModeO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK7CutModeO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK7CutModeO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK7CutModeO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK7SDKInfoV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK7SDKInfoV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK7SDKInfoV` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK9MediaModeO` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK9MediaModeO` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK9MediaModeO` | `s:SY` | `{}` |
| `conformsTo` | `s:10PrinterSDK9MediaModeO` | `s:s12CaseIterableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK9MediaModeO` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK9MediaModeO` | `s:s8SendableP` | `{}` |
| `conformsTo` | `s:10PrinterSDK9RequestIDV` | `s:SH` | `{}` |
| `conformsTo` | `s:10PrinterSDK9RequestIDV` | `s:SQ` | `{}` |
| `conformsTo` | `s:10PrinterSDK9RequestIDV` | `s:s16SendableMetatypeP` | `{}` |
| `conformsTo` | `s:10PrinterSDK9RequestIDV` | `s:s8SendableP` | `{}` |
| `memberOf` | `s:10Foundation14LocalizedErrorPAAE10helpAnchorSSSgvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"LocalizedError.helpAnchor","identifier":"s:10Foundation14LocalizedErrorP10helpAnchorSSSgvp"}}` |
| `memberOf` | `s:10Foundation14LocalizedErrorPAAE13failureReasonSSSgvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"LocalizedError.failureReason","identifier":"s:10Foundation14LocalizedErrorP13failureReasonSSSgvp"}}` |
| `memberOf` | `s:10Foundation14LocalizedErrorPAAE18recoverySuggestionSSSgvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"LocalizedError.recoverySuggestion","identifier":"s:10Foundation14LocalizedErrorP18recoverySuggestionSSSgvp"}}` |
| `memberOf` | `s:10PrinterSDK010DiscoveredA0V10identifier10Foundation4UUIDVvp` | `s:10PrinterSDK010DiscoveredA0V` | `{}` |
| `memberOf` | `s:10PrinterSDK010DiscoveredA0V18advertisedServicesSaySSGvp` | `s:10PrinterSDK010DiscoveredA0V` | `{}` |
| `memberOf` | `s:10PrinterSDK010DiscoveredA0V4nameSSSgvp` | `s:10PrinterSDK010DiscoveredA0V` | `{}` |
| `memberOf` | `s:10PrinterSDK010DiscoveredA0V4rssiSivp` | `s:10PrinterSDK010DiscoveredA0V` | `{}` |
| `memberOf` | `s:10PrinterSDK0A10ConstraintO13jobImageBytesyA2CmF` | `s:10PrinterSDK0A10ConstraintO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A10ConstraintO19mediaGapMicrometersyA2CmF` | `s:10PrinterSDK0A10ConstraintO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A10ConstraintO19pendingPayloadBytesyA2CmF` | `s:10PrinterSDK0A10ConstraintO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A10ConstraintO6copiesyA2CmF` | `s:10PrinterSDK0A10ConstraintO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A10ConstraintO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK0A10ConstraintO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK0A12CapabilitiesV11constraintsSDyAA0A10ConstraintOAA06ScalarE0VGvp` | `s:10PrinterSDK0A12CapabilitiesV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A12CapabilitiesV8featuresSDyAA0A7FeatureOAA0E7SupportVGvp` | `s:10PrinterSDK0A12CapabilitiesV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A12CapabilitiesV8geometryAA0A8GeometryVvp` | `s:10PrinterSDK0A12CapabilitiesV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO15feedToNextLabelyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO3cutyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO3rawyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO5imageyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO5labelyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO5mediayA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO6statusyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO7receiptyA2CmF` | `s:10PrinterSDK0A7FeatureO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7FeatureO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK0A7FeatureO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC10disconnect10completionAA9RequestIDVyAA0C6ResultVyytGYbScMYcc_tF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC11queryStatus13configuration19timeoutMilliseconds10completionAA9RequestIDVAA0E18QueryConfigurationV_s6UInt32VyAA0C6ResultVyAA0eO0VGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC12capabilities10completionAA9RequestIDVyAA0C6ResultVyAA0A12CapabilitiesVGYbScMYcc_tF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC12setMediaMode_7profile19timeoutMilliseconds10completionAA9RequestIDVAA0eF0O_AA11CpclProfileVs6UInt32VyAA0C6ResultVyytGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC13bondedDevices10completionAA9RequestIDVyAA0C6ResultVySayAA010DiscoveredA0VGGYbScMYcc_tF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC15feedToNextLabel7profile19timeoutMilliseconds10completionAA9RequestIDVAA11CpclProfileV_s6UInt32VyAA0C6ResultVyytGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC5close10completionAA9RequestIDVyAA0C6ResultVyytGYbScMYcc_tF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC5print7profile7options11preparation10completionAA9RequestIDVAA11CpclProfileV_AA12PrintOptionsVAA08PreparedM0VAA19CancellationContextCYbKcyAA0C6ResultVyytGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC5print7profile7options11preparation10completionAA9RequestIDVAA14ReceiptProfileV_AA12PrintOptionsVAA08PreparedM0VAA19CancellationContextCYbKcyAA0C6ResultVyytGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC6cancelyyAA9RequestIDVF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC7connect13bleIdentifier7options19timeoutMilliseconds10completion14onDisconnectedAA9RequestIDV10Foundation4UUIDV_AA10BLEOptionsVs6UInt32VyAA0C6ResultVyytGYbScMYccyAUYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC7scanBLE7seconds7service10completionAA9RequestIDVSd_10Foundation4UUIDVSgyAA0C6ResultVySayAA010DiscoveredA0VGGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC7sdkInfo10completionAA9RequestIDVyAA0C6ResultVyAA7SDKInfoVGYbScMYcc_tF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC7sendRaw_6copies19timeoutMilliseconds10completionAA9RequestIDV10Foundation4DataV_s6UInt32VANyAA0C6ResultVyytGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerC8setMedia_7profile19timeoutMilliseconds10completionAA9RequestIDVAA0E8SettingsV_AA11CpclProfileVs6UInt32VyAA0C6ResultVyytGYbScMYcctF` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A7ManagerCACycfc` | `s:10PrinterSDK0A7ManagerC` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8GeometryV15minCutBlankDotss6UInt32VSgvp` | `s:10PrinterSDK0A8GeometryV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8GeometryV17maxPageLengthDotss6UInt32VSgvp` | `s:10PrinterSDK0A8GeometryV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8GeometryV18printableWidthDotss6UInt32VSgvp` | `s:10PrinterSDK0A8GeometryV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8GeometryV4dpiXs6UInt32VSgvp` | `s:10PrinterSDK0A8GeometryV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8GeometryV4dpiYs6UInt32VSgvp` | `s:10PrinterSDK0A8GeometryV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8GeometryV8evidences6UInt32Vvp` | `s:10PrinterSDK0A8GeometryV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8ProtocolO4cpclyA2CmF` | `s:10PrinterSDK0A8ProtocolO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8ProtocolO6escposyA2CmF` | `s:10PrinterSDK0A8ProtocolO` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8ProtocolO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK0A8ProtocolO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK0A8SDKErrorV16errorDescriptionSSSgvp` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"LocalizedError.errorDescription","identifier":"s:10Foundation14LocalizedErrorP16errorDescriptionSSSgvp"}}` |
| `memberOf` | `s:10PrinterSDK0A8SDKErrorV2eeoiySbAC_ACtFZ` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"Equatable.==(_:_:)","identifier":"s:SQ2eeoiySbx_xtFZ"}}` |
| `memberOf` | `s:10PrinterSDK0A8SDKErrorV4codes5Int32Vvp` | `s:10PrinterSDK0A8SDKErrorV` | `{}` |
| `memberOf` | `s:10PrinterSDK0A8SDKErrorVyACs5Int32Vcfc` | `s:10PrinterSDK0A8SDKErrorV` | `{}` |
| `memberOf` | `s:10PrinterSDK10BLEOptionsV12withResponseSbvp` | `s:10PrinterSDK10BLEOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK10BLEOptionsV13maxWriteBytesSivp` | `s:10PrinterSDK10BLEOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK10BLEOptionsV17creditFlowControlAA09BLECrediteF0VSgvp` | `s:10PrinterSDK10BLEOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK10BLEOptionsV19writeCharacteristic10Foundation4UUIDVvp` | `s:10PrinterSDK10BLEOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK10BLEOptionsV7service10Foundation4UUIDVvp` | `s:10PrinterSDK10BLEOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK10BLEOptionsV7service19writeCharacteristic12withResponse13maxWriteBytes17creditFlowControlAC10Foundation4UUIDV_AKSbSiAA09BLECreditmN0VSgtKcfc` | `s:10PrinterSDK10BLEOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK10M90ProfileO10bleOptions13maxWriteBytesAA10BLEOptionsVSi_tKFZ` | `s:10PrinterSDK10M90ProfileO` | `{}` |
| `memberOf` | `s:10PrinterSDK11CpclProfileV11xOffsetDotss6UInt32Vvp` | `s:10PrinterSDK11CpclProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK11CpclProfileV18maxLabelHeightDotss6UInt32Vvp` | `s:10PrinterSDK11CpclProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK11CpclProfileV3dpi9widthDots014maxLabelHeightG04form07xOffsetG0ACs6UInt32V_A2JSbAJtKcfc` | `s:10PrinterSDK11CpclProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK11CpclProfileV3dpis6UInt32Vvp` | `s:10PrinterSDK11CpclProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK11CpclProfileV4formSbvp` | `s:10PrinterSDK11CpclProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK11CpclProfileV9widthDotss6UInt32Vvp` | `s:10PrinterSDK11CpclProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK11FinishScopeO8eachCopyyA2CmF` | `s:10PrinterSDK11FinishScopeO` | `{}` |
| `memberOf` | `s:10PrinterSDK11FinishScopeO8endOfJobyA2CmF` | `s:10PrinterSDK11FinishScopeO` | `{}` |
| `memberOf` | `s:10PrinterSDK11FinishScopeO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK11FinishScopeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK11PixelFormatO5gray8yA2CmF` | `s:10PrinterSDK11PixelFormatO` | `{}` |
| `memberOf` | `s:10PrinterSDK11PixelFormatO5rgb24yA2CmF` | `s:10PrinterSDK11PixelFormatO` | `{}` |
| `memberOf` | `s:10PrinterSDK11PixelFormatO6rgba32yA2CmF` | `s:10PrinterSDK11PixelFormatO` | `{}` |
| `memberOf` | `s:10PrinterSDK11PixelFormatO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK11PixelFormatO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK12PrintElementO5blankyACs6UInt32V_tcACmF` | `s:10PrinterSDK12PrintElementO` | `{}` |
| `memberOf` | `s:10PrinterSDK12PrintElementO5imageyAcA6PixelsC_s5Int32VAHtcACmF` | `s:10PrinterSDK12PrintElementO` | `{}` |
| `memberOf` | `s:10PrinterSDK12PrintOptionsV19timeoutMillisecondsACs6UInt32V_tcfc` | `s:10PrinterSDK12PrintOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK12PrintOptionsV19timeoutMillisecondss6UInt32Vvp` | `s:10PrinterSDK12PrintOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK12StatusResultV15knownConditionss6UInt32Vvp` | `s:10PrinterSDK12StatusResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK12StatusResultV16activeConditionss6UInt32Vvp` | `s:10PrinterSDK12StatusResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK12StatusResultV28sampledMonotonicMillisecondss6UInt64Vvp` | `s:10PrinterSDK12StatusResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK12StatusResultV8evidences6UInt32Vvp` | `s:10PrinterSDK12StatusResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV10completionAA15CompletionLevelOvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV21outputMayHaveOccurredSbvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV4codes5Int32Vvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV5valuexSgvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV7messageSSvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV7outcomeAA0C7OutcomeOvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV9isSuccessSbvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13ManagerResultV9requestIDAA07RequestF0Vvp` | `s:10PrinterSDK13ManagerResultV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV11persistenceAA0C17PersistencePolicyOvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV16widthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV20gapLengthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV21markLengthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV21markOffsetMicrometerss5Int32VSgvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV22labelLengthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV8tracking16widthMicrometers011labelLengthG003gapiG004markiG00k6OffsetG011persistenceAcA0C4ModeOSg_s6UInt32VSgA3Ps5Int32VSgAA0C17PersistencePolicyOtcfc` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13MediaSettingsV8trackingAA0C4ModeOSgvp` | `s:10PrinterSDK13MediaSettingsV` | `{}` |
| `memberOf` | `s:10PrinterSDK13PreparedPrintV5label8elements16mediaRequirementAcA15LabelJobOptionsV_SayAA0D7ElementOGAA05MediaH0VSgtcfc` | `s:10PrinterSDK13PreparedPrintV` | `{}` |
| `memberOf` | `s:10PrinterSDK13PreparedPrintV7receipt8elements6finish16mediaRequirementAcA17ReceiptJobOptionsV_SayAA0D7ElementOGAA0j6FinishL0VAA05MediaI0VSgtcfc` | `s:10PrinterSDK13PreparedPrintV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV06deviceD0s6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV11isSupportedSbvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV11knownFieldss6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV13isImplementedSbvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV14implementations6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV14requiredFieldss6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV15supportedFieldss6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV15supportedValuess6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14FeatureSupportV8evidences6UInt32Vvp` | `s:10PrinterSDK14FeatureSupportV` | `{}` |
| `memberOf` | `s:10PrinterSDK14ImageAlgorithmO14floydSteinbergyA2CmF` | `s:10PrinterSDK14ImageAlgorithmO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ImageAlgorithmO8bayer4x4yA2CmF` | `s:10PrinterSDK14ImageAlgorithmO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ImageAlgorithmO8bayer8x8yA2CmF` | `s:10PrinterSDK14ImageAlgorithmO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ImageAlgorithmO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK14ImageAlgorithmO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK14ImageAlgorithmO9thresholdyA2CmF` | `s:10PrinterSDK14ImageAlgorithmO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ManagerOutcomeO7failureyA2CmF` | `s:10PrinterSDK14ManagerOutcomeO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ManagerOutcomeO7successyA2CmF` | `s:10PrinterSDK14ManagerOutcomeO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ManagerOutcomeO9cancelledyA2CmF` | `s:10PrinterSDK14ManagerOutcomeO` | `{}` |
| `memberOf` | `s:10PrinterSDK14ReceiptProfileV3dpi9widthDotsACs6UInt32V_AGtKcfc` | `s:10PrinterSDK14ReceiptProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK14ReceiptProfileV3dpis6UInt32Vvp` | `s:10PrinterSDK14ReceiptProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK14ReceiptProfileV9widthDotss6UInt32Vvp` | `s:10PrinterSDK14ReceiptProfileV` | `{}` |
| `memberOf` | `s:10PrinterSDK15CompletionLevelO15deviceConfirmedyA2CmF` | `s:10PrinterSDK15CompletionLevelO` | `{}` |
| `memberOf` | `s:10PrinterSDK15CompletionLevelO4noneyA2CmF` | `s:10PrinterSDK15CompletionLevelO` | `{}` |
| `memberOf` | `s:10PrinterSDK15CompletionLevelO8dataSentyA2CmF` | `s:10PrinterSDK15CompletionLevelO` | `{}` |
| `memberOf` | `s:10PrinterSDK15CompletionLevelO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK15CompletionLevelO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV10heightDotss6UInt32Vvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV11originXDotss5Int32Vvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV11originYDotss5Int32Vvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV3dpis6UInt32Vvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV4formSbvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV6copiess6UInt32Vvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV9widthDots06heightG03dpi11originXDots0J5YDots6copies4formACs6UInt32V_A2Ls5Int32VAnLSbtcfc` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK15LabelJobOptionsV9widthDotss6UInt32Vvp` | `s:10PrinterSDK15LabelJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV12verificationAA0C18VerificationPolicyOvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV16widthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV20gapLengthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV21markLengthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV21markOffsetMicrometerss5Int32VSgvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV22labelLengthMicrometerss6UInt32VSgvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV8tracking16widthMicrometers011labelLengthG003gapiG004markiG00k6OffsetG012verificationAcA0C4ModeOSg_s6UInt32VSgA3Ps5Int32VSgAA0C18VerificationPolicyOtcfc` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16MediaRequirementV8trackingAA0C4ModeOSgvp` | `s:10PrinterSDK16MediaRequirementV` | `{}` |
| `memberOf` | `s:10PrinterSDK16ScalarConstraintV4steps6UInt32Vvp` | `s:10PrinterSDK16ScalarConstraintV` | `{}` |
| `memberOf` | `s:10PrinterSDK16ScalarConstraintV7isKnownSbvp` | `s:10PrinterSDK16ScalarConstraintV` | `{}` |
| `memberOf` | `s:10PrinterSDK16ScalarConstraintV7maximums5Int32Vvp` | `s:10PrinterSDK16ScalarConstraintV` | `{}` |
| `memberOf` | `s:10PrinterSDK16ScalarConstraintV7minimums5Int32Vvp` | `s:10PrinterSDK16ScalarConstraintV` | `{}` |
| `memberOf` | `s:10PrinterSDK16ScalarConstraintV8evidences6UInt32Vvp` | `s:10PrinterSDK16ScalarConstraintV` | `{}` |
| `memberOf` | `s:10PrinterSDK16ScalarConstraintV9parameterAA0aD0Ovp` | `s:10PrinterSDK16ScalarConstraintV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV14marginLeftDotss6UInt32Vvp` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV15marginRightDotss6UInt32Vvp` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV18maxTotalLengthDotss6UInt32Vvp` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV3dpis6UInt32Vvp` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV6copiess6UInt32Vvp` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV9widthDots014maxTotalLengthG03dpi6copies010marginLeftG00m5RightG0ACs6UInt32V_A5Ktcfc` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK17ReceiptJobOptionsV9widthDotss6UInt32Vvp` | `s:10PrinterSDK17ReceiptJobOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK19CancellationContextC05checkC0yyKF` | `s:10PrinterSDK19CancellationContextC` | `{}` |
| `memberOf` | `s:10PrinterSDK19CancellationContextC11isCancelledSbvp` | `s:10PrinterSDK19CancellationContextC` | `{}` |
| `memberOf` | `s:10PrinterSDK20BLECreditFlowControlV6dataFC10Foundation4UUIDVvp` | `s:10PrinterSDK20BLECreditFlowControlV` | `{}` |
| `memberOf` | `s:10PrinterSDK20BLECreditFlowControlV7dataOut0F2FCAC10Foundation4UUIDV_AHtcfc` | `s:10PrinterSDK20BLECreditFlowControlV` | `{}` |
| `memberOf` | `s:10PrinterSDK20BLECreditFlowControlV7dataOut10Foundation4UUIDVvp` | `s:10PrinterSDK20BLECreditFlowControlV` | `{}` |
| `memberOf` | `s:10PrinterSDK20ReceiptFinishOptionsV17trailingBlankDots3cut5scopeACs6UInt32V_AA7CutModeOAA0D5ScopeOtcfc` | `s:10PrinterSDK20ReceiptFinishOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK20ReceiptFinishOptionsV17trailingBlankDotss6UInt32Vvp` | `s:10PrinterSDK20ReceiptFinishOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK20ReceiptFinishOptionsV3cutAA7CutModeOvp` | `s:10PrinterSDK20ReceiptFinishOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK20ReceiptFinishOptionsV5scopeAA0D5ScopeOvp` | `s:10PrinterSDK20ReceiptFinishOptionsV` | `{}` |
| `memberOf` | `s:10PrinterSDK22MediaPersistencePolicyO12volatileOnlyyA2CmF` | `s:10PrinterSDK22MediaPersistencePolicyO` | `{}` |
| `memberOf` | `s:10PrinterSDK22MediaPersistencePolicyO15allowPersistentyA2CmF` | `s:10PrinterSDK22MediaPersistencePolicyO` | `{}` |
| `memberOf` | `s:10PrinterSDK22MediaPersistencePolicyO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK22MediaPersistencePolicyO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK23MediaVerificationPolicyO13allowLastSentyA2CmF` | `s:10PrinterSDK23MediaVerificationPolicyO` | `{}` |
| `memberOf` | `s:10PrinterSDK23MediaVerificationPolicyO15requireReadbackyA2CmF` | `s:10PrinterSDK23MediaVerificationPolicyO` | `{}` |
| `memberOf` | `s:10PrinterSDK23MediaVerificationPolicyO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK23MediaVerificationPolicyO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK24StatusQueryConfigurationV15printerProtocol24queryTimeoutMillisecondsAcA0aG0O_s6UInt32VtKcfc` | `s:10PrinterSDK24StatusQueryConfigurationV` | `{}` |
| `memberOf` | `s:10PrinterSDK24StatusQueryConfigurationV15printerProtocolAA0aG0Ovp` | `s:10PrinterSDK24StatusQueryConfigurationV` | `{}` |
| `memberOf` | `s:10PrinterSDK24StatusQueryConfigurationV24queryTimeoutMillisecondss6UInt32Vvp` | `s:10PrinterSDK24StatusQueryConfigurationV` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC15targetWidthDotss6UInt32Vvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC4data10Foundation4DataVvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC4data5width6height6format9algorithm9threshold6invert8fitWidth06targetL4DotsAC10Foundation4DataV_s6UInt32VAqA11PixelFormatOAA14ImageAlgorithmOAQS2bAQtcfc` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC5widths6UInt32Vvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC6formatAA11PixelFormatOvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC6heights6UInt32Vvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC6invertSbvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC8fitWidthSbvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC9algorithmAA14ImageAlgorithmOvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK6PixelsC9thresholds6UInt32Vvp` | `s:10PrinterSDK6PixelsC` | `{}` |
| `memberOf` | `s:10PrinterSDK7CutModeO4fullyA2CmF` | `s:10PrinterSDK7CutModeO` | `{}` |
| `memberOf` | `s:10PrinterSDK7CutModeO4noneyA2CmF` | `s:10PrinterSDK7CutModeO` | `{}` |
| `memberOf` | `s:10PrinterSDK7CutModeO7partialyA2CmF` | `s:10PrinterSDK7CutModeO` | `{}` |
| `memberOf` | `s:10PrinterSDK7CutModeO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK7CutModeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK7SDKInfoV10abiVersions6UInt32Vvp` | `s:10PrinterSDK7SDKInfoV` | `{}` |
| `memberOf` | `s:10PrinterSDK7SDKInfoV11abiRevisions6UInt32Vvp` | `s:10PrinterSDK7SDKInfoV` | `{}` |
| `memberOf` | `s:10PrinterSDK7SDKInfoV13nativeVersionSSvp` | `s:10PrinterSDK7SDKInfoV` | `{}` |
| `memberOf` | `s:10PrinterSDK7SDKInfoV19distributionVersionSSvp` | `s:10PrinterSDK7SDKInfoV` | `{}` |
| `memberOf` | `s:10PrinterSDK7SDKInfoV7buildIDSSSgvp` | `s:10PrinterSDK7SDKInfoV` | `{}` |
| `memberOf` | `s:10PrinterSDK9MediaModeO10continuousyA2CmF` | `s:10PrinterSDK9MediaModeO` | `{}` |
| `memberOf` | `s:10PrinterSDK9MediaModeO3gapyA2CmF` | `s:10PrinterSDK9MediaModeO` | `{}` |
| `memberOf` | `s:10PrinterSDK9MediaModeO8rawValueACSgs6UInt32V_tcfc` | `s:10PrinterSDK9MediaModeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.init(rawValue:)","identifier":"s:SY8rawValuexSg03RawB0Qz_tcfc"}}` |
| `memberOf` | `s:10PrinterSDK9MediaModeO9blackMarkyA2CmF` | `s:10PrinterSDK9MediaModeO` | `{}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A10ConstraintO` | `s:10PrinterSDK0A10ConstraintO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A7FeatureO` | `s:10PrinterSDK0A7FeatureO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A8GeometryV` | `s:10PrinterSDK0A8GeometryV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A8ProtocolO` | `s:10PrinterSDK0A8ProtocolO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK11FinishScopeO` | `s:10PrinterSDK11FinishScopeO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK11PixelFormatO` | `s:10PrinterSDK11PixelFormatO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK12StatusResultV` | `s:10PrinterSDK12StatusResultV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK14FeatureSupportV` | `s:10PrinterSDK14FeatureSupportV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK14ImageAlgorithmO` | `s:10PrinterSDK14ImageAlgorithmO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK14ManagerOutcomeO` | `s:10PrinterSDK14ManagerOutcomeO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK15CompletionLevelO` | `s:10PrinterSDK15CompletionLevelO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK16ScalarConstraintV` | `s:10PrinterSDK16ScalarConstraintV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK22MediaPersistencePolicyO` | `s:10PrinterSDK22MediaPersistencePolicyO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK23MediaVerificationPolicyO` | `s:10PrinterSDK23MediaVerificationPolicyO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK24StatusQueryConfigurationV` | `s:10PrinterSDK24StatusQueryConfigurationV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK7CutModeO` | `s:10PrinterSDK7CutModeO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK7SDKInfoV` | `s:10PrinterSDK7SDKInfoV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK9MediaModeO` | `s:10PrinterSDK9MediaModeO` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ::SYNTHESIZED::s:10PrinterSDK9RequestIDV` | `s:10PrinterSDK9RequestIDV` | `{"sourceOrigin":{"displayName":"Equatable.!=(_:_:)","identifier":"s:SQsRi_zRi0_zrlE2neoiySbx_xtFZ"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK0A10ConstraintO` | `s:10PrinterSDK0A10ConstraintO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK0A7FeatureO` | `s:10PrinterSDK0A7FeatureO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK0A8ProtocolO` | `s:10PrinterSDK0A8ProtocolO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK11FinishScopeO` | `s:10PrinterSDK11FinishScopeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK11PixelFormatO` | `s:10PrinterSDK11PixelFormatO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK14ImageAlgorithmO` | `s:10PrinterSDK14ImageAlgorithmO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK15CompletionLevelO` | `s:10PrinterSDK15CompletionLevelO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK22MediaPersistencePolicyO` | `s:10PrinterSDK22MediaPersistencePolicyO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK23MediaVerificationPolicyO` | `s:10PrinterSDK23MediaVerificationPolicyO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK7CutModeO` | `s:10PrinterSDK7CutModeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp::SYNTHESIZED::s:10PrinterSDK9MediaModeO` | `s:10PrinterSDK9MediaModeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hashValue","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE04hashB0Sivp"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK0A10ConstraintO` | `s:10PrinterSDK0A10ConstraintO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK0A7FeatureO` | `s:10PrinterSDK0A7FeatureO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK0A8ProtocolO` | `s:10PrinterSDK0A8ProtocolO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK11FinishScopeO` | `s:10PrinterSDK11FinishScopeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK11PixelFormatO` | `s:10PrinterSDK11PixelFormatO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK14ImageAlgorithmO` | `s:10PrinterSDK14ImageAlgorithmO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK15CompletionLevelO` | `s:10PrinterSDK15CompletionLevelO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK22MediaPersistencePolicyO` | `s:10PrinterSDK22MediaPersistencePolicyO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK23MediaVerificationPolicyO` | `s:10PrinterSDK23MediaVerificationPolicyO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK7CutModeO` | `s:10PrinterSDK7CutModeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF::SYNTHESIZED::s:10PrinterSDK9MediaModeO` | `s:10PrinterSDK9MediaModeO` | `{"sourceOrigin":{"displayName":"RawRepresentable.hash(into:)","identifier":"s:SYsSHRzSH8RawValueSYRpzrlE4hash4intoys6HasherVz_tF"}}` |
| `memberOf` | `s:s5ErrorP10FoundationE20localizedDescriptionSSvp::SYNTHESIZED::s:10PrinterSDK0A8SDKErrorV` | `s:10PrinterSDK0A8SDKErrorV` | `{"sourceOrigin":{"displayName":"Error.localizedDescription","identifier":"s:s5ErrorP10FoundationE20localizedDescriptionSSvp"}}` |
