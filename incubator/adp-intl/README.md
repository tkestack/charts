# Tencent Cloud Agent Development Platform - Installation & Configuration Guide

This document describes the deployment of Tencent Cloud Agent Development Platform (hereinafter referred to as **ADP**) on IaaS products. It explains the purpose of each configuration item, recommends the corresponding Tencent Cloud products, and provides deployment configuration examples.

---

## Table of Contents

### Part 1: values.yaml Configuration Guide
- [Global Configuration (global)](#global-configuration-global)
  - [Basic Configuration](#basic-configuration)
  - [RSA Key Configuration](#rsa-key-configuration)
- [Component Configuration (components)](#component-configuration-components)
  - [Database Configuration](#database-configuration)
  - [Redis Configuration](#redis-configuration)
  - [Elasticsearch Configuration](#elasticsearch-configuration)
  - [Object Storage Configuration](#object-storage-configuration)
  - [Kafka Message Queue Configuration](#kafka-message-queue-configuration)
  - [ClickHouse Configuration](#clickhouse-configuration)
- [Observability Configuration (observability)](#observability-configuration-observability)
  - [CLS Log Collection](#cls-log-collection)
  - [Prometheus Monitoring](#prometheus-monitoring)
  - [APM Tracing](#apm-tracing)
- [Content Security Configuration (contentSecurity)](#content-security-configuration-contentsecurity)
- [Quick Configuration Checklist](#quick-configuration-checklist)

### Part 2: Server Sizing & Deployment Recommendations
- [Recommended Server Configuration](#recommended-server-configuration)
- [Total Cost Estimation](#total-cost-estimation)
- [Deployment Recommendations](#deployment-recommendations)

---

## Global Configuration (global)

### Basic Configuration

| Key             | Required | Description | Example |
|-----------------|----------|-------------|---------|
| `clusterSize`   | ✅ Required | Cluster size, default `minimal` | Allowed values: `minimal` / `standard` / `recommended`.<br/>**minimal**: single-replica deployment, requires 3 servers (16C32G).<br/>**standard**: dual-replica deployment, requires 6 servers (16C32G).<br/>**recommended**: triple-replica deployment, requires 10 servers (16C32G).<br/>In addition to the replica count, CPU/memory `requests` of each service scale up with cluster size. See [Recommended Server Configuration](#recommended-server-configuration). |
| `clb`           | ✅ Required | CLB (Cloud Load Balancer) domain | Bind a custom domain to the CLB, e.g. `xx-adp.xyz.com` |
| `clbId`         | ✅ Required | CLB instance ID | `lb-h7m35y2x` |
| `scheme`        | ✅ Required | Protocol type | `http` or `https` |
| `clbCertId`     | Conditionally required | CLB HTTPS certificate ID (required when `scheme` is `https`) | `abcdef123456` |
| `checkK8sResources` | ✅ Required | Whether to disable Kubernetes resource checks. Set to `false` when using super nodes. | `true` or `false` |

**Purchase link:** https://buy.intl.cloud.tencent.com/clb

**Specification options:**

| Tier | Bandwidth Cap | Use Case |
|------|---------------|----------|
| Minimal  | 128 Mbps  | Dev / test / PoC |
| Standard | 512 Mbps  | Production, small to medium scale |
| Recommended | 1024 Mbps | Production, large scale |

**Configuration notes:**
- Instance type: Application Load Balancer (recommended)
- Network type: public or private (based on actual needs)
- IP version: IPv4 or IPv6
- Billing mode: by bandwidth or by traffic
- Region: same region as the TKE cluster
- Multi-AZ deployment is supported for higher availability

> **Note:** CLB pricing depends on the instance fee plus bandwidth fee. Refer to the official Tencent Cloud pricing documentation for exact prices.

---

### RSA Key Configuration

Used for encrypting/decrypting sensitive data transmitted between frontend and backend.

| Key | Required | Description |
|-----|----------|-------------|
| `rsa.privateKey` | ✅ Required | RSA private key (Base64-encoded) |
| `rsa.publicKey`  | ✅ Required | RSA public key (Base64-encoded) |

**Generation steps (macOS):**

```bash
# 1. Generate the private key
openssl genrsa -out private.pem 2048

# 2. Generate the public key
openssl rsa -in private.pem -pubout -out public.pem

# 3. Base64-encode (no line break)
cat private.pem | base64 -w 0 > privateKey.txt
cat public.pem  | base64 -w 0 > publicKey.txt
```

**Generation steps (Linux):**

```bash
# 1. Generate the private key
openssl genrsa -out private.pem 2048

# 2. Derive the public key from the private key
openssl rsa -in private.pem -pubout -out public.pem

# 3. Base64-encode the private key (no line break)
base64 -w 0 private.pem > privateKey.txt

# 4. Base64-encode the public key (no line break)
base64 -w 0 public.pem  > publicKey.txt
```

---

## Component Configuration (components)

All component configurations live under `global.components`. Each component contains:
- `vendor`: Cloud vendor identifier (`tencent` / `aws` / `alibaba` / `azure` / `gcp` / `huawei` / `self`)
- `providerType`: Specific product type. Combined with `vendor`, it uniquely identifies the implementation.

> **Important:** All components (Database, Redis, ES, COS, VDB, etc.) should be deployed in the **same region** as the TKE cluster for the best network performance and lowest latency.

### Database Configuration

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.db.vendor`       | ✅ Required | Cloud vendor   | `tencent` |
| `components.db.providerType` | ✅ Required | Product type   | `tdsql` or `mysql` |
| `components.db.host`         | ✅ Required | Database host  | `192.168.8.81` |
| `components.db.port`         | ✅ Required | Database port  | `3306` |
| `components.db.user`         | ✅ Required | Database user  | `adp-test` |
| `components.db.password`     | ✅ Required | Database password | `your-password` |

**Allowed `providerType` values:**
- tencent: `tdsql` or `mysql`

**Purchase links:**

- TDSQL → https://buy.intl.cloud.tencent.com/tdstore
- MySQL → https://buy.intl.cloud.tencent.com/cdb

**Requirements:**
- TDSQL-MySQL 8.0 or MySQL 8.4
- Character set must be `UTF8MB4`
- Table-name case sensitivity must be **case-insensitive** (`lower_case_table_names = 1`)
- Create the user in advance and grant the required privileges
- **Disable the requirement that every table must have a primary key**

**Specification options:**

| Tier | CPU | Memory | Storage | Use Case | Monthly Cost (CNY) |
|------|-----|--------|---------|----------|---------------------|
| Minimal     | 2 cores | 4 GB  | 50 GB   | Dev / test / PoC | 330 |
| Standard    | 4 cores | 8 GB  | 200 GB  | Production, small to medium scale | 700 |
| Recommended | 8 cores | 32 GB | 1000 GB | Production, large scale | 3,000 |

**Configuration notes:**

- Database version: TDSQL-MySQL 8.0 or MySQL 8.4
- Replication mode: physical replication (strong synchronous)
- Character set: `UTF8MB4`
- Table-name case sensitivity: case-insensitive (migratable)
- InnoDB page size: 16 KB
- Backup space: 100% of the instance storage capacity is included free
- Region: same region as the TKE cluster

TDSQL:
- Shards: 2
- Logical partitions: 64

MySQL:
- Nodes: at least dual-node (primary + standby)

> **Pricing note:** Prices above are estimates for a 1-month subscription period. Actual prices may vary by region, promotions, etc. For long-term usage, longer subscription terms typically come with discounts.

---

### Redis Configuration

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.redis.vendor`       | ✅ Required | Cloud vendor | `tencent` |
| `components.redis.providerType` | ✅ Required | Product type | `crs` |
| `components.redis.cluster`      | ✅ Required | Cluster mode | `master` |
| `components.redis.hosts`        | ✅ Required | Redis host list | `["192.168.6.10"]` |
| `components.redis.port`         | ✅ Required | Redis port   | `6379` |
| `components.redis.password`     | ✅ Required | Redis password | `your-password` |

**Allowed `providerType` values:**
- tencent: `crs`

**Purchase link:** https://buy.intl.cloud.tencent.com/redis

**Requirements:**
- Redis 7.0+
- Standalone or cluster edition

**Specification options:**

| Tier | Memory | Connections | Use Case | Monthly Cost (CNY) |
|------|--------|-------------|----------|---------------------|
| Minimal     | 2 GB | 10000 | Dev / test / PoC | 35  |
| Standard    | 4 GB | 10000 | Production, small to medium scale | 70  |
| Recommended | 8 GB | 10000 | Production, large scale | 140 |

**Configuration notes:**
- Product edition: Redis Edition (recommended)
- Compatible version: Redis 7.0+
- Architecture: standard (1 master + 1 replica)
- Performance tier: standard
- Region: same region as the TKE cluster (e.g. Beijing Zone 5)
- Multi-AZ deployment supported

> **Pricing note:** Prices above are estimates for a 1-month subscription period. Actual prices may vary by region and promotions.

---

### Elasticsearch Configuration

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.es.vendor`       | ✅ Required | Cloud vendor | `tencent` |
| `components.es.providerType` | ✅ Required | Product type | `es` |
| `components.es.hosts`        | ✅ Required | ES host list | `["192.168.6.16"]` |
| `components.es.port`         | ✅ Required | ES port      | `9200` |
| `components.es.user`         | ✅ Required | ES user      | `elastic` |
| `components.es.password`     | ✅ Required | ES password  | `your-password` |

**Allowed `providerType` values:**
- tencent: `es`

**Purchase link:** https://buy.intl.cloud.tencent.com/es

**Requirements:**
- Elasticsearch 7.x or 8.x
- At least a 3-node cluster is recommended

**Specification options:**

| Tier | Nodes | CPU/Node | Memory/Node | Storage/Node | Use Case | Monthly Cost (CNY) |
|------|-------|----------|-------------|--------------|----------|---------------------|
| Minimal     | 3 | 2 cores | 4 GB  | 100 GB | Dev / test / PoC | 650   |
| Standard    | 3 | 4 cores | 8 GB  | 200 GB | Production, small to medium scale | 1,950 |
| Recommended | 3 | 8 cores | 16 GB | 200 GB | Production, large scale | 3,300 |

**Configuration notes:**
- Product edition: Elasticsearch Standard (recommended)
- Compatible version: 8.16.1 (multiple versions available)
- Node type: standard
- Storage type: enhanced SSD cloud disk
- Deployment: single AZ (3 nodes)
- Region: same region as the TKE cluster (e.g. Beijing Zone 8)
- Auto disk scaling supported

> **Pricing note:** Prices above are estimates for a 1-month subscription period. Actual prices may vary by region and promotions.

---

### Object Storage Configuration

The unified key is `s3`. The exact storage type is differentiated by `providerType`.

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.s3.vendor`       | ✅ Required | Cloud vendor | `tencent` |
| `components.s3.providerType` | ✅ Required | Product type | `cos` |

**Allowed `providerType` values:**
- tencent: `cos`

#### COS-specific Configuration (effective when `providerType=cos`)

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.s3.cos.secretId`       | ✅ Required | Tencent Cloud SecretId | `AKIDxxxx` |
| `components.s3.cos.secretKey`      | ✅ Required | Tencent Cloud SecretKey | `xxxxx` |
| `components.s3.cos.appId`          | ✅ Required | Tencent Cloud AppId | `1392479074` (do **not** wrap in quotes) |
| `components.s3.cos.bucket`         | ✅ Required | Bucket name | `adp-test-1234567890` |
| `components.s3.cos.region`         | ✅ Required | Region | `ap-guangzhou` |
| `components.s3.cos.domain`         | ✅ Required | COS domain suffix | `myqcloud.com` |
| `components.s3.cos.subPath`        | ✅ Required | Sub-path | `adp-test` (must be granted public-read) |
| `components.s3.cos.expireTime`     | ⚪ Optional | Signature expiration | `3600s` |
| `components.s3.cos.credentialTime` | ⚪ Optional | Temporary credential lifetime | `3600s` |

**Notes**

1. The UIN account behind `components.s3.cos.secretId` and `components.s3.cos.secretKey` must be granted **COS** permissions and **Knowledge Engine Atomic Capability** permissions (**`QcloudLKEAPFullAccess`**). In addition, switch document parsing and document chunking to **post-paid** in https://console.cloud.tencent.com/lkeap/settings.
   <img src="https://adp-testing-1406902593.cos.ap-beijing.myqcloud.com/prod_files/%E6%96%87%E6%A1%A3%E8%A7%A3%E6%9E%90%E5%90%8E%E4%BB%98%E8%B4%B9.png" width="400">

2. Configure CORS on the COS bucket for the domain in use, allowing the `GET`, `PUT`, `OPTIONS`, and `HEAD` methods.

**Purchase link:** https://buy.tencentcloud.com/cos — create a bucket, then create a directory inside it for ADP.

**Specification options:**

| Tier | Storage | Use Case |
|------|---------|----------|
| Minimal     | 50 GB  | Dev / test / PoC |
| Standard    | 500 GB | Production, small to medium scale |
| Recommended | 2 TB+  | Production, large scale |

**Example configuration:**

```yaml
components:
  s3:
    vendor: tencent
    providerType: cos
    cos:
      secretId: AKIDxxxx
      secretKey: xxxxx
      appId: 1234567890  # Note: do NOT wrap in quotes
      bucket: adp-test-1234567890
      region: ap-guangzhou
      domain: myqcloud.com
      subPath: "adp-test"
      expireTime: 3600s
      credentialTime: 3600s
```

---

### Kafka Message Queue Configuration

Kafka is an optional middleware. Purchase Kafka if you need the operation-log query feature in O&M Management.

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.kafka.vendor`       | ✅ Required | Cloud vendor | `tencent` |
| `components.kafka.providerType` | ✅ Required | Product type | `kafka` |
| `components.kafka.hosts`        | ✅ Required | Kafka host list | `["10.0.0.5"]` |
| `components.kafka.port`         | ✅ Required | Kafka port | `9092` |

**Allowed `providerType` values:**
- tencent: `kafka`

**Purchase link:** https://buy.intl.cloud.tencent.com/ckafka

**Requirements:**
- Kafka 2.x or 3.x
- Standard or Pro edition

**Specification options:**

| Tier | Edition | Peak Bandwidth | Disk | Topics | Use Case | Monthly Cost (CNY) |
|------|---------|----------------|------|--------|----------|---------------------|
| Minimal     | Standard | 40 Mbps  | 300 GB  | 50  | Dev / test / PoC | 600   |
| Standard    | Standard | 100 Mbps | 500 GB  | 150 | Production, small to medium scale | 1,200 |
| Recommended | Pro      | 200 Mbps | 1000 GB | 500 | Production, large scale | 2,400 |

**Configuration notes:**
- Product edition: CKafka Standard (recommended) or Pro
- Compatible versions: Kafka 2.4 / 2.8 / 3.x
- Instance type: Standard (pay-as-you-go) or Pro (subscription)
- Message retention: 1–30 days, configurable
- Partitions: auto-allocated; Standard supports up to 500 partitions per instance
- Replicas: Standard supports 2–3 replicas
- Region: same region as the TKE cluster
- Public and private network access supported

**Usage notes:**
- Mainly used for auditing and statistics
- Topics: `pack_pay`, `event_report_prod`, `msg_record_binlog`, `platform_metrology_report`, `t_check_task-formal`, `adp_audit_log_prod`
- Create the topics in advance, or enable auto topic creation
- Topic creation parameters: 3 partitions, 2 replicas

> **Pricing note:** Prices above are estimates for a 1-month subscription period. Actual prices may vary by region and promotions.

**Example configuration:**

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

### ClickHouse Configuration

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `components.clickhouse.vendor`       | ✅ Required | Cloud vendor | `tencent` |
| `components.clickhouse.providerType` | ✅ Required | Product type | `clickhouse` |
| `components.clickhouse.hosts`        | ✅ Required | ClickHouse host list | `["192.168.0.1"]` |
| `components.clickhouse.port`         | ✅ Required | ClickHouse port | `9000` |
| `components.clickhouse.user`         | ✅ Required | ClickHouse user | `default` |
| `components.clickhouse.password`     | ✅ Required | ClickHouse password | `your-password` |

**Allowed `providerType` values:**
- tencent: `clickhouse`

**Purchase link:** https://buy.intl.cloud.tencent.com/cdwch

**Requirements:**
- ClickHouse 25.x
- At least a 2-node cluster is recommended

**Specification options:**

**ClickHouse**

| Tier | Nodes | CPU/Node | Memory/Node | Storage/Node | Use Case | Monthly Cost (CNY) |
|------|-------|----------|-------------|--------------|----------|---------------------|
| General | 2 | 4 cores | 16 GB | 200 GB (SSD) | Statistical analysis | 4,500 |

**ZooKeeper** *(purchased together on the ClickHouse purchase page)*

| Tier | Nodes | CPU/Node | Memory/Node | Storage/Node | Use Case | Monthly Cost (CNY) |
|------|-------|----------|-------------|--------------|----------|---------------------|
| General | 3 (default) | 4 cores | 16 GB | 100 GB (SSD) |  |  |

**Configuration notes:**
- Product edition: ClickHouse Standard (recommended)
- Compatible version: 25.x (multiple versions available)
- Node type: standard
- Storage type: cloud disk (SSD recommended)
- Deployment: single AZ (2 nodes)
- Region: same region as the TKE cluster
- Auto disk scaling supported

> **Pricing note:** Prices above are estimates for a 1-month subscription period. Actual prices may vary by region and promotions.

**Example configuration:**

```yaml
components:
  clickhouse:
    vendor: tencent
    providerType: clickhouse
    hosts:
      - 192.168.0.1
    port: 9000
    user: default
    password: your-password
```

## Observability Configuration (observability)

All observability-related configurations live under `global.observability`.

### CLS Log Collection

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `observability.cls.enabled`  | ⚪ Optional | Enable CLS log collection | `true` / `false` |
| `observability.cls.logsetId` | Conditionally required | CLS logset ID (required when enabled) | `18e6acd6-xxxx` |
| `observability.cls.topicId`  | Conditionally required | CLS log topic ID (required when enabled) | `95fba336-xxxx` |

> Other optional parameters (`logType`, `timeKey`, `timeFormat`, etc.) already have sensible defaults set in the template; no further configuration is required.

**Purchase link:** https://console.intl.cloud.tencent.com/cls/topic

---

### Prometheus Monitoring

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `observability.prometheus.enabled` | ⚪ Optional | Enable Prometheus monitoring | `true` / `false` |

> Other optional parameters (`port`, `interval`, `path`, `scheme`, `matchLabels`, etc.) already have sensible defaults set in the template; no further configuration is required.

**Purchase link:** https://buy.intl.cloud.tencent.com/prometheus

---

### APM Tracing

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `observability.apm.vendor`           | ⚪ Optional | Cloud vendor | `tencent` |
| `observability.apm.providerType`     | ⚪ Optional | Product type | `tps` / `xray` / `jaeger` |
| `observability.apm.otlp`             | ⚪ Optional | OTLP endpoint | `pl.ap-beijing.apm.tencentcs.com:4319` |
| `observability.apm.registry`         | ⚪ Optional | Registry | `""` |
| `observability.apm.attributes.token` | ⚪ Optional | APM token | `xxxxx` |

**Allowed `providerType` values:**
- tencent: `tps`
- aws: `xray`
- self: `jaeger`

**Purchase link:** https://console.intl.cloud.tencent.com/monitor/apm/system/list

---

## Content Security Configuration (contentSecurity)

Used for text content moderation. Optional configuration.

| Key | Required | Description | Example |
|-----|----------|-------------|---------|
| `contentSecurity.region`    | ⚪ Optional | Region | `ap-guangzhou` |
| `contentSecurity.appId`     | ⚪ Optional | App ID | `1234567890` |
| `contentSecurity.uin`       | ⚪ Optional | Root account UIN | `123456789` |
| `contentSecurity.subUin`    | ⚪ Optional | Sub-account UIN | `123456789` |
| `contentSecurity.secretId`  | ⚪ Optional | Tencent Cloud SecretId | `AKIDxxxx` |
| `contentSecurity.secretKey` | ⚪ Optional | Tencent Cloud SecretKey | `xxxxx` |

**Purchase link:** https://console.intl.cloud.tencent.com/cms

**Example configuration:**

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

## Quick Configuration Checklist

### Required Items

Before deploying, make sure the following items are filled in correctly:

- [ ] `global.clb` — CLB domain
- [ ] `global.clbId` — CLB instance ID
- [ ] `global.scheme` — Protocol type
- [ ] `global.clbCertId` — CLB HTTPS certificate ID (required when `scheme` is `https`)
- [ ] `global.rsa.privateKey` — RSA private key
- [ ] `global.rsa.publicKey` — RSA public key
- [ ] `global.components.db.*` — Database configuration
- [ ] `global.components.redis.*` — Redis configuration
- [ ] `global.components.es.*` — Elasticsearch configuration
- [ ] `global.components.s3.*` — Object storage configuration
- [ ] `global.components.kafka.*` — Kafka message queue configuration
- [ ] `global.components.clickhouse.*` — ClickHouse configuration

### Cloud Product Purchase List

| Product              | Purpose | Purchase Link |
|----------------------|---------|---------------|
| CLB Load Balancer    | Traffic ingress | https://buy.intl.cloud.tencent.com/clb |
| MySQL Database       | Business data storage | https://buy.intl.cloud.tencent.com/cdb |
| Elasticsearch        | Log search | https://buy.intl.cloud.tencent.com/es |
| Redis                | Caching | https://buy.intl.cloud.tencent.com/redis |
| COS Object Storage   | File storage | https://buy.tencentcloud.com/cos |
| CKafka Message Queue | Audit log message queue | https://buy.intl.cloud.tencent.com/ckafka |
| ClickHouse           | Data analytics | https://buy.intl.cloud.tencent.com/cdwch |
| CLS Log Service      | Log collection (optional) | https://console.intl.cloud.tencent.com/cls/topic |
| Prometheus           | Monitoring (optional) | https://buy.intl.cloud.tencent.com/prometheus |
| APM                  | Tracing (optional) | https://console.intl.cloud.tencent.com/monitor/apm/system/list |
| ADP Platform         | Knowledge Engine | https://console.intl.cloud.tencent.com/lkeap |

## Recommended Server Configuration

To meet high-availability requirements, deploying Tencent Cloud ADP requires a Kubernetes cluster. The three reference configurations below cover different scales:

### Total Cost — Minimal Configuration

| Component | Monthly Cost (CNY) |
|-----------|---------------------|
| Servers (3 × 16C32G) | 3,000 |
| CLB Load Balancer | Pay-as-you-go |
| TDSQL Database (minimal) | 330 |
| Redis (minimal) | 35 |
| Elasticsearch (minimal) | 650 |
| COS Object Storage | Pay-as-you-go |
| Kafka Message Queue (minimal) | 600 |
| ClickHouse (general) | 4,500 |

### Total Cost — Standard Configuration

| Component | Monthly Cost (CNY) |
|-----------|---------------------|
| Servers (6 × 16C32G) | 6,000 |
| CLB Load Balancer | Pay-as-you-go |
| TDSQL Database (standard) | 700 |
| Redis (standard) | 70 |
| Elasticsearch (standard) | 1,950 |
| COS Object Storage | Pay-as-you-go |
| Kafka Message Queue (standard) | 1,200 |
| ClickHouse (general) | 4,500 |

### Total Cost — Recommended Configuration

| Component | Monthly Cost (CNY) |
|-----------|---------------------|
| Servers (10 × 16C32G) | 10,000 |
| CLB Load Balancer | Pay-as-you-go |
| TDSQL Database (recommended) | 3,000 |
| Redis (recommended) | 140 |
| Elasticsearch (recommended) | 3,300 |
| COS Object Storage | Pay-as-you-go |
| Kafka Message Queue (recommended) | 2,400 |
| ClickHouse (general) | 4,500 |

> **Important notes:**
> 1. All prices above are estimates; the final cost is determined by your actual Tencent Cloud bill.
> 2. CLB and COS are billed by actual usage; costs vary depending on traffic and storage volume.
> 3. For long-term usage, subscription packages typically come with greater discounts.
> 4. Prices may vary by region, subscription duration, and promotional activities.

---

## Deployment Recommendations

1. **Region selection:** Deploy all components in the same region to reduce cross-region latency and cost.
2. **High availability:** For production, deploy across multiple availability zones to improve system availability.
3. **Monitoring & alerting:** Set up comprehensive monitoring and alerting.
4. **Backup strategy:** Regularly back up databases and other critical data.
5. **Security hardening:** Configure security groups, access controls, data encryption, and other security measures.
6. **Auto-scaling:** Adjust resource allocation as your business grows.
