## What's NewMonkey
NewMonkey是一款无root、无USB的Android应用程序稳定性测试工具，将复杂的稳定性测试流程集成在一个便捷可靠的智能monkey客户端中，通过几分钟的简单接入配置即可开始进行测试，真正实现测试自动化。

NewMonkey集**UI自动化执行引擎**与**缺陷识别器**为一体，打通研发流程，对接持续集成和缺陷管理系统，实现下载安装、自动运行应用、发现crash、自动提单整个闭环。

NewMonkey基于`Java`和`Golang`开发，架构包括客户端、web后台、算法后台、NewMonkey SDK。

## 亮点功能

#### 打通研发流程，形成测试闭环

全自动运作，打通公司内外的研发流程，从集成、下载、安装、测试到提单一体化。针对公司外部产品，提供apk上传与crash报告的CGI，以便打通外部研发流程。

#### 自定义脚本功能，实现特定化场景测试

面对不同的应用，其稳定性测试的需求是千差万别的。为了契合业务需求，NewMonkey提供了脚本功能，支持用户编写脚本进行定制化测试，使NewMonkey得以在特定的场景中进行测试，进一步提高测试效率。

#### 基于控件点击+动态加权算法，大大提升测试效率

由于原生monkey是基于坐标点击，随机性高，导致测试的点击效率与遍历效率过于低下。为了解决这个问题，NewMonkey改变了点击的方式与遍历算法，即基于坐标点击与动态加权算法，在保证随机性的基础上，尽量使其他控件有均等的点击机会且尽量操作有意义的控件，从根本上提高测试的效率。

#### “挑战者模式”解决线程安全问题

线程安全问题导致应用程序crash率高，但是其问题发现定位难、复现难，NewMonkey采用hook技术从根本上发现并解决，让偶现问题无所遁形。

## 使用

### 客户端
APK下载地址 ： [NewMonkey2.10](https://monkeyapk-1253358381.cos.ap-guangzhou.myqcloud.com/NewMonkey_2.10.1.apk)

### 后台搭建
和普通的 Helm 包使用方法无异，所有的配置项集中于 `values.yaml`
搭建完后台后，可到web界面(地址为服务器ip:30080)查看使用文档
下面是 `values.yaml` 字段:


| 参数                       | 描述                       |
| ------------------------- | ------------------------- |
| `allowedIp`               | 限定请求的host ip地址，用','分隔（可填写服务器的IP地址） |
| `databaseName`            | 数据库名称， 需要使用[postgresql数据库](https://cloud.tencent.com/product/postgres)|
| `databaseHost`            | 数据库地址 |
| `databaseUser`            | 数据库用户名 |
| `databasePassword`        | 数据库密码    |
| `databasePort`            | 数据库端口    |
| `bugPucket`               | 腾讯云[对象存储桶](https://cloud.tencent.com/product/cos)名称，用于存放发现的crash zip包|
| `apkPucket`               | 腾讯云对象存储桶名称，用于存放apk        |
| `secretId`                | 访问存储桶所需要的secretId， 可在[对象存储-密钥管理](https://console.cloud.tencent.com/cos5/key)中查看 |
| `secretKey`               | 访问存储桶所需要的secretKey， 可在[对象存储-密钥管理](https://console.cloud.tencent.com/cos5/key)中查看 |
| `tapdKey`                 | tapd api账号，发现的Crash会提单至tapd，可在[tapd官网](https://www.tapd.cn/help/view#1120003271001002318)了解  |
| `tapdSecret`              | tapd api secret|
| `sdkVersion`              | sdk版本，stable或latest, 默认latest。 latest支持安卓10，stable不支持|

## 其他
如有其他问题，欢迎[反馈](https://support.qq.com/products/297005?)