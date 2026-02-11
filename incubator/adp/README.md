# 腾讯云智能体开发平台安装配置指南

本文档介绍腾讯云智能体开发平台（下文简称为ADP）在IaaS产品的部署方案，详细说明各配置项的用途、相关腾讯云产品推荐以及部署配置示例。

---

## 目录

### 第一部分：values配置指南
- [全局配置 (global)](#全局配置-global)
  - [基础配置](#基础配置)
  - [模型服务配置](#模型服务配置-modelservices)
  - [RSA 密钥配置](#rsa-密钥配置)
- [基础组件配置 (components)](#基础组件配置-components)
  - [数据库配置](#数据库配置)
  - [Redis 配置](#redis-配置)
  - [Elasticsearch 配置](#elasticsearch-配置)
  - [对象存储配置](#对象存储配置)
  - [Kafka 消息队列配置](#kafka-消息队列配置)
  - [向量数据库配置](#向量数据库配置)
- [可观测性配置 (observability)](#可观测性配置-observability)
  - [CLS 日志收集配置](#cls-日志收集配置)
  - [Prometheus 监控配置](#prometheus-监控配置)
  - [APM 链路追踪配置](#apm-链路追踪配置)
- [内容安全配置 (contentSecurity)](#内容安全配置-contentsecurity)
- [快速配置清单](#快速配置清单)

### 第二部分：服务器选型及部署建议
- [服务器推荐配置](#服务器推荐配置)
- [总费用预估](#总费用预估)
- [部署建议](#部署建议)

---

## 全局配置 (global)

### 基础配置

| 配置项           | 必填 | 说明          | 示例值                                                                                                                                                                                                                   |
|---------------|------|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `clusterSize` | ✅ 必填 | 集群规模，默认minimal     | 可选值：minimal/standard/recommended<br/>minimal 模式单副本部署，需2台16核32G服务器；<br/>standard模式双副本部署，需4台16核32G服务器；<br/>recommend模式三副本部署，需8台16核32G服务器。<br/>除副本数差异外，随集群规模扩大，各服务的CPU、内存request值也会相应调高。<br/>服务器配置参见：[服务器推荐配置](#服务器推荐配置) |
| `clb`         | ✅ 必填 | 负载均衡 CLB 域名 | 需要给clb绑定一个自定义域名，例如：`xx-adp.xyz.com`                                                                                                                                                                                   |
| `clbId`       | ✅ 必填 | CLB 实例 ID   | `lb-h7m35y2x`                                                                                                                                                                                                         |
| `scheme`      | ✅ 必填 | 协议类型        | `http` 或 `https`                                                                                                                                                                                                      |

**购买链接：** https://console.cloud.tencent.com/clb/instance

**规格配置：**

| 配置类型 | 带宽上限 | 适用场景 |
|----------|----------|----------|
| 最小配置 | 128 Mbps | 开发测试、PoC 验证 |
| 标准配置 | 512 Mbps | 生产环境、中小规模 |
| 推荐配置 | 1024 Mbps | 生产环境、大规模 |

**配置说明：**
- 实例类型：应用型负载均衡（推荐）
- 网络类型：公网或内网（根据实际需求选择）
- IP 版本：IPv4 或 IPv6
- 计费模式：按带宽计费或按使用流量计费
- 部署区域：建议与 TKE 集群相同地域
- 支持跨可用区部署，提高可用性

> **注意**：CLB 价格与实例费用、带宽费用相关，具体价格请参考腾讯云官网计费说明。

---

### 模型服务配置 (modelServices)

所有模型服务配置统一放在 `global.modelServices` 下。
若未配置apiKey则chat功能将无法正常运行。

| 配置项 | 必填 | 说明 |
|--------|------|------|
| `modelServices.adp.apiKey` | ✅ 必填 | 腾讯云知识引擎 ADP API Key |
| `modelServices.hunyuan.apiKey` | ✅ 必填 | 腾讯混元大模型 API Key |

**支持的模型服务类型：**
- `adp`: 腾讯云知识引擎 - https://console.cloud.tencent.com/lkeap 选择使用OpenAI SDK方式创建
- `hunyuan`: 腾讯混元大模型 - https://console.cloud.tencent.com/hunyuan/start 选择使用OpenAI SDK方式创建

**配置示例：**

```yaml
global:
  modelServices:
    # 腾讯云知识引擎 ADP（必填）
    adp:
      apiKey: sk-xxxxxxxx
    # 腾讯混元大模型（必填）
    hunyuan:
      apiKey: sk-xxxxxxxx
```

---

### RSA 密钥配置

用于前后端敏感数据加解密传输。

| 配置项 | 必填 | 说明 |
|--------|------|------|
| `rsa.privateKey` | ✅ 必填 | RSA 私钥（Base64 编码）|
| `rsa.publicKey` | ✅ 必填 | RSA 公钥（Base64 编码）|

**生成方式：**

```bash
# 1. 生成私钥
openssl genrsa -out private.pem 2048

# 2. 生成公钥
openssl rsa -in private.pem -pubout -out public.pem

# 3. Base64 编码
cat private.pem | base64 -w 0 > privateKey.txt
cat public.pem | base64 -w 0 > publicKey.txt
```

---

## 基础组件配置 (components)

所有组件配置统一放在 `global.components` 下，每个组件包含：
- `vendor`: 云厂商标识 (tencent/aws/alibaba/azure/gcp/huawei/self)
- `providerType`: 具体产品类型，结合 vendor 唯一标识组件实现

> **重要提示**：所有组件（数据库、Redis、ES、COS、VDB 等）应与 TKE 集群部署在**同一地域**，以获得最佳网络性能和最低延迟。

### 数据库配置

| 配置项 | 必填 | 说明 | 示例值            |
|--------|------|------|----------------|
| `components.db.vendor` | ✅ 必填 | 云厂商 | `tencent`   |
| `components.db.providerType` | ✅ 必填 | 产品类型 | `tdsql`    |
| `components.db.host` | ✅ 必填 | 数据库主机地址 | `192.168.8.81` |
| `components.db.port` | ✅ 必填 | 数据库端口 | `3306`         |
| `components.db.user` | ✅ 必填 | 数据库用户名 | `adp-test`     |
| `components.db.password` | ✅ 必填 | 数据库密码 | `your-password` |

**providerType 可选值：**
- tencent: `tdsql`

**购买链接：** https://cloud.tencent.com/product/tdsql

**要求：**
- TDSQL-MySQL 5.7+ 或兼容版本
- 字符集必须设置为 `UTF8MB4`
- 表名大小写敏感必须设置为**不敏感**（`lower_case_table_names = 1`）
- 需要提前创建数据库和用户，并授予相应权限

**规格配置：**

| 配置类型 | CPU | 内存 | 存储 | 适用场景 | 月费用（元/月） |
|----------|-----|------|------|----------|----------------|
| 最小配置 | 2核 | 4GB | 50GB | 开发测试、PoC 验证 | 330 |
| 标准配置 | 4核 | 8GB | 200GB | 生产环境、中小规模 | 700 |
| 推荐配置 | 8核 | 32GB | 1000GB | 生产环境、大规模 | 3000 |

**配置说明：**
- 数据库版本：MySQL 8.0 (TDSQL Boundless，推荐)
- 物理备份方式：物理复制（强同步）
- 分片数：2 个分片
- 逻辑分区数：64 个
- 字符集：UTF8MB4
- 表名大小写敏感：不敏感（可迁移）
- InnoDB 页面大小：16KB
- 备份空间：免费赠送实例存储容量的 100%
- 部署区域：建议与 TKE 集群相同地域（如：北京五区）

> **价格说明**：以上价格基于 1 个月购买周期预估，实际价格可能因地域、优惠活动等因素有所差异。长期使用建议购买更长周期以获取折扣。

---

### Redis 配置

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `components.redis.vendor` | ✅ 必填 | 云厂商 | `tencent` |
| `components.redis.providerType` | ✅ 必填 | 产品类型 | `redis` |
| `components.redis.cluster` | ✅ 必填 | 集群模式 | `master` |
| `components.redis.hosts` | ✅ 必填 | Redis 主机地址列表 | `["192.168.6.10"]` |
| `components.redis.port` | ✅ 必填 | Redis 端口 | `6379` |
| `components.redis.password` | ✅ 必填 | Redis 密码 | `your-password` |

**providerType 可选值：**
- tencent: `redis`

**购买链接：** https://cloud.tencent.com/product/crs

**要求：**
- Redis 5.0+ 版本
- 支持单机版或集群版

**规格配置：**

| 配置类型 | 内存 | 连接数 | 适用场景 | 月费用（元/月） |
|----------|------|--------|----------|----------------|
| 最小配置 | 2GB | 10000 | 开发测试、PoC 验证 | 35 |
| 标准配置 | 4GB | 10000 | 生产环境、中小规模 | 70 |
| 推荐配置 | 8GB | 10000 | 生产环境、大规模 | 140 |

**配置说明：**
- 产品版本：Redis 版（推荐）
- 兼容版本：Redis 7.0
- 架构版本：标准架构（1 主 1 副本）
- 性能规格：标准性能版
- 部署区域：建议与 TKE 集群相同地域（如：北京五区）
- 可用区部署：支持多可用区部署

> **价格说明**：以上价格基于 1 个月购买周期预估，实际价格可能因地域、优惠活动等因素有所差异。长期使用建议购买更长周期以获取折扣。

---

### Elasticsearch 配置

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `components.es.vendor` | ✅ 必填 | 云厂商 | `tencent` |
| `components.es.providerType` | ✅ 必填 | 产品类型 | `es` |
| `components.es.hosts` | ✅ 必填 | ES 主机地址列表 | `["192.168.6.16"]` |
| `components.es.port` | ✅ 必填 | ES 端口 | `9200` |
| `components.es.user` | ✅ 必填 | ES 用户名 | `elastic` |
| `components.es.password` | ✅ 必填 | ES 密码 | `your-password` |

**providerType 可选值：**
- tencent: `es`

**购买链接：** https://cloud.tencent.com/product/es

**要求：**
- Elasticsearch 7.x 或 8.x 版本
- 建议至少 3 节点集群

**规格配置：**

| 配置类型 | 节点数 | CPU/节点 | 内存/节点 | 存储/节点 | 适用场景 | 月费用（元/月） |
|----------|--------|----------|-----------|-----------|----------|----------------|
| 最小配置 | 3 | 2核 | 4GB | 100GB | 开发测试、PoC 验证 | 650 |
| 标准配置 | 3 | 4核 | 8GB | 200GB | 生产环境、中小规模 | 1,950 |
| 推荐配置 | 3 | 8核 | 16GB | 200GB | 生产环境、大规模 | 3,300 |

**配置说明：**
- 产品版本：Elasticsearch 标准版（推荐）
- 兼容版本：8.16.1（支持多个版本可选）
- 节点类型：标准型
- 存储类型：增强型 SSD 云硬盘
- 部署方式：单可用区部署（3 节点）
- 部署区域：建议与 TKE 集群相同地域（如：北京八区）
- 支持磁盘自动扩容

> **价格说明**：以上价格基于 1 个月购买周期预估，实际价格可能因地域、优惠活动等因素有所差异。长期使用建议购买更长周期以获取折扣。

---

### 对象存储配置

统一使用 `s3` 配置项，通过 `providerType` 区分不同存储类型。

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|-------|
| `components.s3.vendor` | ✅ 必填 | 云厂商 | `tencent` |
| `components.s3.providerType` | ✅ 必填 | 产品类型 | `cos` |

**providerType 可选值：**
- tencent: `cos`

#### COS 专用配置 (providerType=cos 时生效)

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `components.s3.cos.secretId` | ✅ 必填 | 腾讯云 SecretId | `AKIDxxxx` |
| `components.s3.cos.secretKey` | ✅ 必填 | 腾讯云 SecretKey | `xxxxx` |
| `components.s3.cos.appId` | ✅ 必填 | 腾讯云 AppId | `1392479074` |
| `components.s3.cos.bucket` | ✅ 必填 | 存储桶名称 | `adp-test-1234567890` |
| `components.s3.cos.region` | ✅ 必填 | 地域 | `ap-guangzhou` |
| `components.s3.cos.domain` | ✅ 必填 | COS 域名后缀 | `myqcloud.com` |
| `components.s3.cos.subPath` | ⚪ 选填 | 子路径 | `adp-test` |
| `components.s3.cos.expireTime` | ⚪ 选填 | 签名过期时间 | `3600s` |
| `components.s3.cos.credentialTime` | ⚪ 选填 | 临时凭证有效期 | `3600s` |

另外，components.s3.cos.secretId及components.s3.cos.secretKey对应的uin账号，除需要授予cos权限外，还需要授予AI原子能力权限。
<img src="https://adp-iaas-resource-1392479074.cos.ap-beijing.myqcloud.com/images/%E7%BB%99%E8%B4%A6%E5%8F%B7%E5%88%86%E9%85%8D%E5%8E%9F%E5%AD%90%E8%83%BD%E5%8A%9B%E6%9D%83%E9%99%90.png" width="800">  
同时需要在 https://console.cloud.tencent.com/lkeap/settings 中设置文档解析能力为后付费  
<img src="https://adp-iaas-resource-1392479074.cos.ap-beijing.myqcloud.com/images/%E6%96%87%E6%A1%A3%E8%A7%A3%E6%9E%90%E5%92%8C%E6%96%87%E6%A1%A3%E6%8B%86%E5%88%86.png" width="400">

**购买链接：** https://cloud.tencent.com/product/cos 在页面中创建桶，并且创建一个目录给adp使用。

**规格配置：**

| 配置类型 | 存储容量 | 适用场景 |
|----------|----------|----------|
| 最小配置 | 50GB | 开发测试、PoC 验证 |
| 标准配置 | 500GB | 生产环境、中小规模 |
| 推荐配置 | 2TB+ | 生产环境、大规模 |

**配置示例：**

```yaml
components:
  s3:
    vendor: tencent
    providerType: cos
    cos:
      secretId: AKIDxxxx
      secretKey: xxxxx
      appId: 1234567890
      bucket: adp-test-1234567890
      region: ap-guangzhou
      domain: myqcloud.com
      subPath: "adp-test"
      expireTime: 3600s
      credentialTime: 3600s
```

---

### Kafka 消息队列配置

kafka是可选中间件，如果需要运维管理中的操作日志查询功能，请购买kafka。

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `components.kafka.vendor` | ✅ 必填 | 云厂商 | `tencent` |
| `components.kafka.providerType` | ✅ 必填 | 产品类型 | `kafka` |
| `components.kafka.hosts` | ✅ 必填 | Kafka 主机地址列表 | `["10.0.0.5"]` |
| `components.kafka.port` | ✅ 必填 | Kafka 端口 | `9092` |

**providerType 可选值：**
- tencent: `kafka`

**购买链接：** https://console.cloud.tencent.com/ckafka/instance

**要求：**
- Kafka 2.x 或 3.x 版本
- 支持标准版或专业版

**规格配置：**

| 配置类型 | 实例类型 | 峰值带宽 | 磁盘容量 | Topic数 | 适用场景 | 月费用（元/月） |
|----------|----------|----------|----------|--------|----------|----------------|
| 最小配置 | 标准版 | 40 Mbps | 300GB | 50 | 开发测试、PoC 验证 | 600 |
| 标准配置 | 标准版 | 100 Mbps | 500GB | 150 | 生产环境、中小规模 | 1,200 |
| 推荐配置 | 专业版 | 200 Mbps | 1000GB | 500 | 生产环境、大规模 | 2,400 |

**配置说明：**
- 产品版本：CKafka 标准版（推荐）或专业版
- 兼容版本：Kafka 2.4 / 2.8 / 3.x
- 实例类型：标准版（按量付费）或专业版（包年包月）
- 消息保留时间：1~30 天可配置
- 分区数：自动分配，标准版最多 500 个分区/实例
- 副本数：标准版支持 2~3 副本
- 部署区域：建议与 TKE 集群相同地域
- 支持公网访问和内网访问

**使用说明：**
- 主要用于 platform-manager 服务的审计日志生产和消费
- Topic: `adp_audit_log`
- Consumer Group: `platform-manager`
- 需要提前创建 Topic 和配置相应的 ACL 权限

> **价格说明**：以上价格基于 1 个月购买周期预估，实际价格可能因地域、优惠活动等因素有所差异。长期使用建议购买更长周期以获取折扣。

**配置示例：**

```yaml
components:
  kafka:
    vendor: tencent
    providerType: kafka
    hosts:
      - 10.0.0.5
    port: 9092
```

---

### 向量数据库配置

支持数组格式配置多个实例。

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `components.vdb` | ✅ 必填 | 向量数据库配置（数组） | - |
| `components.vdb[].vendor` | ✅ 必填 | 云厂商 | `tencent` |
| `components.vdb[].providerType` | ✅ 必填 | 产品类型 | `vdb` |
| `components.vdb[].addr` | ✅ 必填 | VDB 地址 | `http://192.168.8.235` |
| `components.vdb[].account` | ✅ 必填 | VDB 账号 | `root` |
| `components.vdb[].apiKey` | ✅ 必填 | VDB API Key | `xxxxx` |

**providerType 可选值：**
- tencent: `vdb`

**购买链接：** https://cloud.tencent.com/product/vdb

**规格配置：**

| 配置类型 | 节点数 | CPU/节点 | 内存/节点 | 存储 | 适用场景 | 月费用（元/月） |
|----------|--------|----------|-----------|------|----------|----------------|
| 最小配置 | 3 | 2核 | 8GB | 30GB | 开发测试、PoC 验证 | 450 |
| 标准配置 | 3 | 4核 | 16GB | 60GB | 生产环境、中小规模 | 900 |
| 推荐配置 | 3 | 8核 | 32GB | 100GB | 生产环境、大规模 | 1,800 |

**配置说明：**
- 产品版本：标准版（推荐）
- 实例类型：高可用版（两可用区部署）
- 节点规格：标准型
- 存储类型：云硬盘
- 部署模式：3 节点集群（支持 2~50 个节点）
- 部署区域：建议与 TKE 集群相同地域
- 建议存储容量配置为内存容量的 3 倍左右

> **价格说明**：以上价格基于 1 个月购买周期预估，实际价格可能因地域、优惠活动等因素有所差异。长期使用建议购买更长周期以获取折扣。

**配置示例：**

```yaml
components:
  vdb:
    - vendor: tencent
      providerType: vdb
      addr: http://192.168.8.235
      account: root
      apiKey: your-api-key
```

---

## 可观测性配置 (observability)

所有可观测性相关配置统一放在 `global.observability` 下。

### CLS 日志收集配置

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `observability.cls.enabled` | ⚪ 选填 | 是否启用 CLS 日志收集 | `true` / `false` |
| `observability.cls.logsetId` | 条件必填 | CLS 日志集 ID（启用时必填） | `18e6acd6-xxxx` |
| `observability.cls.topicId` | 条件必填 | CLS 日志主题 ID（启用时必填） | `95fba336-xxxx` |

> 其他选填参数（logType、timeKey、timeFormat 等）已在模板中设置默认值，无需配置。

**购买链接：** https://console.cloud.tencent.com/cls/topic

---

### Prometheus 监控配置

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `observability.prometheus.enabled` | ⚪ 选填 | 是否启用 Prometheus 监控 | `true` / `false` |

> 其他选填参数（port、interval、path、scheme、matchLabels 等）已在模板中设置默认值，无需配置。

**购买链接：** https://console.cloud.tencent.com/tke2/prometheus2

---

### APM 链路追踪配置

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `observability.apm.vendor` | ⚪ 选填 | 云厂商 | `tencent` |
| `observability.apm.providerType` | ⚪ 选填 | 产品类型 | `tps` / `xray` / `jaeger` |
| `observability.apm.otlp` | ⚪ 选填 | OTLP 端点 | `pl.ap-beijing.apm.tencentcs.com:4319` |
| `observability.apm.registry` | ⚪ 选填 | 注册中心 | `""` |
| `observability.apm.attributes.token` | ⚪ 选填 | APM Token | `xxxxx` |

**providerType 可选值：**
- tencent: `tps`
- aws: `xray`
- self: `jaeger`

**购买链接：** https://console.cloud.tencent.com/monitor/apm/system/list

---

## 内容安全配置 (contentSecurity)

用于文本内容安全审核，可选配置。

| 配置项 | 必填 | 说明 | 示例值 |
|--------|------|------|--------|
| `contentSecurity.region` | ⚪ 选填 | 地域 | `ap-guangzhou` |
| `contentSecurity.appId` | ⚪ 选填 | 应用 ID | `1234567890` |
| `contentSecurity.uin` | ⚪ 选填 | 主账号 UIN | `123456789` |
| `contentSecurity.subUin` | ⚪ 选填 | 子账号 UIN | `123456789` |
| `contentSecurity.secretId` | ⚪ 选填 | 腾讯云 SecretId | `AKIDxxxx` |
| `contentSecurity.secretKey` | ⚪ 选填 | 腾讯云 SecretKey | `xxxxx` |

**购买链接：** https://cloud.tencent.com/document/product/1124/51860

**配置示例：**

```yaml
global:
  contentSecurity:
    region: ap-guangzhou
    appId: "1234567890"
    uin: "123456789"
    subUin: "123456789"
    secretId: AKIDxxxx
    secretKey: xxxxx
```

---

## 快速配置清单

### 必填项清单

部署前请确保以下配置项已正确填写：

- [ ] `global.clb` - CLB 域名
- [ ] `global.clbId` - CLB 实例 ID
- [ ] `global.scheme` - 协议类型
- [ ] `global.modelServices.adp.apiKey` - ADP API Key
- [ ] `global.modelServices.hunyuan.apiKey` - 混元 API Key
- [ ] `global.rsa.privateKey` - RSA 私钥
- [ ] `global.rsa.publicKey` - RSA 公钥
- [ ] `global.components.db.*` - 数据库配置
- [ ] `global.components.redis.*` - Redis 配置
- [ ] `global.components.es.*` - Elasticsearch 配置
- [ ] `global.components.s3.*` - 对象存储配置
- [ ] `global.components.kafka.*` - Kafka 消息队列配置
- [ ] `global.components.vdb` - 向量数据库配置

### 云产品购买清单

| 产品 | 用途 | 购买链接 |
|------|------|----------|
| CLB 负载均衡 | 流量入口 | https://console.cloud.tencent.com/clb/instance |
| TDSQL 数据库 | 业务数据存储 | https://cloud.tencent.com/product/tdsql |
| Elasticsearch | 日志检索 | https://cloud.tencent.com/product/es |
| Redis | 缓存服务 | https://cloud.tencent.com/product/crs |
| COS 对象存储 | 文件存储 | https://cloud.tencent.com/product/cos |
| CKafka 消息队列 | 审计日志消息队列 | https://console.cloud.tencent.com/ckafka/instance |
| VDB 向量数据库 | 向量检索 | https://cloud.tencent.com/product/vdb |
| CLS 日志服务 | 日志收集（可选） | https://console.cloud.tencent.com/cls/topic |
| Prometheus | 监控（可选） | https://console.cloud.tencent.com/tke2/prometheus2 |
| APM 应用性能监控 | 链路追踪（可选） | https://console.cloud.tencent.com/monitor/apm/system/list |
| 混元大模型 | AI 能力 | https://console.cloud.tencent.com/hunyuan/start |
| ADP 平台 | 知识引擎 | https://console.cloud.tencent.com/lkeap |

## 服务器推荐配置

为满足高可用需求，部署腾讯云 ADP 需要准备 Kubernetes 集群，以下提供了三种场景的服务器推荐配置供参考：

### 最小配置

**适用场景：** 开发测试、PoC 验证

**服务器规格：**
- **数量：** 2 台
- **配置：** 16核 CPU + 32GB 内存
- **用途：** 创建 K8s 集群或在已有集群中预留此规模资源

**预估费用：** ¥2,000 元/月（2 台 × 1,000 元/月，此处为预估价格，实际价格以腾讯云账单为准）

**配置说明：**
- 建议使用腾讯云标准型实例（如 S5 系列）
- 系统盘：100GB 高性能云硬盘
- 数据盘：根据实际需求配置（建议 500GB+）
- 网络：VPC 私有网络，建议配置 5Mbps+ 公网带宽
- 操作系统：Ubuntu 20.04 LTS 或 CentOS 7.9

### 标准配置

**适用场景：** 小规模生产环境、中小型业务

**服务器规格：**
- **数量：** 4 台
- **配置：** 16核 CPU + 32GB 内存
- **用途：** 创建 K8s 集群或在已有集群中预留此规模资源

**预估费用：** ¥4,000 元/月（4 台 × 1,000 元/月，此处为预估价格，实际价格以腾讯云账单为准）

**配置说明：**
- 建议使用腾讯云标准型实例（如 S5 系列）
- 系统盘：100GB 高性能云硬盘
- 数据盘：根据实际需求配置（建议 500GB+）
- 网络：VPC 私有网络，建议配置 5Mbps+ 公网带宽
- 操作系统：Ubuntu 20.04 LTS 或 CentOS 7.9

### 推荐配置

**适用场景：** 生产环境、中大规模部署

**服务器规格：**
- **数量：** 8 台
- **配置：** 16核 CPU + 32GB 内存
- **用途：** 创建 K8s 集群或在已有集群中预留此规模资源

**预估费用：** ¥8,000 元/月（8 台 × 1,000 元/月，此处为预估价格，实际价格以腾讯云账单为准）

**配置说明：**
- 建议使用腾讯云标准型实例（如 S5 系列）
- 系统盘：100GB 高性能云硬盘
- 数据盘：根据实际需求配置（建议 1TB+）
- 网络：VPC 私有网络，建议配置 10Mbps+ 公网带宽
- 操作系统：Ubuntu 20.04 LTS 或 CentOS 7.9

> **价格说明：** 以上价格为预估价格，实际费用以实际发生价格为准。价格可能因地域、购买时长、优惠活动等因素有所差异。

**购买链接：** https://console.cloud.tencent.com/cvm/instance

## 总费用预估

### 最小配置总费用

| 组件 | 月费用（元） |
|------|-------------|
| 服务器（2台 16c32G） | 2,000 |
| CLB 负载均衡 | 按实际使用 |
| TDSQL 数据库（最小配置） | 330 |
| Redis（最小配置） | 35 |
| Elasticsearch（最小配置） | 650 |
| COS 对象存储 | 按实际使用 |
| Kafka 消息队列（最小配置） | 600 |
| VDB 向量数据库（最小配置） | 450 |
| **合计（不含按量计费）** | **约 4,065 元/月** |

### 标准配置总费用

| 组件 | 月费用（元） |
|------|-------------|
| 服务器（4台 16c32G） | 4,000 |
| CLB 负载均衡 | 按实际使用 |
| TDSQL 数据库（标准配置） | 700 |
| Redis（标准配置） | 70 |
| Elasticsearch（标准配置） | 1,950 |
| COS 对象存储 | 按实际使用 |
| Kafka 消息队列（标准配置） | 1,200 |
| VDB 向量数据库（标准配置） | 900 |
| **合计（不含按量计费）** | **约 8,820 元/月** |

### 推荐配置总费用

| 组件 | 月费用（元） |
|------|-------------|
| 服务器（8台 16c32G） | 8,000 |
| CLB 负载均衡 | 按实际使用 |
| TDSQL 数据库（推荐配置） | 3,000 |
| Redis（推荐配置） | 140 |
| Elasticsearch（推荐配置） | 3,300 |
| COS 对象存储 | 按实际使用 |
| Kafka 消息队列（推荐配置） | 2,400 |
| VDB 向量数据库（推荐配置） | 1,800 |
| **合计（不含按量计费）** | **约 18,640 元/月** |

> **重要说明：**
> 1. 以上所有价格均为预估价格，实际费用以腾讯云账单价格为准
> 2. CLB 和 COS 按实际使用量计费，费用因使用情况而异
> 3. 长期使用建议购买包年套餐，可享受更多折扣
> 4. 价格可能因地域、购买时长、优惠活动等因素有所差异

---

## 部署建议

1. **地域选择：** 所有组件建议部署在同一地域，减少跨地域访问延迟和费用
2. **高可用：** 生产环境建议配置多可用区部署，提高系统可用性
3. **监控告警：** 建议配置完善的监控和告警机制
4. **备份策略：** 定期备份数据库和重要数据
5. **安全加固：** 配置安全组、访问控制、数据加密等安全措施
6. **弹性伸缩：** 根据业务增长适时调整资源配置
