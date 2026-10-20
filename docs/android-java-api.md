# Android Java API 参考

发布候选版本 **0.3.0-preview.4**；原生 SDK **0.3.0**；C ABI **3/r2**。

本页逐项覆盖审定的编译器公共 API 基线，共 **225** 个文档条目。
声明、JVM descriptor、常量、枚举和编译器关系均来自基线，说明按稳定文档 ID 维护。
机器可读的完整基线与说明见 [api-reference.json](api-reference.json)；运行
`python3 tools/check-api-reference.py` 可检查覆盖范围、审定 SHA-256 和本页字节一致性。

基线 SHA-256：`cc7d3634f25deeca19aeef6a8775eab17f40ede6837967113b386bcc33b9288e`

运行约束与错误处理见 [API 与生命周期](api-lifecycle.md) 和 [错误码与排障](errors-troubleshooting.md)。
本页是未发布的发布候选契约，不代表发布制品或公开历史证明。硬件验收仍暂缓，`hardware_verified=false`。

## 类型导航

- [BleOptions](#api-168ab2e3c48dfc7424a0)
- [BleOptions.CreditFlowControl](#api-7b31b50111b4bf370803)
- [CancellationContext](#api-b6cc8aebaaca337eddbc)
- [ConnectionOptions](#api-305c75156578a769bb1d)
- [CpclProfile](#api-d96de71f64e0601eb399)
- [DiscoveredDevice](#api-b790baf5c321454d18b7)
- [EscPosProfile](#api-961de0862e0cb78fdffe)
- [FeatureSupport](#api-1713e3bca4852cbf74f4)
- [M90Profile](#api-594e899b3823cf2251e4)
- [ManagerResult](#api-98f169a3e4c7b889744f)
- [ManagerResult.Completion](#api-1721ae5f9f8202edb30d)
- [ManagerResult.Outcome](#api-2784cdf665d09aa3045c)
- [MediaMode](#api-4b74ae3f0e52d0db0f65)
- [MediaRequirement](#api-2f5be4c6d23e94746056)
- [MediaSettings](#api-e5824d9e8f16babb6dab)
- [PreparedPrint](#api-5cf4c76272c2df7a9a90)
- [PreparedPrint.Builder](#api-9acaf968b2de3c0d2d3d)
- [PreparedPrint.Pixels](#api-52e18138e529bfa1a76c)
- [PrintOptions](#api-4dc5d455340db9937535)
- [PrinterCapabilities](#api-a36171733f6c01585161)
- [PrinterManager](#api-bfc786be5b911ef74d19)
- [PrinterManager.Callback](#api-a8eff59edaee0576f508)
- [PrinterManager.DisconnectedListener](#api-9149b393dfb876ce6b8e)
- [PrinterManager.Preparation](#api-926b9d0552ac918f6e21)
- [RequestId](#api-764c5a4147cfdf641cc3)
- [ScalarConstraint](#api-b49ec93e3a988bef134a)
- [SdkInfo](#api-e68d6e49886d528a891c)
- [StatusQueryConfig](#api-31d51fc34c8d04a03b44)
- [StatusResult](#api-346a10d907279a636fde)

Java 签名保留编译器记录的二进制嵌套名 `$`；源码导入和类型访问使用 `.`。
方法参数名不在 `javap` 基线中，参数顺序与类型以声明和 descriptor 为准。

<a id="api-168ab2e3c48dfc7424a0"></a>

## BleOptions

不可变的 BLE 服务、写入及可选信用流控配置。

```java
public final class com.netumscan.printersdk.BleOptions
```

应用须显式提供服务与特征 UUID、MTU 请求值及写入上限；没有自动识别型号或猜测 UUID 的行为。构造只校验配置，不连接设备。`withResponse` 选择 GATT 写入方式，不能作为打印机执行确认；实际分包长度受协商 MTU、配置上限和可选信用额度共同限制。字段均为 `final`，可在多个设备创建请求间复用。

文档 ID：`android:type:com.netumscan.printersdk.BleOptions`

<a id="api-06c89b8949bb2d2f4f47"></a>

### public com.netumscan.printersdk.BleOptions(java.util.UUID, java.util.UUID, boolean, int, int)

创建不启用信用流控的 BLE 配置。

```java
public com.netumscan.printersdk.BleOptions(java.util.UUID, java.util.UUID, boolean, int, int);
```

参数 `service`、`writeCharacteristic` 为非 null 的服务和写特征 UUID；`withResponse` 为 true 时使用带响应写入，false 时使用无响应写入；`requestedMtu` 的范围为 23..517 字节，`maxWriteBytes` 的范围为 1..512 字节。等价于六参数构造器传入 `creditFlowControl=null`。配置非法抛出 `IllegalArgumentException`。同步返回新配置，不执行蓝牙 IO；没有隐式 MTU 或分包默认值。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:c88f3fcaa589a6a9`

JVM descriptor：`(Ljava/util/UUID;Ljava/util/UUID;ZII)V`

<a id="api-62616d2dd2d65d913d01"></a>

### public com.netumscan.printersdk.BleOptions(java.util.UUID, java.util.UUID, boolean, int, int, com.netumscan.printersdk.BleOptions$CreditFlowControl)

创建带可选信用流控的 BLE 配置。

```java
public com.netumscan.printersdk.BleOptions(java.util.UUID, java.util.UUID, boolean, int, int, com.netumscan.printersdk.BleOptions$CreditFlowControl);
```

参数 `service`、`writeCharacteristic` 不可为 null；`requestedMtu` 为 23..517 字节，`maxWriteBytes` 为 1..512 字节。`creditFlowControl` 可为 null；非 null 时 `withResponse` 必须为 false，且写特征必须不同于 `dataOut` 和 `dataFC`。该对象已保证两种通知特征互不相同。违反条件抛出 `IllegalArgumentException`。同步创建配置，不发起连接或订阅；GATT 属性和通知能力在 `connect()` 时验证。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:7cd4a0c376a401a5`

JVM descriptor：`(Ljava/util/UUID;Ljava/util/UUID;ZIILcom/netumscan/printersdk/BleOptions$CreditFlowControl;)V`

<a id="api-cb046178c975767ab6e0"></a>

### public final boolean withResponse

是否使用带响应的 GATT 特征写入。

```java
public final boolean withResponse;
```

由构造参数显式指定，true 对应 `WRITE_TYPE_DEFAULT`，false 对应 `WRITE_TYPE_NO_RESPONSE`；启用信用流控时必须为 false。GATT 写回调或响应不表示纸面打印完成。没有可变 setter。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:9349d0eb41799510`

JVM descriptor：`Z`

<a id="api-7dd3ed5c4225dba40584"></a>

### public final com.netumscan.printersdk.BleOptions$CreditFlowControl creditFlowControl

可选的 Data Transmission V1.2 信用流控配置。

```java
public final com.netumscan.printersdk.BleOptions$CreditFlowControl creditFlowControl;
```

值为 null 表示不启用该流控；五参数构造器固定采用 null。非 null 时连接会订阅两种通知特征，并等待初始信用信息后才就绪；不能用它代替通用状态查询或打印完成确认。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:5020202ee255a725`

JVM descriptor：`Lcom/netumscan/printersdk/BleOptions$CreditFlowControl;`

<a id="api-3e70e0378b25fbbd5251"></a>

### public final int maxWriteBytes

单次 BLE 写入的数据长度上限，单位为字节。

```java
public final int maxWriteBytes;
```

合法范围为 1..512，由构造参数显式指定。实际单包长度不超过此值与协商 MTU 减 3 的较小值；启用信用流控时还受信用额度约束。这是传输分包上限，不是光栅条带高度或完整作业大小限制。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:f96a0e16f66d9c02`

JVM descriptor：`I`

<a id="api-329424eb072add7be305"></a>

### public final int requestedMtu

连接时请求的 ATT MTU，单位为字节。

```java
public final int requestedMtu;
```

合法范围为 23..517。23 表示沿用初始 MTU；大于 23 时请求 MTU 协商。请求值不保证等于协商结果，实际写包还受 `maxWriteBytes` 限制；没有自动将 MTU 请求值当成可用载荷大小的行为。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:11c9b2aff8de43b4`

JVM descriptor：`I`

<a id="api-3a483f5c69ca680c6989"></a>

### public final java.util.UUID service

目标 BLE GATT 服务 UUID。

```java
public final java.util.UUID service;
```

构造时必须非 null。连接后在该服务中查找写特征和可选通知特征；未知服务不会自动回退到其他服务。UUID 本身不证明设备型号或协议兼容性。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:d1aa937cc2ea3c07`

JVM descriptor：`Ljava/util/UUID;`

<a id="api-4790d77a0327dac499e3"></a>

### public final java.util.UUID writeCharacteristic

目标服务内用于发送打印数据的特征 UUID。

```java
public final java.util.UUID writeCharacteristic;
```

构造时必须非 null；连接时验证其具备所选的带响应或无响应写属性。启用信用流控时不得与两种通知特征 UUID 相同。特征不支持时连接失败，通常报告 `PrinterException` code 1004。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions:0d32a05b9d9ca5ae`

JVM descriptor：`Ljava/util/UUID;`

<a id="api-7b31b50111b4bf370803"></a>

## BleOptions.CreditFlowControl

Data Transmission V1.2 的两种通知特征配置。

```java
public final class com.netumscan.printersdk.BleOptions$CreditFlowControl
```

不可变的 `BleOptions` 嵌套值类型。`dataOut` 与 `dataFC` 均位于配置选定的服务；SDK 使用通知建立流控会话，其中信用通知决定可发送额度。只适用于明确支持该固件协议的设备，配置本身不升级硬件证据等级，也不公开平台 GATT 句柄。

文档 ID：`android:type:com.netumscan.printersdk.BleOptions$CreditFlowControl`

<a id="api-6657cb40e72e0c97a9e3"></a>

### public com.netumscan.printersdk.BleOptions$CreditFlowControl(java.util.UUID, java.util.UUID)

声明互不相同的数据通知与信用通知 UUID。

```java
public com.netumscan.printersdk.BleOptions$CreditFlowControl(java.util.UUID, java.util.UUID);
```

参数 `dataOut`、`dataFC` 均不可为 null，且两者不得相等，否则同步抛出 `IllegalArgumentException`。返回新配置，不进行订阅。作为 `BleOptions.creditFlowControl` 使用时，还要求写特征不同于这两个 UUID，并使用无响应写入。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions$CreditFlowControl:33abf9a6aa732f1e`

JVM descriptor：`(Ljava/util/UUID;Ljava/util/UUID;)V`

<a id="api-ab18289d478138156f5d"></a>

### public final java.util.UUID dataFC

Data Transmission V1.2 的信用流控通知特征 UUID。

```java
public final java.util.UUID dataFC;
```

非 null，且不同于 `dataOut`。连接时订阅此特征，解析其信用信息并限制后续发送；等待信用也占用操作超时预算。通知不表示纸面打印完成；流控错误不会自动重放已发送数据。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions$CreditFlowControl:1c434c73eb8d8d08`

JVM descriptor：`Ljava/util/UUID;`

<a id="api-ba50413f8eac6399d66f"></a>

### public final java.util.UUID dataOut

Data Transmission V1.2 的数据通知特征 UUID。

```java
public final java.util.UUID dataOut;
```

非 null，且不同于 `dataFC`。连接时须能在目标服务中找到该特征、NOTIFY 属性与 CCCD；SDK 订阅该特征以建立此固件要求的通知通道。当前公共 Java API 不提供数据通知回调，不能据此读取通用打印机状态。

文档 ID：`android:member:com.netumscan.printersdk.BleOptions$CreditFlowControl:e8f4989c9668b7e5`

JVM descriptor：`Ljava/util/UUID;`

<a id="api-b6cc8aebaaca337eddbc"></a>

## CancellationContext

准备阶段的协作取消上下文。

```java
public final class com.netumscan.printersdk.CancellationContext
```

应用在耗时像素准备中检查取消并尽快返回；该对象不持有可操作的native资源。请求取消或清理后，迟到的准备结果不能重新提交打印。

文档 ID：`android:type:com.netumscan.printersdk.CancellationContext`

<a id="api-2e00f14c155bf147c36d"></a>

### public boolean isCancelled()

检查准备是否已被取消。

```java
public boolean isCancelled();
```

应用在耗时准备的分块边界检查该值并尽早结束；仅用于协作取消，不提供native设备操作。

文档 ID：`android:member:com.netumscan.printersdk.CancellationContext:f1f8e4ff91b49c6d`

JVM descriptor：`()Z`

<a id="api-0f816b14b5645dfb7250"></a>

### public void throwIfCancelled()

在准备函数中检查取消或总超时。

```java
public void throwIfCancelled();
```

取消时抛出CancellationException，超时通过稳定Timeout错误结束；应用应在耗时准备的边界调用该方法。

文档 ID：`android:member:com.netumscan.printersdk.CancellationContext:871ea18d6bc6f0cb`

JVM descriptor：`()V`

<a id="api-305c75156578a769bb1d"></a>

## ConnectionOptions

设备地址和连接方式配置。

```java
public final class com.netumscan.printersdk.ConnectionOptions
```

通过spp或ble工厂选择连接目标；协议profile按每次打印请求提供，连接DTO不持有平台Bluetooth句柄。

文档 ID：`android:type:com.netumscan.printersdk.ConnectionOptions`

<a id="api-3e5b97334c8317067cf0"></a>

### public final com.netumscan.printersdk.BleOptions ble

构造BLE连接目标。

```java
public final com.netumscan.printersdk.BleOptions ble;
```

传入明确地址及BleOptions服务/特征配置；DTO不打开连接、不执行扫描，也不暴露平台设备句柄。

文档 ID：`android:member:com.netumscan.printersdk.ConnectionOptions:aba718e6092d58ce`

JVM descriptor：`Lcom/netumscan/printersdk/BleOptions;`

<a id="api-c19d55fa15e17d1a5d0c"></a>

### public final java.lang.String address

蓝牙设备地址。

```java
public final java.lang.String address;
```

连接时需要明确有效地址；发现值不包含可直接操作的平台Bluetooth句柄。

文档 ID：`android:member:com.netumscan.printersdk.ConnectionOptions:b1aeb5a5c56be66f`

JVM descriptor：`Ljava/lang/String;`

<a id="api-d856f066b9e2be032eb1"></a>

### public static com.netumscan.printersdk.ConnectionOptions ble(java.lang.String, com.netumscan.printersdk.BleOptions)

构造BLE连接目标。

```java
public static com.netumscan.printersdk.ConnectionOptions ble(java.lang.String, com.netumscan.printersdk.BleOptions);
```

传入明确地址及BleOptions服务/特征配置；DTO不打开连接、不执行扫描，也不暴露平台设备句柄。

文档 ID：`android:member:com.netumscan.printersdk.ConnectionOptions:040f19a651bedc97`

JVM descriptor：`(Ljava/lang/String;Lcom/netumscan/printersdk/BleOptions;)Lcom/netumscan/printersdk/ConnectionOptions;`

<a id="api-c2f74fa8ad3dc7549046"></a>

### public static com.netumscan.printersdk.ConnectionOptions spp(java.lang.String)

构造经典蓝牙SPP连接目标。

```java
public static com.netumscan.printersdk.ConnectionOptions spp(java.lang.String);
```

传入明确设备地址；Manager.connect负责异步参数校验和连接，协议profile仍由每个打印请求独立选择。

文档 ID：`android:member:com.netumscan.printersdk.ConnectionOptions:c8b71af4f566db64`

JVM descriptor：`(Ljava/lang/String;)Lcom/netumscan/printersdk/ConnectionOptions;`

<a id="api-d96de71f64e0601eb399"></a>

## CpclProfile

声明 CPCL 操作的显式光栅几何。

```java
public final class com.netumscan.printersdk.CpclProfile
```

不可变配置，逐次提供给 Manager 的打印、介质或走纸操作；连接只接收通信目标。点数为打印机 dots，DPI 和可打印宽度由应用按实际设备声明。xOffsetDots/form 保留为配置字段，Manager 不自动继承到 PreparedPrint；作业原点与结束策略显式提供。Raw 不受这些字段改写，配置不是硬件验收证明。

文档 ID：`android:type:com.netumscan.printersdk.CpclProfile`

<a id="api-d9243ca54e436527f6fc"></a>

### public com.netumscan.printersdk.CpclProfile(int, int, int, boolean)

创建水平原点为零的 CPCL 配置。

```java
public com.netumscan.printersdk.CpclProfile(int, int, int, boolean);
```

参数 dpi 为正整数；widthDots 为 8..7992 dots，必须为 8 的倍数；maxLabelHeightDots 为 1..65535 dots；form 是保留的标签结束配置字段。等价于五参数构造器传入 xOffsetDots=0。非法几何同步抛出 IllegalArgumentException；不执行 IO，不自动推断纸宽。Manager 作业的原点与结束策略由 PreparedPrint 显式声明。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:7002d48a5c80a84b`

JVM descriptor：`(IIIZ)V`

<a id="api-acf193df3ed9c8f9d898"></a>

### public com.netumscan.printersdk.CpclProfile(int, int, int, boolean, int)

创建带水平光栅原点的 CPCL 配置。

```java
public com.netumscan.printersdk.CpclProfile(int, int, int, boolean, int);
```

参数 dpi 为正整数；widthDots 为 8..7992 dots 且为 8 的倍数；maxLabelHeightDots 为 1..65535 dots；xOffsetDots 为 0..widthDots-1，form 为保留的标签结束配置字段。非法参数同步抛出 IllegalArgumentException。Manager 不自动将原点和结束字段覆盖到 PreparedPrint；本次标签描述须显式提供对应值，超界不自动裁剪。Raw 不受改写。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:8f3cfa075f5b2a1c`

JVM descriptor：`(IIIZI)V`

<a id="api-b21b6b4649d00efca4d5"></a>

### public final boolean form

保留的 CPCL 标签结束配置字段。

```java
public final boolean form;
```

true 表示下一标签开始策略（CPCL FORM），false 表示内容结束。Manager 打印显式使用 PreparedPrint.label 描述的结束策略，不自动继承此字段；App 可以自行将其填入本次描述。它不设置介质类型、不校准传感器，也不影响 Raw。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:6df5f7cd5045db8d`

JVM descriptor：`Z`

<a id="api-dc0ed4d1751e21a8bf5b"></a>

### public final int dpi

显式声明的打印密度，单位为 dots per inch。

```java
public final int dpi;
```

由构造器要求为正整数，没有型号默认值。Java 包装将其用于标签作业的 X/Y DPI 和几何校验；它不自动改变打印机物理分辨率，必须与实际设备匹配。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:a54ea9eab4fa22b3`

JVM descriptor：`I`

<a id="api-62ac8ccfc717fd318b32"></a>

### public final int maxLabelHeightDots

一张标签的最大页高，单位为 dots。

```java
public final int maxLabelHeightDots;
```

范围为 1..65535，由调用方按设备约束声明。显式标签提交的 `originY + height + trailingBlankDots` 须不超过它；此值不乘 copies，也不是整单累计长度或手机内存承诺。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:442cf4821daf3658`

JVM descriptor：`I`

<a id="api-9fc785d8c552c1b98cd0"></a>

### public final int widthDots

设备可打印的最大光栅宽度，单位为 dots。

```java
public final int widthDots;
```

范围为 8..7992，必须为 8 的倍数。输入图片可窄于该值；SDK 不自动缩放，实际图宽按 8 点补齐后再加水平原点不得超过此上限。纸张毫米宽度或蓝牙包长均不能直接代入。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:d1f158b9ba2a99a4`

JVM descriptor：`I`

<a id="api-5180a79db48655575a6e"></a>

### public final int xOffsetDots

保留的非负水平原点配置字段，单位为 dots。

```java
public final int xOffsetDots;
```

四参数构造器默认值为 0；显式值必须小于 widthDots。Manager 不自动将此字段应用到 PreparedPrint.label；本次作业的 originX 由输入描述显式提供。原点不改变输入图尺寸或 Raw 字节，超界不自动裁剪。

文档 ID：`android:member:com.netumscan.printersdk.CpclProfile:af181a7757d57091`

JVM descriptor：`I`

<a id="api-b790baf5c321454d18b7"></a>

## DiscoveredDevice

蓝牙发现或配对枚举的只读设备信息。

```java
public final class com.netumscan.printersdk.DiscoveredDevice
```

包含地址、名称、可选RSSI与广播服务标识；后续连接使用设备标识和显式BLE选项，不暴露平台设备句柄。

文档 ID：`android:type:com.netumscan.printersdk.DiscoveredDevice`

<a id="api-5d1582cb157eea406b6d"></a>

### public final java.lang.Integer rssi

扫描接收信号强度。

```java
public final java.lang.Integer rssi;
```

单位为dBm；没有扫描测量值时为空，不使用特殊数值伪造有效测量。

文档 ID：`android:member:com.netumscan.printersdk.DiscoveredDevice:4911150c511b5cd7`

JVM descriptor：`Ljava/lang/Integer;`

<a id="api-862732bae26f04800853"></a>

### public final java.lang.String address

蓝牙设备地址。

```java
public final java.lang.String address;
```

连接时需要明确有效地址；发现值不包含可直接操作的平台Bluetooth句柄。

文档 ID：`android:member:com.netumscan.printersdk.DiscoveredDevice:b1aeb5a5c56be66f`

JVM descriptor：`Ljava/lang/String;`

<a id="api-9b7190a400caf05e5d3d"></a>

### public final java.lang.String name

设备广播或系统提供的名称。

```java
public final java.lang.String name;
```

未知时使用可空值；该名称用于显示，不能替代明确的连接标识。

文档 ID：`android:member:com.netumscan.printersdk.DiscoveredDevice:77409202b35ac1a5`

JVM descriptor：`Ljava/lang/String;`

<a id="api-969a356a5a3af09831f5"></a>

### public final java.util.List<java.lang.String> advertisedServices

广播的服务标识列表。

```java
public final java.util.List<java.lang.String> advertisedServices;
```

只读数据；不提供BluetoothGatt或平台扫描对象，连接仍需要明确配置。

文档 ID：`android:member:com.netumscan.printersdk.DiscoveredDevice:278808084302b914`

JVM descriptor：`Ljava/util/List;`

<a id="api-961de0862e0cb78fdffe"></a>

## EscPosProfile

声明 ESC/POS 小票光栅的显式 DPI 和可打印宽度。

```java
public final class com.netumscan.printersdk.EscPosProfile
```

不可变配置，逐次提供给 Manager 的 ESC/POS 打印操作；连接只接收通信目标。必须与实际设备密度和可打印点宽匹配，不从名称或纸宽推断型号。Preparation 返回 PreparedPrint 小票的像素、空白元素、长度预算及结束策略。当前标准后端不实现硬件状态查询和切纸。

文档 ID：`android:type:com.netumscan.printersdk.EscPosProfile`

<a id="api-a389a27bb00caa90a626"></a>

### public com.netumscan.printersdk.EscPosProfile(int, int)

创建 ESC/POS 光栅几何配置。

```java
public com.netumscan.printersdk.EscPosProfile(int, int);
```

参数 `dpi` 为 1..255 dots per inch，`widthDots` 为 8..7992 dots 且为 8 的倍数。超出范围同步抛出 `IllegalArgumentException`。两值都必须显式提供，没有型号默认值；构造不连接或设置硬件。

文档 ID：`android:member:com.netumscan.printersdk.EscPosProfile:13dfdc2812e6b642`

JVM descriptor：`(II)V`

<a id="api-b663d0e9cf4b797b927b"></a>

### public final int dpi

ESC/POS 作业声明的打印密度，单位为 dots per inch。

```java
public final int dpi;
```

范围为 1..255，由构造参数指定；用于与设备配置一致的 X/Y DPI。它不测量打印头、不自动改变硬件分辨率，配置值须经调用方核实。

文档 ID：`android:member:com.netumscan.printersdk.EscPosProfile:a54ea9eab4fa22b3`

JVM descriptor：`I`

<a id="api-73fb6b16df56ec320fd7"></a>

### public final int widthDots

ESC/POS 设备可打印的最大光栅宽度，单位为 dots。

```java
public final int widthDots;
```

范围为 8..7992，必须为 8 的倍数。整张小票图片可窄于该值；按 8 点补齐后的图宽必须在此范围内，不自动缩放或裁剪，也不等同于纸张毫米宽度。

文档 ID：`android:member:com.netumscan.printersdk.EscPosProfile:d1f158b9ba2a99a4`

JVM descriptor：`I`

<a id="api-1713e3bca4852cbf74f4"></a>

## FeatureSupport

分别记录实现可用性、设备支持与证据的不可变快照。

```java
public final class com.netumscan.printersdk.FeatureSupport
```

通过 `PrinterCapabilities.feature()` 获取，不提供公共构造器。`implementation` 描述 SDK 路径是否实现，`deviceSupport` 描述设备支持是否已知，`evidence` 是证据位掩码；三个维度不能相互替代。当前显式 CPCL/ESC-POS 配置的已知功能可能仅有 PROFILE_DECLARED 且设备支持为 UNKNOWN，因此 `isImplemented()` 可为 true、`isSupported()` 仍为 false。未知功能 ID 返回未实现、未知设备支持和 evidence=0。

文档 ID：`android:type:com.netumscan.printersdk.FeatureSupport`

<a id="api-5adf34cff79f8a28b5fc"></a>

### public boolean isImplemented()

判断 SDK 是否存在该功能的实现路径。

```java
public boolean isImplemented();
```

无参数，返回 `implementation != NOT_IMPLEMENTED`。NATIVE 与 HOST_RENDERED 都返回 true；不读取设备、不执行 IO。该结果不检查 `deviceSupport` 或证据，不是当前硬件可用或打印已验收的保证。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:9f723c20b86e9048`

JVM descriptor：`()Z`

<a id="api-9648a867f14b13663a1a"></a>

### public boolean isSupported()

判断实现可用且设备支持已明确为支持。

```java
public boolean isSupported();
```

无参数，仅在 `isImplemented()` 为 true 且 `deviceSupport == SUPPORTED` 时返回 true。UNKNOWN 与 UNSUPPORTED 都返回 false，不能用 false 反推设备必定不支持。此判断不要求 HARDWARE_VERIFIED 位，仍应单独检查证据。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:751796123f4e2c80`

JVM descriptor：`()Z`

<a id="api-b69d65a56f8413e395f5"></a>

### public final int deviceSupport

该功能在设备上的支持知识状态。

```java
public final int deviceSupport;
```

当前定义为 UNKNOWN=0、UNSUPPORTED=1、SUPPORTED=2。UNKNOWN 表示没有足够证据，不等于 UNSUPPORTED；显式打印参数和协议编码存在也不能推导为 SUPPORTED。字段只读，配合 `implementation` 与 `evidence` 使用。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:6dfcca999e954a11`

JVM descriptor：`I`

<a id="api-0034bebc335217764927"></a>

### public final int evidence

支持声明的证据位掩码。

```java
public final int evidence;
```

PROFILE_DECLARED=1、DEVICE_REPORTED=2、HARDWARE_VERIFIED=4 可按位组合，0 表示没有对应证据。应使用按位与测试目标位；配置声明或设备自报均不能替代硬件验证。读取快照不会触发新的查询或验收。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:958eb37813714ec1`

JVM descriptor：`I`

<a id="api-99fa3cc41f8df96a5868"></a>

### public final int implementation

该功能的 SDK 实现类别整数。

```java
public final int implementation;
```

当前定义为 NOT_IMPLEMENTED=0、NATIVE=1、HOST_RENDERED=2。它描述实现路径而非设备能力；使用 `isImplemented()` 可保留对将来非零实现值的保守兼容。字段只读，读取不执行 IO。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:9ad48e1c07766934`

JVM descriptor：`I`

<a id="api-5ede70a7e57b8e7202c9"></a>

### public final int knownFields

功能knownFields位集合。

```java
public final int knownFields;
```

VALUES_KNOWN=1、REQUIRED_FIELDS_KNOWN=2、SUPPORTED_FIELDS_KNOWN=4，先检查此位再解释对应集合，未知不等于空。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:700caffac055e8b2`

JVM descriptor：`I`

<a id="api-c5a9c98790c8414e72cf"></a>

### public final int requiredFields

功能requiredFields位集合。

```java
public final int requiredFields;
```

介质设置必需字段mask，仅REQUIRED_FIELDS_KNOWN有效时解释；当前CPCL仅tracking。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:7da7b5176ab9cfb2`

JVM descriptor：`I`

<a id="api-09357b4d94c68c8db5dc"></a>

### public final int supportedFields

功能supportedFields位集合。

```java
public final int supportedFields;
```

介质允许字段mask，仅SUPPORTED_FIELDS_KNOWN有效时解释；未知不能推断全部可用。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:6a1a916a859f4e9f`

JVM descriptor：`I`

<a id="api-0eeee30ce1ebd05e100f"></a>

### public final int supportedValues

功能supportedValues位集合。

```java
public final int supportedValues;
```

功能允许的枚举值mask，仅VALUES_KNOWN有效时解释；CUT按FULL/PARTIAL，IMAGE按算法，MEDIA按tracking值。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:8e1bfa54fc237043`

JVM descriptor：`I`

<a id="api-2711890ae200c6e98573"></a>

### public static final int DEVICE_REPORTED = 2

DEVICE_REPORTED常量，值2。

```java
public static final int DEVICE_REPORTED = 2;
```

表示DEVICE_REPORTED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:7384e00424860bf1`

JVM descriptor：`I`

<a id="api-29c5a143635d71a155f4"></a>

### public static final int HARDWARE_VERIFIED = 4

HARDWARE_VERIFIED常量，值4。

```java
public static final int HARDWARE_VERIFIED = 4;
```

表示HARDWARE_VERIFIED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:a41dc2f2bd9542ff`

JVM descriptor：`I`

<a id="api-333b4ee110fff9669c75"></a>

### public static final int HOST_RENDERED = 2

HOST_RENDERED常量，值2。

```java
public static final int HOST_RENDERED = 2;
```

表示HOST_RENDERED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:6e6ae85ee79f4469`

JVM descriptor：`I`

<a id="api-36b7b3a7bdf8d0253599"></a>

### public static final int NATIVE = 1

NATIVE常量，值1。

```java
public static final int NATIVE = 1;
```

表示NATIVE对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:9c09323ac8e6906f`

JVM descriptor：`I`

<a id="api-8f674851f75479a82ebf"></a>

### public static final int NOT_IMPLEMENTED = 0

NOT_IMPLEMENTED常量，值0。

```java
public static final int NOT_IMPLEMENTED = 0;
```

表示NOT_IMPLEMENTED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:258ec4eedffc58f1`

JVM descriptor：`I`

<a id="api-7cb192a56c0db341863a"></a>

### public static final int PROFILE_DECLARED = 1

PROFILE_DECLARED常量，值1。

```java
public static final int PROFILE_DECLARED = 1;
```

表示PROFILE_DECLARED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:296a3a40ae4f87ce`

JVM descriptor：`I`

<a id="api-1a137e5ddc2239a97711"></a>

### public static final int REQUIRED_FIELDS_KNOWN = 2

REQUIRED_FIELDS_KNOWN常量，值2。

```java
public static final int REQUIRED_FIELDS_KNOWN = 2;
```

表示REQUIRED_FIELDS_KNOWN对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:67c7e976e8b80178`

JVM descriptor：`I`

<a id="api-d39842a85f93d06ffa3a"></a>

### public static final int SUPPORTED = 2

SUPPORTED常量，值2。

```java
public static final int SUPPORTED = 2;
```

表示SUPPORTED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:2660f6d171c11793`

JVM descriptor：`I`

<a id="api-96b5ed030acd084cf86a"></a>

### public static final int SUPPORTED_FIELDS_KNOWN = 4

SUPPORTED_FIELDS_KNOWN常量，值4。

```java
public static final int SUPPORTED_FIELDS_KNOWN = 4;
```

表示SUPPORTED_FIELDS_KNOWN对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:8b212cb35baa50a9`

JVM descriptor：`I`

<a id="api-b402a3b6e7c5f8404721"></a>

### public static final int UNKNOWN = 0

UNKNOWN常量，值0。

```java
public static final int UNKNOWN = 0;
```

表示UNKNOWN对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:12fee7f020c6e236`

JVM descriptor：`I`

<a id="api-d1ae2781a5eb8768e313"></a>

### public static final int UNSUPPORTED = 1

UNSUPPORTED常量，值1。

```java
public static final int UNSUPPORTED = 1;
```

表示UNSUPPORTED对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:cc394616ff0eb36c`

JVM descriptor：`I`

<a id="api-5f63e368a44431300b29"></a>

### public static final int VALUES_KNOWN = 1

VALUES_KNOWN常量，值1。

```java
public static final int VALUES_KNOWN = 1;
```

表示VALUES_KNOWN对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.FeatureSupport:2a8cd771661a8b86`

JVM descriptor：`I`

<a id="api-594e899b3823cf2251e4"></a>

## M90Profile

提供 M90 固件 Data Transmission V1.2 的 BLE 连接预设。

```java
public final class com.netumscan.printersdk.M90Profile
```

工具类型，无公共构造器。预设只组合固定的服务、数据写入和信用通知 UUID，调用方仍须提供 MTU 与包长上限并选择打印协议/几何配置。选择此预设不自动发现或认证型号，也不表示无线或纸面行为已经完成硬件验收。

文档 ID：`android:type:com.netumscan.printersdk.M90Profile`

<a id="api-4a211dd1fcaf5ed95e6f"></a>

### public static com.netumscan.printersdk.BleOptions bleOptions(int, int)

创建 M90 V1.2 无响应写入与信用流控配置。

```java
public static com.netumscan.printersdk.BleOptions bleOptions(int, int);
```

参数 `requestedMtu` 为 23..517 字节，`maxWriteBytes` 为 1..512 字节；非法值由 `BleOptions` 抛出 `IllegalArgumentException`。返回非 null `BleOptions`：服务 `0000ff00-0000-1000-8000-00805f9b34fb`、写特征 FF02、数据通知 FF01、信用通知 FF03（后三者使用相同蓝牙基础 UUID），`withResponse=false`。同步创建，不连接设备；预设仅依据固件文档，不证明硬件支持。

文档 ID：`android:member:com.netumscan.printersdk.M90Profile:fadbe287c9213756`

JVM descriptor：`(II)Lcom/netumscan/printersdk/BleOptions;`

<a id="api-98f169a3e4c7b889744f"></a>

## ManagerResult

单次请求的不可变完成结果。

```java
public final class com.netumscan.printersdk.ManagerResult<T>
```

包含请求标识、成功/失败/取消、稳定错误码、辅助消息、完成证据、可能已输出标记及可选业务值。主线程回调恰好完成一次；dataSent仅证明数据发送完成，不证明纸张已打印。

文档 ID：`android:type:com.netumscan.printersdk.ManagerResult`

<a id="api-9decaa39a103f3afbb6b"></a>

### public final T value

成功结果的可选业务值。

```java
public final T value;
```

用于设备列表、能力、身份和状态查询；没有返回值的请求为Void/null，失败时不要假定业务值存在。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:60258455367224f8`

JVM descriptor：`Ljava/lang/Object;`

<a id="api-356bea50d55103f0d6ac"></a>

### public final boolean outputMayHaveOccurred

是否可能已发送了不可撤回的输出。

```java
public final boolean outputMayHaveOccurred;
```

true时设备可能已经收到部分命令或像素；应用不得据此自动重试或重放，需自行决定提示和后续人工操作。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:a134b771ae6ec59f`

JVM descriptor：`Z`

<a id="api-ea8d4b6c1a2baff62e9d"></a>

### public final com.netumscan.printersdk.ManagerResult$Completion completion

打印完成证据级别。

```java
public final com.netumscan.printersdk.ManagerResult$Completion completion;
```

none表示没有打印完成证据，dataSent表示传输完成，deviceConfirmed仅在协议提供明确设备确认时使用。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:97ce1429538d8a64`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Completion;`

<a id="api-b511db0e6dff799b48b8"></a>

### public final com.netumscan.printersdk.ManagerResult$Outcome outcome

请求成功、失败或取消的分类。

```java
public final com.netumscan.printersdk.ManagerResult$Outcome outcome;
```

与稳定code及完成证据一起读取；取消或失败不自动表示设备没有产生部分输出。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:c2dc63bbace485a2`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Outcome;`

<a id="api-e4a0bf43f650f01efaeb"></a>

### public final com.netumscan.printersdk.RequestId requestId

请求标识。

```java
public final com.netumscan.printersdk.RequestId requestId;
```

仅能由创建该标识的Manager识别；用于关联完成结果和发送取消意图。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:e82f6b58f9864f0c`

JVM descriptor：`Lcom/netumscan/printersdk/RequestId;`

<a id="api-4fe8239624fcc5ce1537"></a>

### public final int code

稳定SDK错误码。

```java
public final int code;
```

0表示成功，其他值按SDK错误契约解释；不要依赖可读message进行程序分支。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:c87585a61ac30812`

JVM descriptor：`I`

<a id="api-94755314530c221bb6bc"></a>

### public final java.lang.String message

可读的辅助错误消息。

```java
public final java.lang.String message;
```

用于集成诊断和界面提示；程序逻辑以稳定code为主，不解析该文本。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult:62f72828fbf07916`

JVM descriptor：`Ljava/lang/String;`

<a id="api-1721ae5f9f8202edb30d"></a>

## ManagerResult.Completion

打印完成证据级别。

```java
public final class com.netumscan.printersdk.ManagerResult$Completion extends java.lang.Enum<com.netumscan.printersdk.ManagerResult$Completion>
```

NONE/none表示没有打印完成证据，DATA_SENT/dataSent表示传输完成，DEVICE_CONFIRMED/deviceConfirmed仅在协议提供明确设备确认时使用。

文档 ID：`android:type:com.netumscan.printersdk.ManagerResult$Completion`

枚举声明顺序（`ordinal()` 从 0 起；不作为持久化协议值）：

| ordinal | 枚举项 |
| --- | --- |
| 0 | `NONE` |
| 1 | `DATA_SENT` |
| 2 | `DEVICE_CONFIRMED` |

<a id="api-6d97921c294a639254f4"></a>

### public static com.netumscan.printersdk.ManagerResult$Completion valueOf(java.lang.String)

按精确名称读取枚举常量。

```java
public static com.netumscan.printersdk.ManagerResult$Completion valueOf(java.lang.String);
```

由Java编译器生成；名称不匹配时遵循Java标准枚举异常行为。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Completion:b1c46fd2ef782e48`

JVM descriptor：`(Ljava/lang/String;)Lcom/netumscan/printersdk/ManagerResult$Completion;`

这是 Java 编译器为枚举生成的公共方法。

<a id="api-352c269dc1c32a562773"></a>

### public static com.netumscan.printersdk.ManagerResult$Completion[] values()

枚举声明顺序中的全部常量。

```java
public static com.netumscan.printersdk.ManagerResult$Completion[] values();
```

由Java编译器生成，返回新数组；常量名称和值属于本版本公开契约。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Completion:bbc424685d75dbb8`

JVM descriptor：`()[Lcom/netumscan/printersdk/ManagerResult$Completion;`

这是 Java 编译器为枚举生成的公共方法。

<a id="api-290d9cf4014b21ab8076"></a>

### public static final com.netumscan.printersdk.ManagerResult$Completion DATA_SENT

仅数据发送完成。

```java
public static final com.netumscan.printersdk.ManagerResult$Completion DATA_SENT;
```

该常量的精确名称、原始值或条件位属于本版本契约；完成证据不得被解释为强于实际协议可证明的级别。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Completion:25379bc32a34dbdc`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Completion;`

<a id="api-544156fc54fe7a081b86"></a>

### public static final com.netumscan.printersdk.ManagerResult$Completion DEVICE_CONFIRMED

设备明确确认完成。

```java
public static final com.netumscan.printersdk.ManagerResult$Completion DEVICE_CONFIRMED;
```

该常量的精确名称、原始值或条件位属于本版本契约；完成证据不得被解释为强于实际协议可证明的级别。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Completion:0f0213ab646475bb`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Completion;`

<a id="api-40186482712649e8f8f2"></a>

### public static final com.netumscan.printersdk.ManagerResult$Completion NONE

没有完成证据。

```java
public static final com.netumscan.printersdk.ManagerResult$Completion NONE;
```

该常量的精确名称、原始值或条件位属于本版本契约；完成证据不得被解释为强于实际协议可证明的级别。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Completion:b2288a2b928b5668`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Completion;`

<a id="api-2784cdf665d09aa3045c"></a>

## ManagerResult.Outcome

请求的终态分类。

```java
public final class com.netumscan.printersdk.ManagerResult$Outcome extends java.lang.Enum<com.netumscan.printersdk.ManagerResult$Outcome>
```

SUCCESS/success、FAILURE/failure和CANCELLED/cancelled分别表示成功、失败及取消；同时检查稳定code和输出证据以决定应用提示。

文档 ID：`android:type:com.netumscan.printersdk.ManagerResult$Outcome`

枚举声明顺序（`ordinal()` 从 0 起；不作为持久化协议值）：

| ordinal | 枚举项 |
| --- | --- |
| 0 | `SUCCESS` |
| 1 | `FAILURE` |
| 2 | `CANCELLED` |

<a id="api-63c73722c03dc5aa768a"></a>

### public static com.netumscan.printersdk.ManagerResult$Outcome valueOf(java.lang.String)

按精确名称读取枚举常量。

```java
public static com.netumscan.printersdk.ManagerResult$Outcome valueOf(java.lang.String);
```

由Java编译器生成；名称不匹配时遵循Java标准枚举异常行为。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Outcome:e5d94c2fff5d9609`

JVM descriptor：`(Ljava/lang/String;)Lcom/netumscan/printersdk/ManagerResult$Outcome;`

这是 Java 编译器为枚举生成的公共方法。

<a id="api-37db37ba405e67a9a9e4"></a>

### public static com.netumscan.printersdk.ManagerResult$Outcome[] values()

枚举声明顺序中的全部常量。

```java
public static com.netumscan.printersdk.ManagerResult$Outcome[] values();
```

由Java编译器生成，返回新数组；常量名称和值属于本版本公开契约。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Outcome:48814b7d3efdb6ee`

JVM descriptor：`()[Lcom/netumscan/printersdk/ManagerResult$Outcome;`

这是 Java 编译器为枚举生成的公共方法。

<a id="api-d7e9bb44403ab6f37534"></a>

### public static final com.netumscan.printersdk.ManagerResult$Outcome CANCELLED

请求取消。

```java
public static final com.netumscan.printersdk.ManagerResult$Outcome CANCELLED;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Outcome:6dc2c8acb95c7598`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Outcome;`

<a id="api-851e4da4067f58b66f35"></a>

### public static final com.netumscan.printersdk.ManagerResult$Outcome FAILURE

请求失败。

```java
public static final com.netumscan.printersdk.ManagerResult$Outcome FAILURE;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Outcome:e3c5f749b2c365b7`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Outcome;`

<a id="api-515dec3613d752c82ce0"></a>

### public static final com.netumscan.printersdk.ManagerResult$Outcome SUCCESS

请求成功。

```java
public static final com.netumscan.printersdk.ManagerResult$Outcome SUCCESS;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.ManagerResult$Outcome:458dd1ddc909dc38`

JVM descriptor：`Lcom/netumscan/printersdk/ManagerResult$Outcome;`

<a id="api-4b74ae3f0e52d0db0f65"></a>

## MediaMode

与打印语言独立的介质跟踪方式枚举。

```java
public final class com.netumscan.printersdk.MediaMode extends java.lang.Enum<com.netumscan.printersdk.MediaMode>
```

用于 `setMedia()` 或兼容 `setMediaMode()`，当前 CPCL 后端实现跟踪模式命令，ESC/POS 后端拒绝。选择枚举不会声明纸宽、纸长、间隙长度或传感器校准结果；调用方必须装入适当介质，并核实固件兼容性。枚举的 Java ordinal 不是公共协议编码，不应自行用于拼接命令。

文档 ID：`android:type:com.netumscan.printersdk.MediaMode`

枚举声明顺序（`ordinal()` 从 0 起；不作为持久化协议值）：

| ordinal | 枚举项 |
| --- | --- |
| 0 | `GAP` |
| 1 | `BLACK_MARK` |
| 2 | `CONTINUOUS` |

<a id="api-f964ddb8df3fb623eb9a"></a>

### public static com.netumscan.printersdk.MediaMode valueOf(java.lang.String)

按精确枚举名称查找介质模式。

```java
public static com.netumscan.printersdk.MediaMode valueOf(java.lang.String);
```

参数 `name` 必须为非 null 且大小写精确的 `GAP`、`BLACK_MARK` 或 `CONTINUOUS`；返回对应枚举常量。Java 自动生成此方法：null 抛出 `NullPointerException`，未匹配名称抛出 `IllegalArgumentException`。不按显示名称、数字或 ordinal 解析，不执行 IO。

文档 ID：`android:member:com.netumscan.printersdk.MediaMode:25dac0f8c6207093`

JVM descriptor：`(Ljava/lang/String;)Lcom/netumscan/printersdk/MediaMode;`

这是 Java 编译器为枚举生成的公共方法。

<a id="api-5e48053988753ec90a1e"></a>

### public static com.netumscan.printersdk.MediaMode[] values()

返回按声明顺序排列的介质枚举数组。

```java
public static com.netumscan.printersdk.MediaMode[] values();
```

无参数，返回新数组 `[GAP, BLACK_MARK, CONTINUOUS]`。这是 Java 枚举自动生成的辅助方法；修改返回数组不改变枚举常量集合。顺序仅用于枚举展示，不能推断设备支持或协议数值。

文档 ID：`android:member:com.netumscan.printersdk.MediaMode:e6138ae9aa44ee4e`

JVM descriptor：`()[Lcom/netumscan/printersdk/MediaMode;`

这是 Java 编译器为枚举生成的公共方法。

<a id="api-011c7bd7bc5fb2bb6e29"></a>

### public static final com.netumscan.printersdk.MediaMode BLACK_MARK

黑标介质的跟踪模式。

```java
public static final com.netumscan.printersdk.MediaMode BLACK_MARK;
```

用于已装入黑标介质的 CPCL 跟踪设置；不测量标记长度、偏移或纸张位置，不执行传感器校准。枚举存在不表示所有设备固件支持该模式。

文档 ID：`android:member:com.netumscan.printersdk.MediaMode:f19064fdd38fb10e`

JVM descriptor：`Lcom/netumscan/printersdk/MediaMode;`

<a id="api-13c48e699eb17d12cb27"></a>

### public static final com.netumscan.printersdk.MediaMode CONTINUOUS

连续纸的介质跟踪模式。

```java
public static final com.netumscan.printersdk.MediaMode CONTINUOUS;
```

用于 CPCL 连续介质跟踪设置；不会自动将标签作业转换为 ESC/POS 小票，也不控制切刀。应用须提供匹配的纸张和打印参数。

文档 ID：`android:member:com.netumscan.printersdk.MediaMode:cf069c583bcf0729`

JVM descriptor：`Lcom/netumscan/printersdk/MediaMode;`

<a id="api-904ffa7e8f2a61c5f45d"></a>

### public static final com.netumscan.printersdk.MediaMode GAP

间隙标签的介质跟踪模式。

```java
public static final com.netumscan.printersdk.MediaMode GAP;
```

用于已装入间隙标签的 CPCL 跟踪设置；不自动测量间隙、设置标签尺寸或执行校准。调用 `setMedia()` 仍可能因设备/协议不支持而失败，成功只证明命令数据已发送。

文档 ID：`android:member:com.netumscan.printersdk.MediaMode:4b03b38b1cbe2f6a`

JVM descriptor：`Lcom/netumscan/printersdk/MediaMode;`

<a id="api-2f5be4c6d23e94746056"></a>

## MediaRequirement

作业提交的显式介质前置条件。

```java
public final class com.netumscan.printersdk.MediaRequirement
```

包含非null MediaSettings和证据策略，不自动设置介质。当前仅CPCL tracking+ALLOW_LAST_SENT可用；REQUIRE_READBACK及其他字段在提交前1004拒绝，不自动降级。

文档 ID：`android:type:com.netumscan.printersdk.MediaRequirement`

<a id="api-934cea35f180203cee46"></a>

### public com.netumscan.printersdk.MediaRequirement(com.netumscan.printersdk.MediaSettings, int)

保存介质前置条件及证据策略。

```java
public com.netumscan.printersdk.MediaRequirement(com.netumscan.printersdk.MediaSettings, int);
```

settings不可null；policy只接受ALLOW_LAST_SENT=1或REQUIRE_READBACK=2，否则IllegalArgumentException。不执行IO；当前仅CPCL tracking+LAST_SENT可提交，读回在IO前1004拒绝。

文档 ID：`android:member:com.netumscan.printersdk.MediaRequirement:9b01646a36c59049`

JVM descriptor：`(Lcom/netumscan/printersdk/MediaSettings;I)V`

<a id="api-075e118dcce2937e38f1"></a>

### public final com.netumscan.printersdk.MediaSettings settings

介质前置条件的settings。

```java
public final com.netumscan.printersdk.MediaSettings settings;
```

settings为非null不可变MediaSettings；verificationPolicy为ALLOW_LAST_SENT=1或REQUIRE_READBACK=2。仅描述要求，不执行设置；当前读回策略不支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaRequirement:c1088016778c7033`

JVM descriptor：`Lcom/netumscan/printersdk/MediaSettings;`

<a id="api-6b3c71590e4b08e71543"></a>

### public final int verificationPolicy

介质前置条件的verificationPolicy。

```java
public final int verificationPolicy;
```

settings为非null不可变MediaSettings；verificationPolicy为ALLOW_LAST_SENT=1或REQUIRE_READBACK=2。仅描述要求，不执行设置；当前读回策略不支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaRequirement:8513b835b607017f`

JVM descriptor：`I`

<a id="api-763fa86084104696fcd6"></a>

### public static final int ALLOW_LAST_SENT = 1

ALLOW_LAST_SENT常量，值1。

```java
public static final int ALLOW_LAST_SENT = 1;
```

允许当前协议最近成功发送的介质缓存，非设备读回。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaRequirement:5f044e082d8420a3`

JVM descriptor：`I`

<a id="api-947792eed5478e949e92"></a>

### public static final int REQUIRE_READBACK = 2

REQUIRE_READBACK常量，值2。

```java
public static final int REQUIRE_READBACK = 2;
```

要求设备读回，当前IO前1004拒绝。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaRequirement:f4ae445776867292`

JVM descriptor：`I`

<a id="api-e5824d9e8f16babb6dab"></a>

## MediaSettings

以微米表示的不可变介质参数。

```java
public final class com.netumscan.printersdk.MediaSettings
```

null字段表示未指定，不能当作硬件默认；presentFields按非null字段生成。使用时tracking必须存在，现有标准后端只支持CPCL tracking，其他字段在IO前拒绝。

文档 ID：`android:type:com.netumscan.printersdk.MediaSettings`

<a id="api-06350cf378ee9c0d4586"></a>

### public com.netumscan.printersdk.MediaSettings(com.netumscan.printersdk.MediaMode, java.lang.Long, java.lang.Long, java.lang.Long, java.lang.Long, java.lang.Integer, int)

保存显式微米介质参数。

```java
public com.netumscan.printersdk.MediaSettings(com.netumscan.printersdk.MediaMode, java.lang.Long, java.lang.Long, java.lang.Long, java.lang.Long, java.lang.Integer, int);
```

tracking及尺寸字段可null，存在位据此生成；非null长度须在uint32范围（负数/超过0xffffffff构造IllegalArgumentException），实际操作进一步要求正数和tracking匹配。持久化policy只接受0或1；标准后端只支持tracking，其他字段IO前1004拒绝。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:e4681a628fcf986d`

JVM descriptor：`(Lcom/netumscan/printersdk/MediaMode;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/Integer;I)V`

<a id="api-ff2768b6972dcbc90dc5"></a>

### public final com.netumscan.printersdk.MediaMode tracking

生成仅含tracking的易失介质设置。

```java
public final com.netumscan.printersdk.MediaMode tracking;
```

mode不可null，其余字段未指定、policy=VOLATILE_ONLY。不执行IO；通过PrinterManager.setMedia提交。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:29ec59d75927919b`

JVM descriptor：`Lcom/netumscan/printersdk/MediaMode;`

<a id="api-6ce20c57ddf2984df3c5"></a>

### public final int persistencePolicy

介质persistencePolicy字段。

```java
public final int persistencePolicy;
```

VOLATILE_ONLY=0默认仅易失设置，ALLOW_PERSISTENT=1表示允许持久化，不要求后端必须持久化。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:3203af0199d0da68`

JVM descriptor：`I`

<a id="api-91c5a169dc65d41b9147"></a>

### public final int presentFields

介质presentFields字段。

```java
public final int presentFields;
```

TRACKING=1/GAP_LENGTH=2/LABEL_LENGTH=4/WIDTH=8/MARK_LENGTH=16/MARK_OFFSET=32，按非null字段生成。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:794dc497376c264f`

JVM descriptor：`I`

<a id="api-5c070755010f3fda64e6"></a>

### public final java.lang.Integer markOffsetMicrometers

介质markOffsetMicrometers字段。

```java
public final java.lang.Integer markOffsetMicrometers;
```

可选有符号黑标偏移（微米），仅BLACK_MARK模式。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:4a5c58d30f50366d`

JVM descriptor：`Ljava/lang/Integer;`

<a id="api-dada2dd1d134d006d048"></a>

### public final java.lang.Long gapLengthMicrometers

介质gapLengthMicrometers字段。

```java
public final java.lang.Long gapLengthMicrometers;
```

可选间隙（微米），仅GAP模式。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:49aefeb794b34aaf`

JVM descriptor：`Ljava/lang/Long;`

<a id="api-63d5c4618a10caef79aa"></a>

### public final java.lang.Long labelLengthMicrometers

介质labelLengthMicrometers字段。

```java
public final java.lang.Long labelLengthMicrometers;
```

可选标签长度（微米）。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:1ab71564f3d5b5a9`

JVM descriptor：`Ljava/lang/Long;`

<a id="api-b3363ec26b6c849ac06e"></a>

### public final java.lang.Long markLengthMicrometers

介质markLengthMicrometers字段。

```java
public final java.lang.Long markLengthMicrometers;
```

可选黑标长度（微米），仅BLACK_MARK模式。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:469334b25042ab9e`

JVM descriptor：`Ljava/lang/Long;`

<a id="api-837ac1cf2b702376736a"></a>

### public final java.lang.Long widthMicrometers

介质widthMicrometers字段。

```java
public final java.lang.Long widthMicrometers;
```

可选宽度（微米）。 null表示未指定，不是硬件报告；标准后端支持性在提交前校验。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:d98d979bb5fb0351`

JVM descriptor：`Ljava/lang/Long;`

<a id="api-eb04add88b1f2a07c336"></a>

### public static com.netumscan.printersdk.MediaSettings tracking(com.netumscan.printersdk.MediaMode)

生成仅含tracking的易失介质设置。

```java
public static com.netumscan.printersdk.MediaSettings tracking(com.netumscan.printersdk.MediaMode);
```

mode不可null，其余字段未指定、policy=VOLATILE_ONLY。不执行IO；通过PrinterManager.setMedia提交。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:ec3e07d79765b01f`

JVM descriptor：`(Lcom/netumscan/printersdk/MediaMode;)Lcom/netumscan/printersdk/MediaSettings;`

<a id="api-99b4670819c188d481e0"></a>

### public static final int ALLOW_PERSISTENT = 1

ALLOW_PERSISTENT常量，值1。

```java
public static final int ALLOW_PERSISTENT = 1;
```

允许后端持久化，不要求一定持久化。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:70ffa1d5adb462ca`

JVM descriptor：`I`

<a id="api-cdd22e96de0b4001e166"></a>

### public static final int GAP_LENGTH = 2

GAP_LENGTH常量，值2。

```java
public static final int GAP_LENGTH = 2;
```

表示GAP_LENGTH对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:baa2bf119fedcc5e`

JVM descriptor：`I`

<a id="api-e28057198450a2970dad"></a>

### public static final int LABEL_LENGTH = 4

LABEL_LENGTH常量，值4。

```java
public static final int LABEL_LENGTH = 4;
```

表示LABEL_LENGTH对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:7fc0684ca801c37f`

JVM descriptor：`I`

<a id="api-e40c8ce4469837329fee"></a>

### public static final int MARK_LENGTH = 16

MARK_LENGTH常量，值16。

```java
public static final int MARK_LENGTH = 16;
```

表示MARK_LENGTH对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:166a764d81b676c2`

JVM descriptor：`I`

<a id="api-91248227efd9d134953e"></a>

### public static final int MARK_OFFSET = 32

MARK_OFFSET常量，值32。

```java
public static final int MARK_OFFSET = 32;
```

表示MARK_OFFSET对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:542e43778f1fbf84`

JVM descriptor：`I`

<a id="api-298798dd8bd76c5f8357"></a>

### public static final int TRACKING = 1

TRACKING常量，值1。

```java
public static final int TRACKING = 1;
```

表示TRACKING对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:83415fc166517f4b`

JVM descriptor：`I`

<a id="api-cf997c833d8a6ef4cbd9"></a>

### public static final int VOLATILE_ONLY = 0

VOLATILE_ONLY常量，值0。

```java
public static final int VOLATILE_ONLY = 0;
```

仅允许易失设置。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:9275e9849a183175`

JVM descriptor：`I`

<a id="api-716625f2b58108b19de8"></a>

### public static final int WIDTH = 8

WIDTH常量，值8。

```java
public static final int WIDTH = 8;
```

表示WIDTH对应的已知/存在字段mask；先检查known或present位再解释相关字段。 不执行IO，不表示硬件已验证支持。

文档 ID：`android:member:com.netumscan.printersdk.MediaSettings:26874840ab7f4a0d`

JVM descriptor：`I`

<a id="api-5cf4c76272c2df7a9a90"></a>

## PreparedPrint

准备阶段产生的不可变打印描述。

```java
public final class com.netumscan.printersdk.PreparedPrint
```

描述标签或小票布局、图片/空白元素及可选介质要求；不持有native任务或图像句柄。Manager在后台导入像素并构建native job，重复引用同一像素对象只导入一次。

文档 ID：`android:type:com.netumscan.printersdk.PreparedPrint`

<a id="api-8617a994ccb9d516bea9"></a>

### public static com.netumscan.printersdk.PreparedPrint$Builder label(int, int, int)

创建标签布局的打印描述构建器。

```java
public static com.netumscan.printersdk.PreparedPrint$Builder label(int, int, int);
```

宽、高以dots计，dpi为明确分辨率；元素与原点等信息在build后固定，Manager负责后台native导入与校验。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:bb2ee17d7110b13e`

JVM descriptor：`(III)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-e7b052b087d3bd055711"></a>

### public static com.netumscan.printersdk.PreparedPrint$Builder receipt(int, long, int)

创建小票布局的打印描述构建器。

```java
public static com.netumscan.printersdk.PreparedPrint$Builder receipt(int, long, int);
```

宽度与最大长度以dots计，并指定dpi；可追加图像或空白，最终由Manager后台构建native任务。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:fb69c31c3d616b0b`

JVM descriptor：`(IJI)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-53c008e0301074d5af58"></a>

### public static final int BAYER_4X4 = 2

4×4 Bayer抖动。

```java
public static final int BAYER_4X4 = 2;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:0dcb27f1cd32e35c`

JVM descriptor：`I`

<a id="api-771700c49c1997c40209"></a>

### public static final int BAYER_8X8 = 3

8×8 Bayer抖动。

```java
public static final int BAYER_8X8 = 3;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:122522976173ccef`

JVM descriptor：`I`

<a id="api-9b2738ba3a169d64fd0a"></a>

### public static final int CUT_FULL = 1

全切纸。

```java
public static final int CUT_FULL = 1;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:64956941107fd9c3`

JVM descriptor：`I`

<a id="api-841edbae5f025122122e"></a>

### public static final int CUT_NONE = 0

不切纸。

```java
public static final int CUT_NONE = 0;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:a31548e7e8ce3a2e`

JVM descriptor：`I`

<a id="api-228f18e16e242eff52b8"></a>

### public static final int CUT_PARTIAL = 2

半切纸。

```java
public static final int CUT_PARTIAL = 2;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:b6051533a14a0c38`

JVM descriptor：`I`

<a id="api-2ba47dc359bab6fc5b11"></a>

### public static final int EACH_COPY = 0

每一份应用尾部处理。

```java
public static final int EACH_COPY = 0;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:447559c0d9447997`

JVM descriptor：`I`

<a id="api-740d8bc387a75bf68376"></a>

### public static final int END_OF_JOB = 1

整任务结束应用尾部处理。

```java
public static final int END_OF_JOB = 1;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:0714561c652f45aa`

JVM descriptor：`I`

<a id="api-84aec6509d021e1eb22a"></a>

### public static final int FLOYD_STEINBERG = 1

Floyd-Steinberg抖动。

```java
public static final int FLOYD_STEINBERG = 1;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:17319debb6248132`

JVM descriptor：`I`

<a id="api-cc8d78ec34350969517e"></a>

### public static final int GRAY8 = 1

一字节灰度像素格式。

```java
public static final int GRAY8 = 1;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:4909d4185765b94a`

JVM descriptor：`I`

<a id="api-d63f0a63ad2b60c3d27b"></a>

### public static final int RGB24 = 2

三字节RGB像素格式。

```java
public static final int RGB24 = 2;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:72c70a2f4730535e`

JVM descriptor：`I`

<a id="api-1e746648e751eb7ba9e0"></a>

### public static final int RGBA32 = 3

四字节RGBA像素格式。

```java
public static final int RGBA32 = 3;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:5ff7bf192f2c5b09`

JVM descriptor：`I`

<a id="api-e66987c4630e845630d4"></a>

### public static final int THRESHOLD = 0

阈值二值化。

```java
public static final int THRESHOLD = 0;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint:885594684c18a57d`

JVM descriptor：`I`

<a id="api-9acaf968b2de3c0d2d3d"></a>

## PreparedPrint.Builder

构造纯数据打印描述的构建器。

```java
public final class com.netumscan.printersdk.PreparedPrint$Builder
```

设置布局选项并追加元素后调用build生成不可变PreparedPrint。该构建器不执行设备IO；在Manager的preparation回调中完成耗时准备。

文档 ID：`android:type:com.netumscan.printersdk.PreparedPrint$Builder`

<a id="api-0ab9ead54f180df7f147"></a>

### public com.netumscan.printersdk.PreparedPrint build()

固定当前布局和元素并生成PreparedPrint。

```java
public com.netumscan.printersdk.PreparedPrint build();
```

复制构建器元素清单形成不可变描述；像素数据不因此重复导入native，后续Manager仍执行完整校验。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:d900c33e25f03f69`

JVM descriptor：`()Lcom/netumscan/printersdk/PreparedPrint;`

<a id="api-e0cee1e48780f69702c7"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder addImage(com.netumscan.printersdk.PreparedPrint$Pixels, int, int)

在指定标签坐标添加像素元素。

```java
public com.netumscan.printersdk.PreparedPrint$Builder addImage(com.netumscan.printersdk.PreparedPrint$Pixels, int, int);
```

x、y以dots计；同一Pixels对象可被多元素引用，native导入阶段共享一次图像存储。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:de70c2c8e2a844e5`

JVM descriptor：`(Lcom/netumscan/printersdk/PreparedPrint$Pixels;II)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-464f27b4f40daa22908e"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder appendBlank(int)

向小票追加指定dots的空白。

```java
public com.netumscan.printersdk.PreparedPrint$Builder appendBlank(int);
```

只记录空白描述，参数与布局在构建/准入时校验；不会在调用构建器方法时发送设备命令。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:9d6ca812b38d2212`

JVM descriptor：`(I)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-0a5b355fc9feadc82bed"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder appendImage(com.netumscan.printersdk.PreparedPrint$Pixels)

向小票顺序追加像素元素。

```java
public com.netumscan.printersdk.PreparedPrint$Builder appendImage(com.netumscan.printersdk.PreparedPrint$Pixels);
```

仅用于小票构建器；相邻元素的顺序决定输出顺序，复用Pixels不会额外创建重复native图像。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:21f9b2f4c8e7c2bc`

JVM descriptor：`(Lcom/netumscan/printersdk/PreparedPrint$Pixels;)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-254bdd08bd74b84bb90f"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder copies(int)

设置整个打印描述的份数。

```java
public com.netumscan.printersdk.PreparedPrint$Builder copies(int);
```

使用有效正整数；份数与完成范围在native准入时校验，不通过应用循环自动重放失败任务。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:4f6f683c9d09277c`

JVM descriptor：`(I)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-096948fcb267611e32b7"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder mediaRequirement(com.netumscan.printersdk.MediaRequirement)

绑定打印任务要求的介质条件。

```java
public com.netumscan.printersdk.PreparedPrint$Builder mediaRequirement(com.netumscan.printersdk.MediaRequirement);
```

描述任务对介质设置的明确要求；该值不执行隐式型号探测或自动介质恢复。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:22e9666355086120`

JVM descriptor：`(Lcom/netumscan/printersdk/MediaRequirement;)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-d5aaebec1aa584949f1b"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder nextLabel(boolean)

设置标签打印后的下一张定位要求。

```java
public com.netumscan.printersdk.PreparedPrint$Builder nextLabel(boolean);
```

只记录本次标签请求的完成要求；最终是否支持由明确profile能力决定。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:27570e49e4b5f7b4`

JVM descriptor：`(Z)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-c31db99a6dfeef6e0613"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder origin(int, int)

设置标签原点偏移。

```java
public com.netumscan.printersdk.PreparedPrint$Builder origin(int, int);
```

x、y以dots计，仅适用于标签布局；不改变像素准备和协议编码的分层。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:e368678d47a99dce`

JVM descriptor：`(II)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-1b6fe367072b80ab0442"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder receiptFinish(int, int, int)

设置小票尾部空白、切纸方式和应用范围。

```java
public com.netumscan.printersdk.PreparedPrint$Builder receiptFinish(int, int, int);
```

尾部空白以dots计，cutMode和finishScope使用PreparedPrint常量；不支持切纸时由准入校验拒绝。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:b9150a9859c07c55`

JVM descriptor：`(III)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-7a856229800daad8444a"></a>

### public com.netumscan.printersdk.PreparedPrint$Builder receiptMargins(int, int)

设置小票左右边距。

```java
public com.netumscan.printersdk.PreparedPrint$Builder receiptMargins(int, int);
```

leftDots、rightDots以dots计，仅对小票布局有效；不会通过缩放图像暗中改变纸张宽度。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Builder:fd1f365df039aeb0`

JVM descriptor：`(II)Lcom/netumscan/printersdk/PreparedPrint$Builder;`

<a id="api-52e18138e529bfa1a76c"></a>

## PreparedPrint.Pixels

原始像素及图像处理参数。

```java
public final class com.netumscan.printersdk.PreparedPrint$Pixels
```

只描述GRAY8、RGB24或RGBA32原始像素；编码图片解码由应用准备函数负责。传入byte[]从准备提交到请求终态保持只读，同一Pixels对象重复使用时共享一次native导入。

文档 ID：`android:type:com.netumscan.printersdk.PreparedPrint$Pixels`

<a id="api-f769f13c96f24617f0db"></a>

### public com.netumscan.printersdk.PreparedPrint$Pixels(byte[], int, int, int, int, int, boolean, int)

构造PreparedPrint$Pixels只读数据。

```java
public com.netumscan.printersdk.PreparedPrint$Pixels(byte[], int, int, int, int, int, boolean, int);
```

只描述GRAY8、RGB24或RGBA32原始像素；编码图片解码由应用准备函数负责。传入byte[]从准备提交到请求终态保持只读，同一Pixels对象重复使用时共享一次native导入。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:01112b49f4903a1f`

JVM descriptor：`([BIIIIIZI)V`

<a id="api-dbe5c3107692807ec377"></a>

### public final boolean invert

是否反转输出黑白。

```java
public final boolean invert;
```

只改变图像处理配置，不修改输入像素对象。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:702f6f1660fce0d8`

JVM descriptor：`Z`

<a id="api-2b460e5c14f643e38872"></a>

### public final int algorithm

二值化算法。

```java
public final int algorithm;
```

选择阈值、Floyd-Steinberg或Bayer算法；图像处理独立于协议编码。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:6d8363603cc9fb29`

JVM descriptor：`I`

<a id="api-e115c8f44ce3e289f679"></a>

### public final int format

原始像素格式。

```java
public final int format;
```

选择GRAY8、RGB24或RGBA32；输入数据长度与宽高须一致。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:7d80c06872b09b89`

JVM descriptor：`I`

<a id="api-2f3b4ef48902ab86e34e"></a>

### public final int height

原图高度。

```java
public final int height;
```

单位为像素；大图按SDK图像/协议流水线分块处理，不要求完整最终打印缓冲区。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:1e8b3775e799a9fa`

JVM descriptor：`I`

<a id="api-8f60b8f57e5328fe8179"></a>

### public final int targetWidthDots

缩放目标宽度。

```java
public final int targetWidthDots;
```

单位为打印dots；默认0表示不提供显式目标宽度，实际行为遵循图像适配配置。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:65cdfcdcafb435c0`

JVM descriptor：`I`

<a id="api-11088a51f4bd6745b2b3"></a>

### public final int threshold

二值化阈值。

```java
public final int threshold;
```

有效范围按图像契约校验，默认128；不改变原始像素格式。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:b0f72a281f2c8781`

JVM descriptor：`I`

<a id="api-f628ffc14780e5016ad7"></a>

### public final int width

原图宽度。

```java
public final int width;
```

单位为像素，与height和format共同确定输入数据布局；不等同于传输分块大小。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:5727cdfd5221243c`

JVM descriptor：`I`

<a id="api-d5fd81bb07f52ad8e40f"></a>

### public static com.netumscan.printersdk.PreparedPrint$Pixels gray8(byte[], int, int)

用默认阈值设置构造GRAY8像素描述。

```java
public static com.netumscan.printersdk.PreparedPrint$Pixels gray8(byte[], int, int);
```

传入一字节灰度像素及宽高，默认threshold=128且不反色、不强制目标宽度；byte[]在请求完成前保持只读。

文档 ID：`android:member:com.netumscan.printersdk.PreparedPrint$Pixels:46d6216c01ea5816`

JVM descriptor：`([BII)Lcom/netumscan/printersdk/PreparedPrint$Pixels;`

<a id="api-4dc5d455340db9937535"></a>

## PrintOptions

请求总超时配置。

```java
public final class com.netumscan.printersdk.PrintOptions
```

超时预算覆盖等待、应用准备、native准入和执行阶段；timeoutMs/timeoutMilliseconds使用毫秒，必须为有效正值。

文档 ID：`android:type:com.netumscan.printersdk.PrintOptions`

<a id="api-107c99c34589685041cd"></a>

### public com.netumscan.printersdk.PrintOptions(int)

构造PrintOptions只读数据。

```java
public com.netumscan.printersdk.PrintOptions(int);
```

超时预算覆盖等待、应用准备、native准入和执行阶段；timeoutMs/timeoutMilliseconds使用毫秒，必须为有效正值。

文档 ID：`android:member:com.netumscan.printersdk.PrintOptions:e86d26104a321d47`

JVM descriptor：`(I)V`

<a id="api-4c7c59da4716bbbc5f26"></a>

### public final int timeoutMs

请求总超时配置。

```java
public final int timeoutMs;
```

超时预算覆盖等待、应用准备、native准入和执行阶段；timeoutMs/timeoutMilliseconds使用毫秒，必须为有效正值。

文档 ID：`android:member:com.netumscan.printersdk.PrintOptions:ccf22bfbf1a01308`

JVM descriptor：`I`

<a id="api-a36171733f6c01585161"></a>

## PrinterCapabilities

聚合本地能力、约束与几何观察。

```java
public final class com.netumscan.printersdk.PrinterCapabilities
```

八项feature、四项constraint和geometry分别保留known/deviceSupport/evidence。不执行IO、不预留接纳额度；纯连接设备几何未知，不能由最近Profile或零数值推断硬件支持。

文档 ID：`android:type:com.netumscan.printersdk.PrinterCapabilities`

<a id="api-99761482a4773c008c52"></a>

### public com.netumscan.printersdk.FeatureSupport feature(int)

按ID取一项功能能力。

```java
public com.netumscan.printersdk.FeatureSupport feature(int);
```

ID1..8对应PrinterManager功能常量；其他ID返回unknown/未实现值，不执行IO。实现、deviceSupport与evidence独立，检查knownFields后才能解释集合mask。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:02554ca7e27ea317`

JVM descriptor：`(I)Lcom/netumscan/printersdk/FeatureSupport;`

<a id="api-e4cdb110786ced1f5c22"></a>

### public com.netumscan.printersdk.ScalarConstraint constraint(int)

按ID取一项范围约束。

```java
public com.netumscan.printersdk.ScalarConstraint constraint(int);
```

ID1..4对应PrinterConstraint参数；其他ID返回known=false，不执行IO。copies及源载荷额度是SDK策略，未知介质范围不是无限。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:a258c0e7ea03dc6f`

JVM descriptor：`(I)Lcom/netumscan/printersdk/ScalarConstraint;`

<a id="api-1144e63ac4d0fc5c6a33"></a>

### public final int dpiX

打印几何dpiX观察值。

```java
public final int dpiX;
```

横向DPI，须geometryPresentFields的DPI位1有效。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:5253b3056074e745`

JVM descriptor：`I`

<a id="api-442b043e5d7a36e6f759"></a>

### public final int dpiY

打印几何dpiY观察值。

```java
public final int dpiY;
```

纵向DPI，须DPI位1有效。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:414f3289a65cc726`

JVM descriptor：`I`

<a id="api-b2acb3e6aacd017bcd27"></a>

### public final int geometryEvidence

打印几何geometryEvidence观察值。

```java
public final int geometryEvidence;
```

PROFILE_DECLARED=1、DEVICE_REPORTED=2、HARDWARE_VERIFIED=4；零表示无证据。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:913c74adc3bf7c03`

JVM descriptor：`I`

<a id="api-6ef929d87e42388914f9"></a>

### public final int geometryPresentFields

打印几何geometryPresentFields观察值。

```java
public final int geometryPresentFields;
```

DPI=1、WIDTH=2、LENGTH=4、CUT_BLANK=8；未知字段数值零不能解释为已知零或无限。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:cf4ac59529e54952`

JVM descriptor：`I`

<a id="api-cf25b3fad6e01659f4c4"></a>

### public final int maxPageLengthDots

打印几何maxPageLengthDots观察值。

```java
public final int maxPageLengthDots;
```

一页/一份最大长度（点），须LENGTH位4有效，不乘copies，不是小票整单预算。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:d4fa201acc001d96`

JVM descriptor：`I`

<a id="api-0bc443d11dcb982b726a"></a>

### public final int minCutBlankDots

打印几何minCutBlankDots观察值。

```java
public final int minCutBlankDots;
```

切纸前最小留白（点），须CUT_BLANK位8有效。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:fd704893c25f2b1c`

JVM descriptor：`I`

<a id="api-5cd56ea0b31eb4942545"></a>

### public final int printableWidthDots

打印几何printableWidthDots观察值。

```java
public final int printableWidthDots;
```

可打印宽度（点），须WIDTH位2有效。 当前纯通信设备无几何证据，必须检查存在位，不能从数值零推断正常或支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterCapabilities:338e757da58637fb`

JVM descriptor：`I`

<a id="api-bfc786be5b911ef74d19"></a>

## PrinterManager

独立的单设备打印会话。

```java
public final class com.netumscan.printersdk.PrinterManager
```

通过构造器创建独立实例；连接、发现、打印、控制、查询和清理均由此入口管理。请求立即返回标识，完成结果异步投递到主线程；准备与准入保持请求顺序，打印机IO始终由native设备队列串行执行，不自动重连、重放或重试。

文档 ID：`android:type:com.netumscan.printersdk.PrinterManager`

<a id="api-6761fb538c137c164625"></a>

### public com.netumscan.printersdk.PrinterManager(android.content.Context)

创建独立Manager实例。

```java
public com.netumscan.printersdk.PrinterManager(android.content.Context);
```

每个实例至多管理一个连接；不使用共享单例。应用按页面或业务所有权保存实例，并在结束时调用异步close释放资源。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:989371a8a2f8fb1d`

JVM descriptor：`(Landroid/content/Context;)V`

<a id="api-67aaa2c77fa3ef876418"></a>

### public com.netumscan.printersdk.RequestId bondedDevices(com.netumscan.printersdk.PrinterManager$Callback<java.util.List<com.netumscan.printersdk.DiscoveredDevice>>)

枚举系统已配对的经典蓝牙设备。

```java
public com.netumscan.printersdk.RequestId bondedDevices(com.netumscan.printersdk.PrinterManager$Callback<java.util.List<com.netumscan.printersdk.DiscoveredDevice>>);
```

Android通过Manager异步返回只读设备列表；iOS不提供SPP配对枚举，使用同一异步完成通道返回Unsupported，不发起隐式配对。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:250ef332e85fdb96`

JVM descriptor：`(Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-aa164db0d48e84572c33"></a>

### public com.netumscan.printersdk.RequestId capabilities(com.netumscan.printersdk.PrinterManager$Callback<com.netumscan.printersdk.PrinterCapabilities>)

读取当前设备的能力描述。

```java
public com.netumscan.printersdk.RequestId capabilities(com.netumscan.printersdk.PrinterManager$Callback<com.netumscan.printersdk.PrinterCapabilities>);
```

异步交付PrinterCapabilities；未知或不支持的能力应按描述处理，能力查询不执行自动打印探测，也不替代每次请求的准入校验。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:3b59a91b1fcc68e8`

JVM descriptor：`(Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-704c0cf7d94eeebbfb7f"></a>

### public com.netumscan.printersdk.RequestId close(com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

永久关闭Manager并释放其连接资源。

```java
public com.netumscan.printersdk.RequestId close(com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

这是幂等的异步清理屏障；所有属于该会话的请求终态先交付，清理完成后再交付close回调。关闭后业务请求异步返回InvalidState。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:9ffe7f34b33337a5`

JVM descriptor：`(Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-351a74d77bb03f0bdc72"></a>

### public com.netumscan.printersdk.RequestId connect(com.netumscan.printersdk.ConnectionOptions, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>, com.netumscan.printersdk.PrinterManager$DisconnectedListener)

连接指定设备。

```java
public com.netumscan.printersdk.RequestId connect(com.netumscan.printersdk.ConnectionOptions, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>, com.netumscan.printersdk.PrinterManager$DisconnectedListener);
```

立即返回请求标识；连接成功或失败通过主线程完成回调交付。每个Manager至多拥有一个设备连接，意外断连通过本次连接的onDisconnected通知，不自动重连。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:7758906a23f2affa`

JVM descriptor：`(Lcom/netumscan/printersdk/ConnectionOptions;ILcom/netumscan/printersdk/PrinterManager$Callback;Lcom/netumscan/printersdk/PrinterManager$DisconnectedListener;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-eace0338b53324c15ab8"></a>

### public com.netumscan.printersdk.RequestId disconnect(com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

关闭当前连接并结束本会话请求。

```java
public com.netumscan.printersdk.RequestId disconnect(com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

尽快取消等待、准备和native任务并异步释放资源；清理完成后才可显式连接新设备。不合作的准备代码可以迟到返回，但结果不会再次准入。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:9b3300e7a5bc65cd`

JVM descriptor：`(Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-749f2f0f27db36618600"></a>

### public com.netumscan.printersdk.RequestId locateNextLabel(com.netumscan.printersdk.CpclProfile, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

提交定位下一张标签请求。

```java
public com.netumscan.printersdk.RequestId locateNextLabel(com.netumscan.printersdk.CpclProfile, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

指定CpclProfile并在同一native设备队列执行；仅在设备profile声明支持时可用，不自行猜测定位命令。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:4cb506aa83355555`

JVM descriptor：`(Lcom/netumscan/printersdk/CpclProfile;ILcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-b1350d512c685d6b43f8"></a>

### public com.netumscan.printersdk.RequestId print(com.netumscan.printersdk.CpclProfile, com.netumscan.printersdk.PrintOptions, com.netumscan.printersdk.PrinterManager$Preparation, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

准备并提交一次标签或小票打印请求。

```java
public com.netumscan.printersdk.RequestId print(com.netumscan.printersdk.CpclProfile, com.netumscan.printersdk.PrintOptions, com.netumscan.printersdk.PrinterManager$Preparation, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

profile选择本次编码协议；preparation在后台产生PreparedPrint，options限制总超时。调用顺序决定准备准入顺序，完成回调区分dataSent与deviceConfirmed；任何失败都不自动重试或重放。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:e9a6f4131a96c701`

JVM descriptor：`(Lcom/netumscan/printersdk/CpclProfile;Lcom/netumscan/printersdk/PrintOptions;Lcom/netumscan/printersdk/PrinterManager$Preparation;Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-0f0f84483fed6f61bc23"></a>

### public com.netumscan.printersdk.RequestId print(com.netumscan.printersdk.EscPosProfile, com.netumscan.printersdk.PrintOptions, com.netumscan.printersdk.PrinterManager$Preparation, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

准备并提交一次标签或小票打印请求。

```java
public com.netumscan.printersdk.RequestId print(com.netumscan.printersdk.EscPosProfile, com.netumscan.printersdk.PrintOptions, com.netumscan.printersdk.PrinterManager$Preparation, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

profile选择本次编码协议；preparation在后台产生PreparedPrint，options限制总超时。调用顺序决定准备准入顺序，完成回调区分dataSent与deviceConfirmed；任何失败都不自动重试或重放。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:0b55b4dc3454c79a`

JVM descriptor：`(Lcom/netumscan/printersdk/EscPosProfile;Lcom/netumscan/printersdk/PrintOptions;Lcom/netumscan/printersdk/PrinterManager$Preparation;Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-f54cb667a80e5fd96c3e"></a>

### public com.netumscan.printersdk.RequestId queryStatus(com.netumscan.printersdk.StatusQueryConfig, int, com.netumscan.printersdk.PrinterManager$Callback<com.netumscan.printersdk.StatusResult>)

提交硬件状态查询请求。

```java
public com.netumscan.printersdk.RequestId queryStatus(com.netumscan.printersdk.StatusQueryConfig, int, com.netumscan.printersdk.PrinterManager$Callback<com.netumscan.printersdk.StatusResult>);
```

配置明确协议请求、响应和超时；请求/响应事务占用同一设备队列。结果通过StatusResult报告已知位与活动位，不支持查询时异步失败。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:8cb94bf2e247d99b`

JVM descriptor：`(Lcom/netumscan/printersdk/StatusQueryConfig;ILcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-efdba753fb81e704f7f0"></a>

### public com.netumscan.printersdk.RequestId scanBle(java.util.UUID, int, com.netumscan.printersdk.PrinterManager$Callback<java.util.List<com.netumscan.printersdk.DiscoveredDevice>>)

枚举一段时间内发现的BLE设备。

```java
public com.netumscan.printersdk.RequestId scanBle(java.util.UUID, int, com.netumscan.printersdk.PrinterManager$Callback<java.util.List<com.netumscan.printersdk.DiscoveredDevice>>);
```

服务过滤和扫描时长由请求给定，结果只含只读DiscoveredDevice数据；扫描由Manager持有并可按请求标识取消。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:a66e97929d58d2ae`

JVM descriptor：`(Ljava/util/UUID;ILcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-89db5e6d23981953297a"></a>

### public com.netumscan.printersdk.RequestId sdkInfo(com.netumscan.printersdk.PrinterManager$Callback<com.netumscan.printersdk.SdkInfo>)

读取已加载SDK的身份信息。

```java
public com.netumscan.printersdk.RequestId sdkInfo(com.netumscan.printersdk.PrinterManager$Callback<com.netumscan.printersdk.SdkInfo>);
```

异步交付分发版本、native版本及ABI版本/修订，用于本地集成诊断；该值不等同于硬件验证证明。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:cabce4d23a0c13a1`

JVM descriptor：`(Lcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-b5659199b3bac62370ba"></a>

### public com.netumscan.printersdk.RequestId sendRaw(byte[], int, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

发送显式原始命令请求。

```java
public com.netumscan.printersdk.RequestId sendRaw(byte[], int, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

入口先检查非空、copies 为 1..100、超时为正，否则异步回调 1001；再检查载荷超过 1MiB 返回 1008，恰好等于允许；再检查生命周期返回 1002、64 个未结束业务请求预算返回 1008。有效输入在返回前制作有界快照，最终入队原子复检容量。全部 Raw 与打印、介质、查询共用同一 native FIFO；不解析载荷协议语义。入口拒绝不产生输出，结果仍由一次主线程回调交付。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:4906567398108084`

JVM descriptor：`([BIILcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-3c6f9674bbf993229af8"></a>

### public com.netumscan.printersdk.RequestId setMedia(com.netumscan.printersdk.MediaSettings, com.netumscan.printersdk.CpclProfile, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>)

提交介质设置控制请求。

```java
public com.netumscan.printersdk.RequestId setMedia(com.netumscan.printersdk.MediaSettings, com.netumscan.printersdk.CpclProfile, int, com.netumscan.printersdk.PrinterManager$Callback<java.lang.Void>);
```

使用MediaSettings和明确CpclProfile描述设置，能力与参数经校验后在同一设备队列执行；不支持的字段返回稳定错误，不依据型号猜测支持。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:bba5c8c4158d41a7`

JVM descriptor：`(Lcom/netumscan/printersdk/MediaSettings;Lcom/netumscan/printersdk/CpclProfile;ILcom/netumscan/printersdk/PrinterManager$Callback;)Lcom/netumscan/printersdk/RequestId;`

<a id="api-99a5653b30edc0f80216"></a>

### public static final int FEATURE_CUT = 5

切纸能力。

```java
public static final int FEATURE_CUT = 5;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:7ac9bf17bd0dbac2`

JVM descriptor：`I`

<a id="api-860b6fb550faa21e1bc8"></a>

### public static final int FEATURE_FEED_TO_NEXT_LABEL = 8

下一张标签定位能力。

```java
public static final int FEATURE_FEED_TO_NEXT_LABEL = 8;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:bb60d15581a3e604`

JVM descriptor：`I`

<a id="api-5862e2dc34ab7af5aafc"></a>

### public static final int FEATURE_IMAGE = 7

图像打印能力。

```java
public static final int FEATURE_IMAGE = 7;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:bbf3ec21c86c2b1d`

JVM descriptor：`I`

<a id="api-99fc492258e13ba8a594"></a>

### public static final int FEATURE_LABEL = 1

标签打印能力。

```java
public static final int FEATURE_LABEL = 1;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:4c5619690e84e1bf`

JVM descriptor：`I`

<a id="api-719f05fa74d690d82c3b"></a>

### public static final int FEATURE_MEDIA = 4

介质设置能力。

```java
public static final int FEATURE_MEDIA = 4;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:bdac68bb07a3ff93`

JVM descriptor：`I`

<a id="api-99299bc1232a036b8491"></a>

### public static final int FEATURE_RAW = 6

原始命令能力。

```java
public static final int FEATURE_RAW = 6;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:7bb504424a281ed6`

JVM descriptor：`I`

<a id="api-e0a815cc01161ca39ea6"></a>

### public static final int FEATURE_RECEIPT = 2

小票打印能力。

```java
public static final int FEATURE_RECEIPT = 2;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:34743d368e7191d9`

JVM descriptor：`I`

<a id="api-b39525c6bb6bc9b8c8ca"></a>

### public static final int FEATURE_STATUS = 3

状态查询能力。

```java
public static final int FEATURE_STATUS = 3;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:57a2e549cda799a3`

JVM descriptor：`I`

<a id="api-c495b55a4368ea9d6525"></a>

### public void cancel(com.netumscan.printersdk.RequestId)

请求取消本Manager拥有的请求。

```java
public void cancel(com.netumscan.printersdk.RequestId);
```

取消意图覆盖等待、准备、准入与native执行阶段；外部Manager的标识和已完成请求不改变设备。取消本身不证明没有输出，最终结果的outputMayHaveOccurred用于提示可能已部分发送。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager:80c2dece04d1d2f6`

JVM descriptor：`(Lcom/netumscan/printersdk/RequestId;)V`

<a id="api-a8eff59edaee0576f508"></a>

## PrinterManager.Callback

单次业务请求的完成回调。

```java
public interface com.netumscan.printersdk.PrinterManager$Callback<T>
```

Manager在主线程异步交付一次ManagerResult；参数错误、状态错误、准备失败、准入失败和native终态都使用同一完成通道。

文档 ID：`android:type:com.netumscan.printersdk.PrinterManager$Callback`

<a id="api-d4c89b1859fbe8158588"></a>

### public abstract void completed(com.netumscan.printersdk.ManagerResult<T>)

单次业务请求的完成回调。

```java
public abstract void completed(com.netumscan.printersdk.ManagerResult<T>);
```

Manager在主线程异步交付一次ManagerResult；参数错误、状态错误、准备失败、准入失败和native终态都使用同一完成通道。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager$Callback:a4abf86f61088fa4`

JVM descriptor：`(Lcom/netumscan/printersdk/ManagerResult;)V`

<a id="api-9149b393dfb876ce6b8e"></a>

## PrinterManager.DisconnectedListener

当前连接的意外断连通知。

```java
public interface com.netumscan.printersdk.PrinterManager$DisconnectedListener
```

通知只属于注册时的连接会话；主动disconnect通过自身完成回调报告，旧会话事件不能影响后续连接。

文档 ID：`android:type:com.netumscan.printersdk.PrinterManager$DisconnectedListener`

<a id="api-63a9a27aa8820f2c2db8"></a>

### public abstract void disconnected(com.netumscan.printersdk.ManagerResult<java.lang.Void>)

当前连接的意外断连通知。

```java
public abstract void disconnected(com.netumscan.printersdk.ManagerResult<java.lang.Void>);
```

通知只属于注册时的连接会话；主动disconnect通过自身完成回调报告，旧会话事件不能影响后续连接。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager$DisconnectedListener:95c5f6c8a06cc7be`

JVM descriptor：`(Lcom/netumscan/printersdk/ManagerResult;)V`

<a id="api-926b9d0552ac918f6e21"></a>

## PrinterManager.Preparation

后台像素准备函数。

```java
public interface com.netumscan.printersdk.PrinterManager$Preparation
```

在Manager后台工作线程执行，接收CancellationContext并返回PreparedPrint。可抛出准备错误；不得在此执行设备IO或假定清理会等待不合作的准备代码。

文档 ID：`android:type:com.netumscan.printersdk.PrinterManager$Preparation`

<a id="api-71d53807452a19f29817"></a>

### public abstract com.netumscan.printersdk.PreparedPrint prepare(com.netumscan.printersdk.CancellationContext) throws java.lang.Exception

后台像素准备函数。

```java
public abstract com.netumscan.printersdk.PreparedPrint prepare(com.netumscan.printersdk.CancellationContext) throws java.lang.Exception;
```

在Manager后台工作线程执行，接收CancellationContext并返回PreparedPrint。可抛出准备错误；不得在此执行设备IO或假定清理会等待不合作的准备代码。

文档 ID：`android:member:com.netumscan.printersdk.PrinterManager$Preparation:8098e318858ba01d`

JVM descriptor：`(Lcom/netumscan/printersdk/CancellationContext;)Lcom/netumscan/printersdk/PreparedPrint;`

<a id="api-764c5a4147cfdf641cc3"></a>

## RequestId

仅由原Manager识别的不透明请求标识。

```java
public final class com.netumscan.printersdk.RequestId
```

将该值交给返回它的Manager.cancel请求取消；标识本身不持有native任务句柄，也不提供独立打印控制入口。

文档 ID：`android:type:com.netumscan.printersdk.RequestId`

<a id="api-29b3eab038d8022694c1"></a>

### public java.lang.String toString()

读取请求标识的辅助文本。

```java
public java.lang.String toString();
```

仅用于应用诊断；取消应传递原RequestId对象，不应解析文本重建native任务标识。

文档 ID：`android:member:com.netumscan.printersdk.RequestId:a9e4d7b84d18cdab`

JVM descriptor：`()Ljava/lang/String;`

<a id="api-b49ec93e3a988bef134a"></a>

## ScalarConstraint

不可变标量约束及依据。

```java
public final class com.netumscan.printersdk.ScalarConstraint
```

parameterId 指定约束，known=false 表示未知，不能解释为无限制。源载荷约束来自 SDK 接纳策略；协议几何或硬件支持仍须使用相应配置和能力证据。

文档 ID：`android:type:com.netumscan.printersdk.ScalarConstraint`

<a id="api-8477e1284dd57f499175"></a>

### public final boolean known

此约束是否有可靠已知范围。

```java
public final boolean known;
```

false 时 minimum、maximum、step 不能解释为无限制或硬件保证。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:a2fcb139f5d87956`

JVM descriptor：`Z`

<a id="api-d43001a41eba5b3320b7"></a>

### public final int evidence

范围的证据来源。

```java
public final int evidence;
```

区分 SDK 接纳策略、协议定义及其他证据，不能把 SDK 限制解释为已验证硬件能力。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:958eb37813714ec1`

JVM descriptor：`I`

<a id="api-0e47382cd2419c821178"></a>

### public final int maximum

已知约束的闭区间最大值。

```java
public final int maximum;
```

单位由 parameterId 决定；仅 known=true 时有意义。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:324164fa97d559e7`

JVM descriptor：`I`

<a id="api-5efa04f35bb99b9c6002"></a>

### public final int minimum

已知约束的闭区间最小值。

```java
public final int minimum;
```

单位由 parameterId 决定；仅 known=true 时有意义。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:4c11d30ea9a16e9f`

JVM descriptor：`I`

<a id="api-118090c567ac5cb1249a"></a>

### public final int parameterId

本快照的约束参数标识。

```java
public final int parameterId;
```

使用 COPIES、MEDIA_GAP_UM、JOB_IMAGE_BYTES 或 PENDING_PAYLOAD_BYTES 查询；未知标识返回已知位为 false 的约束。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:55be3d55c85c3eb8`

JVM descriptor：`I`

<a id="api-fefbccf3a2f0c364c608"></a>

### public final long step

已知约束的取值步长。

```java
public final long step;
```

在 minimum 起点按此步长取值；仅 known=true 时有意义。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:5aa9cefccae2739d`

JVM descriptor：`J`

<a id="api-7b40261535e852085c70"></a>

### public static final int COPIES = 1

份数约束标识，单位份。

```java
public static final int COPIES = 1;
```

固定公共查询参数标识；范围通过 PrinterCapabilities.constraint 读取，未知时不能推断无限制。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:1cb3e86c38667f1f`

JVM descriptor：`I`

<a id="api-e3f831803f36216af72a"></a>

### public static final int JOB_IMAGE_BYTES = 3

单作业图像源载荷约束标识，单位字节。

```java
public static final int JOB_IMAGE_BYTES = 3;
```

固定公共查询参数标识；范围通过 PrinterCapabilities.constraint 读取，未知时不能推断无限制。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:633c5aa13832b2cb`

JVM descriptor：`I`

<a id="api-f817ae755a9cdbe8ec44"></a>

### public static final int MEDIA_GAP_UM = 2

介质间隙约束标识，单位微米。

```java
public static final int MEDIA_GAP_UM = 2;
```

固定公共查询参数标识；范围通过 PrinterCapabilities.constraint 读取，未知时不能推断无限制。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:050af49c580b838f`

JVM descriptor：`I`

<a id="api-6c3c1651b1e3c2abcccf"></a>

### public static final int PENDING_PAYLOAD_BYTES = 4

设备未终态源载荷约束标识，单位字节。

```java
public static final int PENDING_PAYLOAD_BYTES = 4;
```

固定公共查询参数标识；范围通过 PrinterCapabilities.constraint 读取，未知时不能推断无限制。

文档 ID：`android:member:com.netumscan.printersdk.ScalarConstraint:da0e3bdd16ea3c2c`

JVM descriptor：`I`

<a id="api-e68d6e49886d528a891c"></a>

## SdkInfo

实际加载原生运行库的身份。

```java
public final class com.netumscan.printersdk.SdkInfo
```

由原生 C ABI 返回版本和构建身份，与 Demo BuildConfig 独立。生产 CMake 将原生版本、分发 VERSION 和源输入 SHA-256 编入库；缺失构建身份明确未知。该信息不证明签名、发布或硬件兼容。

文档 ID：`android:type:com.netumscan.printersdk.SdkInfo`

<a id="api-2fe33d151571157e902c"></a>

### public final int abiRevision

实际加载库的abiRevision。

```java
public final int abiRevision;
```

当前ABI3最低修订1，须与同版包装一起使用。

文档 ID：`android:member:com.netumscan.printersdk.SdkInfo:3c9a67871faec9fc`

JVM descriptor：`I`

<a id="api-fa7deb09d69a004e2a1f"></a>

### public final int abiVersion

实际加载库的abiVersion。

```java
public final int abiVersion;
```

当前ABI主版本3；ABI2不能混用，必须成套更新包装与库。

文档 ID：`android:member:com.netumscan.printersdk.SdkInfo:da69401829dacd32`

JVM descriptor：`I`

<a id="api-8a11e88892aadb1fa51d"></a>

### public final java.lang.String buildId

可选原生源构建 SHA-256 标识。

```java
public final java.lang.String buildId;
```

未知时为 null。生产 CMake 对受审定原生源和构建文件白名单计算，不包含 Git dirty、主机路径、环境或私有配置；不等同于完整二进制哈希。

文档 ID：`android:member:com.netumscan.printersdk.SdkInfo:1637e37d8d13a768`

JVM descriptor：`Ljava/lang/String;`

<a id="api-c3ffff62c449b0a3e8f2"></a>

### public final java.lang.String distributionVersion

构建库时嵌入的分发版本。

```java
public final java.lang.String distributionVersion;
```

生产 CMake 来源于 VERSION；未嵌入时为空字符串，不猜测或继承 Demo 版本。

文档 ID：`android:member:com.netumscan.printersdk.SdkInfo:17e16ecc61815642`

JVM descriptor：`Ljava/lang/String;`

<a id="api-17210b8724d6da37e2a2"></a>

### public final java.lang.String nativeVersion

实际加载库的nativeVersion。

```java
public final java.lang.String nativeVersion;
```

当前原生SDK语义版本0.3.0，生产CMake来源PROJECT_VERSION；不表示已发布。

文档 ID：`android:member:com.netumscan.printersdk.SdkInfo:9d70e248890bcc50`

JVM descriptor：`Ljava/lang/String;`

<a id="api-31d51fc34c8d04a03b44"></a>

## StatusQueryConfig

逐次硬件状态查询配置。

```java
public final class com.netumscan.printersdk.StatusQueryConfig
```

与打印几何、纸宽和 DPI 独立，接纳时复制，不改变连接默认值。CPCL/ESC_POS 当前未验证状态指令，因此查询同步返回 1004 UNSUPPORTED_OPERATION 且零打印机 IO；硬件仍未知。

文档 ID：`android:type:com.netumscan.printersdk.StatusQueryConfig`

<a id="api-972333d5cecdc3dfd0e8"></a>

### public com.netumscan.printersdk.StatusQueryConfig(int, int)

创建本次状态查询配置。

```java
public com.netumscan.printersdk.StatusQueryConfig(int, int);
```

protocol 只能是 CPCL 或 ESC_POS，queryTimeoutMs 必须为正整数毫秒，非法值同步抛 IllegalArgumentException。构造不执行 IO，不设置打印几何，也不证明固件支持状态查询。

文档 ID：`android:member:com.netumscan.printersdk.StatusQueryConfig:bfc5664f8357a682`

JVM descriptor：`(II)V`

<a id="api-7d926b09b7dd58da8403"></a>

### public final int protocol

本次状态查询选择的协议。

```java
public final int protocol;
```

只接受 CPCL=1 或 ESC_POS=2；选择协议不证明目标固件支持状态读回。

文档 ID：`android:member:com.netumscan.printersdk.StatusQueryConfig:b02cb9ffeefa8216`

JVM descriptor：`I`

<a id="api-61205a74675bd4d9f2d1"></a>

### public final int queryTimeoutMs

本次请求／响应事务的超时预算。

```java
public final int queryTimeoutMs;
```

必须大于 0，单位毫秒；与 queryStatus 的排队及操作总预算分别设置，不能据此绕过总预算。

文档 ID：`android:member:com.netumscan.printersdk.StatusQueryConfig:ee80c97565d158f3`

JVM descriptor：`I`

<a id="api-f34b5e25eec42fda666e"></a>

### public static final int CPCL = 1

CPCL 协议标识。

```java
public static final int CPCL = 1;
```

固定公共常量；仅标识协议，不保证目标固件已验证。

文档 ID：`android:member:com.netumscan.printersdk.StatusQueryConfig:bc25745e438ddbc7`

JVM descriptor：`I`

<a id="api-885a4db7b2a8d2745ec9"></a>

### public static final int ESC_POS = 2

ESC/POS 协议标识。

```java
public static final int ESC_POS = 2;
```

固定公共常量；仅标识协议，不保证目标固件已验证。

文档 ID：`android:member:com.netumscan.printersdk.StatusQueryConfig:282da3ae891951ec`

JVM descriptor：`I`

<a id="api-346a10d907279a636fde"></a>

## StatusResult

查询得到的硬件状态值。

```java
public final class com.netumscan.printersdk.StatusResult
```

knownConditions指明哪些状态位已知，activeConditions只在相应已知位内有意义；不得把未知位解释为正常，也不能从状态查询推断某次任务已打印完成。

文档 ID：`android:type:com.netumscan.printersdk.StatusResult`

<a id="api-6bd4c7e2dcd974871acc"></a>

### public final int activeConditions

已激活的硬件条件位。

```java
public final int activeConditions;
```

与knownConditions组合读取，不能单独将零值解释为所有硬件条件正常。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:7399537314a382a4`

JVM descriptor：`I`

<a id="api-935cf315825864fc4d7f"></a>

### public final int evidence

状态值的证据类型。

```java
public final int evidence;
```

遵循状态查询契约解释；不代表指定打印请求已设备确认完成。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:958eb37813714ec1`

JVM descriptor：`I`

<a id="api-1a0ec13fb92024dbae8a"></a>

### public final int knownConditions

硬件状态中已知的条件位。

```java
public final int knownConditions;
```

只有对应位为已知时，才可解释activeConditions中的该状态；未知不是正常。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:ca1edcaa356737e1`

JVM descriptor：`I`

<a id="api-7db2a2673b7578c3377e"></a>

### public static final int COVER_OPEN = 2

开盖条件位。

```java
public static final int COVER_OPEN = 2;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:63e53ba840019830`

JVM descriptor：`I`

<a id="api-b98a0e5b3700e2a0af4f"></a>

### public static final int CUTTER_ERROR = 8

切刀错误条件位。

```java
public static final int CUTTER_ERROR = 8;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:637b2910ef015ada`

JVM descriptor：`I`

<a id="api-b7448e50b83e77c0c944"></a>

### public static final int PAPER_NEAR_END = 4

纸张将尽条件位。

```java
public static final int PAPER_NEAR_END = 4;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:bf16c2c3cb59609d`

JVM descriptor：`I`

<a id="api-38d1b817317c7817d342"></a>

### public static final int PAPER_OUT = 1

缺纸条件位。

```java
public static final int PAPER_OUT = 1;
```

该常量的精确名称及编译值由公开基线固定；使用与本类型匹配的字段或参数，能力是否受支持以profile描述和请求校验为准。

文档 ID：`android:member:com.netumscan.printersdk.StatusResult:3f80da847c593bc9`

JVM descriptor：`I`
