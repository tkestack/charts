# Agent Portal

`agent-portal` 是用于在 TKE 上部署 Agent Portal（智能体门户）的 Helm Chart。

Agent Portal 是面向企业的智能体统一入口，提供智能体接入与管理、意图总控与路由、多智能体协同编排、运行观测以及模型管理等能力，可对接腾讯云智能体开发平台（ADP）、Dify 及其他 OpenAI 兼容智能体服务。

## 架构说明

Chart 将 Agent Portal 部署为单个 Deployment（前后端同镜像，后端以 `SERVE_WEB=true` 同时托管前端静态资源）：

- **Web 前端**：React 单页应用，由后端在 `APP_BASE_PATH` 子路径下托管
- **后端服务**：Node.js 服务，监听 4000 端口，提供 REST API、SSE 会话与管理台接口
- **db-init initContainer**：容器启动前执行数据库迁移（migrate）与初始化数据写入
- **配置注入**：所有运行时配置由 Kubernetes Secret 渲染为 `.env`，挂载到 `/app/apps/server/.env`，避免数据库密码、对象存储密钥等进入 ConfigMap

## 前置依赖

部署前需自行准备以下外部资源，Chart 本身不包含这些组件：

| 依赖 | 必填 | 说明 |
| ---- | ---- | ---- |
| MySQL / TDSQL-MySQL | ✅ | MySQL 8.0+ 或 TDSQL-MySQL；字符集 `UTF8MB4`；`lower_case_table_names=1`；需提前创建库与授权用户。购买：[MySQL](https://console.cloud.tencent.com/cdb/instance) / [TDSQL](https://console.cloud.tencent.com/tdsqld/instance-tdmysql) |
| 对象存储 COS | ✅ | 用于头像、附件等文件存储；也可对接自建 MinIO。购买：[COS](https://console.cloud.tencent.com/cos) |
| CLB + 域名 | ✅ | 对外访问入口，需绑定自定义域名；填写 `clb` / `clbId`。购买：[CLB](https://console.cloud.tencent.com/clb/instance) |
| SSL 证书 | 条件必填 | `clbScheme=https` 时填写 `clbCertId`，Chart 自动创建 TKE 用的证书 Secret。申请：[SSL](https://console.cloud.tencent.com/ssl) |
| SMTP 服务 | 可选 | 用于邮箱验证与密码重置 |

> **注意**：数据库、COS 建议与 TKE 集群部署在**同一地域**，以获得最佳网络性能。

## 配置说明

以下是主要可配置的参数及默认值。

### 镜像配置

| Key | Description | Default |
|-----|-------------|---------|
| image.repository | Agent Portal 镜像仓库地址 | ccr.ccs.tencentyun.com/tke-market/agent-portal |
| image.tag | 镜像 Tag，为空时使用 Chart 的 appVersion | tke-market-license-dev-67799082-20260805-143502-amd64 |
| image.pullPolicy | 镜像拉取策略 | Always |
| imagePullSecrets | 私有仓库拉取凭据 | [] |
| replicaCount | Deployment 副本数 | 2 |

> 当前镜像仅提供 `linux/amd64` 架构，请确保调度到 amd64 节点；集群中混有 ARM 节点时，建议通过 `nodeSelector` 显式约束：
>
> ```yaml
> nodeSelector:
>   kubernetes.io/arch: amd64
> ```

### 访问配置

| Key | Description | Default |
|-----|-------------|---------|
| clb | **必填**，对外访问域名（绑定到 CLB 的自定义域名） | xx-portal.example.com |
| clbId | **必填**，已有 CLB 实例 ID，写入 `kubernetes.io/ingress.existLbId` | lb-example |
| scheme | 平台访问协议，`http` 或 `https`（用于应用侧 Origin / Public URL） | https |
| clbScheme | CLB 监听协议，`http` 或 `https`；可与 `scheme` 不同以支持 SSL Offload | https |
| clbCertId | **`clbScheme=https` 时必填**，腾讯云 SSL 证书 ID；Chart 生成 Secret `<release>-agent-portal-clb-cert` | \<YOUR_CLB_CERT_ID\> |
| APP_BASE_PATH | 应用部署子路径，需与 `ingress.path` 保持一致；留空表示部署在根路径 | /agent-portal |
| service.type | Service 类型 | ClusterIP |
| service.port | Service 与容器端口 | 4000 |

### ADP 接入配置

| Key | Description | Default |
|-----|-------------|---------|
| adp.apiEndpoint | ADP 云 API 地址，支持 host 或完整 URL | ""（复用 `clb`） |
| adp.chatEndpoint | ADP 对话 SSE 完整地址 | ""（自动拼 `<scheme>://<clb>/adp/v2/chat`） |
| adp.host | Portal 展示和同步时使用的 ADP Host | ""（自动拼 `<scheme>://<clb>`） |

Portal 与 ADP 共用同一个 CLB/域名时无需配置本段；使用独立 ADP 地址时应显式填写。

### Ingress 配置

| Key | Description | Default |
|-----|-------------|---------|
| ingress.enabled | 是否创建 Ingress | true |
| ingress.className | IngressClass 名称，TKE 使用 `qcloud` | qcloud |
| ingress.host | Ingress 域名，为空时取 `clb` | "" |
| ingress.path | 路由路径，需与 `APP_BASE_PATH` 一致 | /agent-portal |
| ingress.pathType | 路径匹配类型 | ImplementationSpecific |
| ingress.tls | 是否启用 TLS；实际挂载还需 `clbScheme=https` | true |
| ingress.tlsSecretName | TLS Secret 名称，为空时由 `clbCertId` 自动生成；填写后复用现成 Secret 且不再创建 | "" |
| ingress.annotations | 额外 Ingress 注解；`existLbId` / `direct-access` 由模板按 `clbId` 自动注入 | {} |

**TKE Ingress 使用注意事项**：
- Chart 对齐 ADP：用 `clbId` 绑定已有 CLB，用 `clbCertId` 自动创建含 `qcloud_cert_id` 的 Secret（名称带 release 前缀，可与 ADP 同命名空间共存）
- `nginx.ingress.kubernetes.io/*` 系列注解对 `qcloud` IngressClass 不生效，如需配置超时请在 CLB 监听器上调整
- 如果集群网络模式未采用负载均衡直连 Pod 模式，后端 Service 的访问类型不能为 `ClusterIP`，需改为 `NodePort` 或 `LoadBalancer`
- 负载均衡直连 Pod 模式详见：[TKE 文档](https://cloud.tencent.com/document/product/457/41897)

### 数据库配置

| Key | Description | Default |
|-----|-------------|---------|
| db.host | **必填**，数据库主机地址 | 192.168.0.1 |
| db.port | 数据库端口 | 3306 |
| db.user | **必填**，数据库用户名 | \<YOUR_DB_USER\> |
| db.password | **必填**，数据库密码 | \<YOUR_DB_PASSWORD\> |
| db.name | 数据库名 | agent_portal |
| db.type | 数据库兼容模式，`mysql` 或 `tdsql` | mysql |
| db.connectionLimit | MySQL 连接池上限，多副本部署时建议保持默认 | 50 |

> 容器启动时会自动执行迁移：空库执行初始化（建表 + 种子数据），已初始化的库仅执行 migrate。

### 文件存储配置

| Key | Description | Default |
|-----|-------------|---------|
| storage.type | 存储类型，`s3`（含 COS / MinIO）或 `local` | s3 |
| storage.bucket | **必填**，Bucket 名称，COS 需带 APPID 后缀 | \<YOUR_COS_BUCKET\> |
| storage.region | **必填**，Bucket 所在地域 | \<YOUR_COS_REGION\> |
| storage.endpoint | 访问 Endpoint，为空时按 region 自动拼 `https://cos.<region>.myqcloud.com` | "" |
| storage.accessKey | **必填**，Access Key（COS 对应 SecretId） | \<YOUR_SECRET_ID\> |
| storage.secretKey | **必填**，Secret Key | \<YOUR_SECRET_KEY\> |
| storage.forcePathStyle | 路径风格寻址；COS 用 `false`，自建 MinIO 用 `true` | "false" |

### 密钥配置

| Key | Description | Default |
|-----|-------------|---------|
| PORTAL_CREDENTIALS_KEY | **必填**，凭据加密与 token 签名密钥，要求 ≥ 32 字符 | \<YOUR_PORTAL_CREDENTIALS_KEY\> |
| BETTER_AUTH_SECRET | **必填**，Session 加密密钥 | \<YOUR_BETTER_AUTH_SECRET\> |
| AUTH_CUSTOMER_SECRET_KEY | Customer 免密登录签名密钥；未启用时可留空 | "" |

**生成方式**：

```bash
openssl rand -base64 32
```

> ⚠️ **升级注意**：`PORTAL_CREDENTIALS_KEY` 用于加密已存储的 IM / Connector 凭据。已有存量数据的环境升级时必须沿用原值，重新生成会导致历史凭据无法解密。

### 单点登录（SSO）配置

支持通过标准 OAuth2 协议对接企业已有的身份认证系统，可选；不配置时使用账号密码登录。

| Key | Description | Default |
|-----|-------------|---------|
| AUTH_GENERIC_OAUTH_CLIENT_ID | OAuth2 Client ID | "" |
| AUTH_GENERIC_OAUTH_CLIENT_SECRET | OAuth2 Client Secret | "" |
| AUTH_GENERIC_OAUTH_AUTHORIZATION_URL | 授权端点地址 | "" |
| AUTH_GENERIC_OAUTH_TOKEN_URL | Token 端点地址 | "" |
| AUTH_GENERIC_OAUTH_USER_INFO_URL | 用户信息端点地址 | "" |
| AUTH_GENERIC_OAUTH_SCOPES | 请求 Scope，多个值用空格分隔 | "read all" |

Client ID、Client Secret 与三个端点需成组配置。用户信息字段映射、Token 认证方式等完整参数见 `values.yaml` 中的 `AUTH_GENERIC_OAUTH_*` 段。

### 邮件配置

| Key | Description | Default |
|-----|-------------|---------|
| SMTP_HOST | SMTP 服务器地址 | "" |
| SMTP_PORT | SMTP 端口 | "587" |
| SMTP_USER | SMTP 用户名 | "" |
| SMTP_PASS | SMTP 密码 | "" |
| SMTP_FROM | 发件人地址 | "" |

### 功能与登录开关

| Key | Description | Default |
|-----|-------------|---------|
| LOGIN_CAPTCHA_ENABLED | 是否启用登录图形验证码 | "true" |
| LOGIN_CAPTCHA_PROVIDER | 验证码提供方：`cap`、`slider` 或 `character` | "cap" |
| LOGIN_CAPTCHA_CHECK_IP | 验证码 IP 一致性校验；CGNAT / 多层代理环境建议关闭 | "false" |
| FEATURE_ORCHESTRATION | 多智能体协同编排总开关 | "true" |
| FULFILLMENT_AGENT_TIMEOUT_MS | 智能体履约超时（毫秒） | "30000" |
| FULFILLMENT_MODEL_TIMEOUT_MS | 模型履约超时（毫秒） | "30000" |
| FULFILLMENT_API_TIMEOUT_MS | API 履约超时（毫秒） | "15000" |
| LOG_LEVEL | 日志级别，`trace` / `debug` / `info` / `warn` / `error` / `fatal` | info |
| LOG_PRETTY | 日志美化输出，生产环境建议保持 `false` | "false" |

管理台与用户端的各模块默认全部开启，无需额外配置。如需按需裁剪模块入口，请联系技术支持。

### 资源与调度配置

| Key | Description | Default |
|-----|-------------|---------|
| resources.limits.cpu | CPU 上限 | "2" |
| resources.limits.memory | 内存上限 | 4Gi |
| resources.requests.cpu | CPU 请求 | "1" |
| resources.requests.memory | 内存请求 | 2Gi |
| nodeSelector | 节点选择器 | {} |
| tolerations | 污点容忍 | [] |
| affinity | 亲和性配置 | {} |
| podAnnotations | Pod 注解 | {} |
| podLabels | Pod 标签 | {} |

## 安装

### 在 TKE 应用市场安装（推荐）

在容器服务控制台进入 **应用市场**，搜索并打开 **Agent Portal**，点击「创建应用」：

![TKE 应用市场创建 Agent Portal](https://agent-portal-1256076159.cos.ap-guangzhou.myqcloud.com/Portal-DocsClipboard_Screenshot_1786436357.png)

按上图填写：

1. **名称**：应用实例名，例如 `agent-portal`
2. **地域 / 集群**：选择目标 TKE 集群
3. **Namespace**：选择或新建部署命名空间
4. **Chart 版本**：选择需要的版本
5. **参数**：右侧编辑框即完整的 `values.yaml`，把占位符替换为实际值即可

参数各字段的含义与默认值见本文「[配置说明](#配置说明)」及 Chart 内的 [`values.yaml`](./values.yaml)，安装前**至少**需要修改：

- 对外访问：`clb` / `clbId` / `scheme` / `clbScheme` / `clbCertId`
- 数据库：`db.host` / `db.user` / `db.password`
- 对象存储：`storage.bucket` / `storage.region` / `storage.accessKey` / `storage.secretKey`
- 应用密钥：`PORTAL_CREDENTIALS_KEY` / `BETTER_AUTH_SECRET`（`openssl rand -base64 32` 生成）

填好后点击「创建」，等待应用状态变为已部署，即可通过 `https://<clb>/<APP_BASE_PATH>` 访问；首次进入以超级管理员身份在授权页粘贴激活码完成 License 激活。

### 使用 Helm 命令行安装

也可以直接用本 Chart 安装，参数写入 `my-values.yaml`（字段同上）：

```bash
helm install agent-portal . -f my-values.yaml -n agent-portal --create-namespace
```

## 示例

### 部署到根路径

```yaml
APP_BASE_PATH: ""
ingress:
  path: /
  pathType: Prefix
```

### 对接自建 MinIO

```yaml
storage:
  bucket: "portal"
  region: "us-east-1"
  endpoint: "http://minio.default.svc.cluster.local:9000"
  accessKey: "<YOUR_MINIO_ACCESS_KEY>"
  secretKey: "<YOUR_MINIO_SECRET_KEY>"
  forcePathStyle: "true"
```

### 查看状态与日志

```bash
kubectl -n agent-portal get deploy,po,svc,ingress -l app.kubernetes.io/name=agent-portal
kubectl -n agent-portal logs -f deploy/agent-portal
```

## 常见 FAQ

**1. Pod 一直处于 `Init:0/1`，`db-init` 容器反复失败**

数据库连接不通或权限不足。检查 `db.host` / `db.port` 是否可从集群内访问、`db.user` 是否对 `db.name` 有建表权限，并确认数据库安全组已放通 TKE 集群网段：

```bash
kubectl -n agent-portal logs deploy/agent-portal -c db-init
```

**2. 启动报错提示数据库配置缺失**

生产环境下 `db.host`、`db.user`、`db.password`、`db.name` 任一缺失都会在启动时抛错，以避免回退到 `localhost` / 空密码。若数据库确实使用空密码，请显式配置 `db.password: ""`。

**3. 页面能打开但静态资源 404**

`APP_BASE_PATH` 与 `ingress.path` 不一致。两者必须相同（例如都为 `/agent-portal`），否则前端资源路径与网关路由无法匹配。

**4. 会话回复中断或长请求被截断**

SSE 长连接被链路上的超时切断。使用 TKE 默认的 `qcloud` IngressClass 时，流量由 CLB 承载，需要在 CLB 监听器上放宽会话保持与空闲超时。若前端还串接了自建网关（Nginx、APISIX 等），需同步放宽其读写超时。

注意 `nginx.ingress.kubernetes.io/*` 系列注解仅对 Nginx Ingress Controller 生效，配置在 `qcloud` IngressClass 上不起作用。

**5. 升级后历史 IM / Connector 凭据无法解密**

`PORTAL_CREDENTIALS_KEY` 被重新生成。请将原环境的 key 原样填回，该值用于存量凭据的 AES-256-GCM 解密。

**6. 登录验证码总是校验失败**

出口 IP 在两次请求间发生变化（CGNAT、多层负载均衡等场景）。将 `LOGIN_CAPTCHA_CHECK_IP` 设为 `"false"`。
