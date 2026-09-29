# P2P Agent Helm Values 配置参数表

## 全局配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `global.namespace` | `p2pagent` | string | 部署命名空间 |
| `global.imagePullPolicy` | `IfNotPresent` | string | 镜像拉取策略 |
| `global.deployMode` | `"mixed"` | string | 部署模式：seeder/mixed/leecher。leecher 不可与 stargz 同时使用 |

## 镜像统一管理

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `images.agent.image` | `ccr.ccs.tencentyun.com/tke-market/p2p-agent` | string | Agent 镜像地址 |
| `images.agent.tag` | `0.2.5` | string | Agent 镜像版本 |
| `images.agent.pullPolicy` | `IfNotPresent` | string | Agent 镜像拉取策略 |
| `images.tracker.image` | `ccr.ccs.tencentyun.com/tke-market/tracker` | string | Tracker 镜像地址 |
| `images.tracker.tag` | `0.2.5` | string | Tracker 镜像版本 |
| `images.tracker.pullPolicy` | `IfNotPresent` | string | Tracker 镜像拉取策略 |
| `images.seedServer.image` | `ccr.ccs.tencentyun.com/tke-market/seed-server` | string | SeedServer 镜像地址 |
| `images.seedServer.tag` | `0.2.5` | string | SeedServer 镜像版本 |
| `images.seedServer.pullPolicy` | `IfNotPresent` | string | SeedServer 镜像拉取策略 |
| `images.watcher.image` | `ccr.ccs.tencentyun.com/tke-market/watcher` | string | Watcher 镜像地址 |
| `images.watcher.tag` | `0.2.5` | string | Watcher 镜像版本 |
| `images.watcher.pullPolicy` | `IfNotPresent` | string | Watcher 镜像拉取策略 |
| `images.ntracker.image` | `ccr.ccs.tencentyun.com/tke-market/ntracker` | string | Ntracker 镜像地址 |
| `images.ntracker.tag` | `0.2.5` | string | Ntracker 镜像版本 |
| `images.ntracker.pullPolicy` | `IfNotPresent` | string | Ntracker 镜像拉取策略 |
| `images.mirrorSetup.image` | `ccr.ccs.tencentyun.com/tke-market/p2p-mirror-setup` | string | Mirror Setup 镜像地址 |
| `images.mirrorSetup.tag` | `0.2.5` | string | Mirror Setup 镜像版本 |
| `images.mirrorSetup.pullPolicy` | `IfNotPresent` | string | Mirror Setup 镜像拉取策略 |

## 资源配置

> 默认为 `{}`（不限制）。配置块存在即启用资源限制，留空或删除整个块即禁用。
> 格式为标准 Kubernetes [resources](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) 结构。

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `resources.agent` | `{}` | Agent Pod 资源限制 |
| `resources.ntracker` | `{}` | NTracker Pod 资源限制 |
| `resources.watcher` | `{}` | Watcher Pod 资源限制 |
| `resources.tracker` | `{}` | Tracker Pod 资源限制 |
| `resources.seedServer` | `{}` | SeedServer Pod 资源限制 |

配置示例：

```yaml
resources:
  agent:
    requests:
      cpu: "1000m"
      memory: "2048Mi"
    limits:
      cpu: "8000m"
      memory: "16384Mi"
```

## 容忍配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `tolerations.agent` | 见下方 | array | Agent（seeder/leecher）Pod 的容忍配置 |
| `tolerations.server` | 见下方 | array | 外围组件（watcher/seedServer/tracker/ntracker）Pod 的容忍配置 |

**默认容忍配置**：
```yaml
tolerations:
  agent:
    - operator: "Exists"
      effect: "NoSchedule"
  server:
    - operator: "Exists"
      effect: "NoSchedule"
```

## 亲和性配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `affinity.seeder` | 见下方 | object | Seeder 节点亲和性配置 |
| `affinity.leecher` | 见下方 | object | Leecher 节点亲和性配置 |
| `affinity.server` | 见下方 | object | 外围组件（watcher/seedServer/tracker）硬亲和性：必须调度到 seeder 节点 |
| `affinity.ntracker` | 见下方 | object | ntracker 亲和性：硬约束为 ntracker 或 seeder 节点（OR），软亲和优先 `tke.cloud.tencent.com/p2p-ntracker=true`；无该标签时降级到 seeder |

**默认亲和性配置**：
```yaml
affinity:
  seeder:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: tke.cloud.tencent.com/p2p-role
                operator: In
                values:
                  - "seeder"
  leecher:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: tke.cloud.tencent.com/p2p-role
                operator: In
                values:
                  - "leecher"
  server:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: tke.cloud.tencent.com/p2p-role
                operator: In
                values:
                  - "seeder"
  ntracker:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: tke.cloud.tencent.com/p2p-ntracker
                operator: In
                values:
                  - "true"
          - matchExpressions:
              - key: tke.cloud.tencent.com/p2p-role
                operator: In
                values:
                  - "seeder"
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
              - key: tke.cloud.tencent.com/p2p-ntracker
                operator: In
                values:
                  - "true"
```

跨集群把 ntracker 节点 IP 写入 leecher 的 `ntrackerDNS` 时，可给少量稳定节点打上 `tke.cloud.tencent.com/p2p-ntracker=true`。ntracker 会优先落到这些节点；没有该标签时降级调度到 `p2p-role=seeder` 节点。`helm install/upgrade` 时若 Ready 可选节点数（ntracker 标签 ∪ seeder）小于 `ntracker.replicaCount`，会直接 fail。StatefulSet 始终带硬反亲和，一台节点只跑一个 ntracker。`helm template` 无集群 API 时跳过节点计数校验。

## 基础配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `imagePullSecrets` | `[]` | array | 镜像拉取密钥列表 |
| `nameOverride` | `""` | string | 名称覆盖 |
| `fullnameOverride` | `""` | string | 完整名称覆盖 |

## Agent 组件配置

P2PAgent 通过 fnotify 和定期轮询检查配置文件更新，支持热更新的配置无需重启。定期轮询时间由`agent.configCheckInterval`配置。

### P2P 核心配置

| 参数 | 默认值 | 类型 | 说明 | 热更新 | 适用场景<br>(文件/镜像/通用)|
|------|--------|------|------|:------:|------|
| `agent.adminPort` | `65100` | int | 管理端口 | 否 | 通用 |
| `agent.dataUnitPort` | `65101` | int | 数据单元端口 | 否 | 通用 |
| `agent.preheatPort` | `65102` | int | 预热端口 | 否 | 镜像 |
| `agent.portHTTP` | `65001` | int | HTTP 代理端口 | 否 | 通用 |
| `agent.portHTTPS` | `65002` | int | HTTPS 代理端口 | 否 | 通用 |
| `agent.peerPortRange` | `"65200-65399"` | string | ntracker 模式 peer 间进行 P2P 传输端口范围，格式 "start（含）-end（含）"，在启动时依次尝试 | 否 | 通用 |
| `agent.socketDir` | `/run/p2p-agent` | string | Socket 目录 | 否 | 通用 |
| `agent.hostSocketDir` | `/run/p2p-agent` | string | 主机 Socket 目录 | 否 | 通用 |
| **`agent.agentDataDir`** | `""` | string | Agent 数据目录，请设置为主机 NVME 挂载点 | 否 | 通用 |
| `agent.configCheckInterval` | `600` | int | 配置热更新轮询间隔（秒），默认 600 | 是 | 通用 |
| `agent.featureMode` | `"image,preheat,file"` | string | 功能模式，逗号分隔启用的功能：`image`（镜像 P2P）、`file`（文件 P2P）、`preheat`（预热），image 始终隐式启用 | 否 | 通用 |
| `agent.trackerType` | `"ntracker"` | string | Tracker 类型：ntracker/bittorrent | 否 | 通用 |
| `agent.trackersAddr` | `"http://tracker-service/announce"` | string | Tracker 地址 | 否 | 通用 |
| `agent.torrentServerAddr` | `"http://seed-server-service"` | string | 种子服务器地址 | 否 | 通用 |
| `agent.ntrackersAddr` | `""` | string | 静态 ntracker 地址列表（逗号分隔），设置后跳过 DNS/discovery 刷新 | 否 | 通用 |
| `agent.ntrackerDNS` | `"ntracker-service"` | string | ntracker 服务地址 | 否 | 通用 |

### P2P 下载配置

以下配置镜像与文件下载通用。

| 参数 | 默认值 | 类型 | 说明 | 热更新 |
|------|--------|------|------|:------:|
| `agent.maxConcurrent` | `8` | int | 单层最大 slice worker 并发数 | 是 |
| `agent.globalMaxConcurrent` | `32` | int | 全局回源 slice 下载最大并发数 | 是 |
| `agent.headSlices` | `0` | int | 打乱 slice 前保持顺序下发的头部 slice 数，0 或未配置表示关闭 | 是 |
| `agent.shuffleSize` | `32` | int | 按特定组大小打乱下载数据，可避免p2p集群同时请求数据的同一段。0表示不打乱。Leecher 与 Content Store Seeder（`reuseContainerdContentStore`）强制为 0。预热场景下可以适当调小该值，以减少数据的响应延迟 | 是 |
| `agent.minSliceSize` | `4` | int | 最小分片大小（MB） | 是 |
| `agent.maxSliceSize` | `128` | int | 最大分片大小（MB） | 是 |
| `agent.sliceSizeRate` | `2.0` | float | 分片大小增长率 | 是 |
| `agent.minP2PTimeout` | `10` | int | 最小 P2P 超时时间（秒） | 是 |
| `agent.minP2PDownloadSpeed` | `2097152` | int | 最小 P2P 下载速度（字节/秒） | 是 |
| `agent.minLayerDownloadSpeed` | `5242880` | int | 最小层级下载速度（字节/秒） | 是 |
| `agent.leecherReadRateLimit` | `500` | int | Leecher 读取限速（MB/s） | 是 |
| `agent.leecherWriteRateLimit` | `750` | int | Leecher 写入限速（MB/s） | 是 |
| `agent.seederReadRateLimit` | `500` | int | Seeder 读取限速（MB/s） | 是 |
| `agent.seederWriteRateLimit` | `750` | int | Seeder 写入限速（MB/s） | 是 |
| `agent.maxMemoryUsageMB` | `2048` | int | 最大内存使用（MB） | 否 |
| `agent.maxConcurrentUploads` | `256` | int | 最大并发上传连接数，超过后返回 503 | 是 |
| `agent.maxBtConcurrentFlow` | `256` | int | 最大 BT 并发流 | 是 |
| `agent.maxCpuPercentage` | `75` | int | 最大 CPU 使用率（%） | 是 |
| `agent.maxMemoryPercentage` | `75` | int | 最大内存使用率（%） | 是 |
| `agent.maxCpuUpperBound` | `300` | int | CPU 上限（%） | 是 |
| `agent.maxMemoryUpperBound` | `3221225472` | int | 内存上限（字节） | 是 |
| `agent.overloadStrategy` | `0` | int | 过载策略（0=拒绝新任务，1=回源下载） | 是 |
| `agent.btPortRange` | `"50001-80001"` | string | BT 端口范围（仅 BT 模式有效，ntracker 模式下无效） | 否 |
| `agent.maxPeerConnection` | `35` | int | 最大对等连接数（仅 BT 模式有效，ntracker 模式下无效） | 是 |
| `agent.requestBlockSize` | `1024` | int | 请求块大小（字节）（仅 BT 模式有效，ntracker 模式下无效） | 否 |

### 镜像源代理

| 参数 | 默认值 | 类型 | 说明 | 热更新 |
|------|--------|------|------|:------:|
| `agent.registryHttps` | `"ccr.ccs.tencentyun.com"` | string | HTTPS 注册表列表 | 否 |
| `agent.registryHttp` | `"ccr.ccs.tencentyun.com"` | string | HTTP 注册表列表；与 `agent.registryHttps` 重合时，Helm 渲染会从 HTTP 列表中移除重合项 | 否 |
| `agent.defaultRegistry` | `"ccr.ccs.tencentyun.com"` | string | 默认注册表 | 是 |
| `agent.containerdProxyAutoConfig` | `false` | boolean | 启用 containerd certs.d mirror 代理方案。启用后通过 init container 配置 containerd 的 per-registry mirror，将镜像拉取请求转发到 P2P Agent。registryHttps/registryHttp 中的仓库会自动生成对应的 hosts.toml | 否 |
| `agent.remoteMirrorCIDR` | `""` | string | 允许来自其他节点的镜像代理请求，逗号分隔 CIDR；空表示拒绝所有远端 mirror | 是 |
| `agent.namespaceWhitelist` | `""` | string | 允许走 P2P 的 host/namespace，逗号分隔 | 是 |
| `agent.namespaceBlacklist` | `""` | string | 禁止走 P2P 的 host/namespace，逗号分隔 | 是 |
| `agent.repoWhitelist` | `""` | string | 允许走 P2P 的 host/namespace/repo，逗号分隔 | 是 |
| `agent.repoBlacklist` | `""` | string | 禁止走 P2P 的 host/namespace/repo，逗号分隔 | 是 |
| `agent.registryAuth.username` | `""` | string | Registry 认证用户名，仅在使用 docker registry mirror 模式时需要配置，用于回源拉取私有仓库时的认证。为空表示不启用认证 | 是 |
| `agent.registryAuth.password` | `""` | string | Registry 认证密码，与 username 配合使用 | 是 |

**namespaceWhitelist、repoWhiteList配置说明：**

| 配置情况 | 行为 |
|---------|------|
| 黑白名单都不配置 | 全部放行，所有镜像走 P2P |
| 仅配置黑名单 | 命中黑名单的禁用 P2P，其余放行 |
| 仅配置白名单 | 只允许命中白名单的走 P2P，其余禁用 |
| 黑白名单都配置 | 先检查黑名单，命中则禁用；未命中黑名单的再检查白名单，命中白名单才放行 |

namespace 和 repo 两个维度同时配置白名单时取 AND 语义：两个维度都要命中才放行。配置示例如下：

 ```yaml
agent:
  # 只允许 mirrors.tencent.com 上的 llmapp namespace 走 P2P
  namespaceWhitelist: "mirrors.tencent.com/llmapp"

  # 禁止所有 registry 上的 test- 开头的 namespace 走 P2P
  namespaceBlacklist: "*/test-*"

  # 只允许特定 repo 走 P2P
  repoWhitelist: "mirrors.tencent.com/llmapp/flow-executor"

  # 禁止特定 repo（含子路径）走 P2P
  repoBlacklist: "mirrors.tencent.com/internal/debug-tool"

  # 多个规则用逗号分隔
  namespaceWhitelist: "mirrors.tencent.com/llmapp,ccr.ccs.tencentyun.com/prod-*"
```

### GC (LRU)

以下配置仅在 seeder 模式生效。

| 参数 | 默认值 | 类型 | 说明 | 热更新 |
|------|--------|------|------|:------:|
| `agent.LRUSizeGB` | `50` | int | LRU 缓存大小（GB） | 否 |
| `agent.evictionWindowFactor` | `2.0` | float | LRU 淘汰候选窗口放大系数 F（余量段 = (F-1)×目标淘汰量）；(0,1) 按 2 处理 | 是 |
| `agent.evictionMinSlackWindow` | `64` | int | LRU 淘汰余量段节点数下限| 是 |
| `agent.evictionMaxSlackWindow` | `50000` | int | LRU 淘汰余量段节点数上限（安全阀） | 是 |
| `agent.protectionTime` | `3600` | int | 保护时间（秒） | 是 |
| `agent.maxFilesNum` | `200` | int | 最大文件数 | 是 |
| `agent.diskMinRemainRatio` | `50` | int | 磁盘最小剩余比例（%） | 是 |
| `agent.maxGcNumWhenDiskClear` | `50` | int | 磁盘清理时最大 GC 数 | 是 |

### GC (TTL)

以下配置仅在 seeder 模式生效，均支持热更新。

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `agent.expireTime` | `10800` | int | 过期时间（秒） |
| `agent.detectionInterval` | `1800` | int | 检测间隔（秒） |

### 日志配置

以下配置镜像与文件下载通用。

| 参数 | 默认值 | 类型 | 说明 | 热更新 |
|------|--------|------|------|:------:|
| `agent.debug` | `false` | boolean | 调试模式 | 是 |
| `agent.logLevel` | `"info"` | string | 日志级别 | 是 |
| `agent.logPath` | `""` | string | 日志路径 | 否 |
| `agent.logMaxSize` | `500` | int | 日志最大大小（MB） | 否 |
| `agent.logMaxNum` | `10` | int | 日志最大数量 | 否 |

### Watcher 配置

以下配置仅在镜像 seeder 模式下生效，均不支持热更新。

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `agent.watcherUrl` | `""` | string | Watcher 地址，默认不启用 |
| `agent.heartbeatInterval` | `5` | int | 心跳间隔（秒） |
| `agent.heartbeatTimeout` | `10` | int | 心跳超时（秒） |
| `agent.maxFailedHeartbeats` | `5` | int | 最大失败心跳次数 |

### 其他配置

| 参数 | 默认值 | 类型 | 说明 | 热更新 | 适用场景<br>(文件/镜像/通用)|
|------|--------|------|------|:------:|------|
| `agent.enableLayerP2PMetrics` | `false` | boolean | 是否启用层 P2P 指标 | 是 | 镜像 |
| `agent.reuseContainerdContentStore` | `false` | boolean | 是否复用 containerd 的 content store 作为做种数据源，启用后 seeder 无需额外拷贝层数据，直接从 containerd content store 读取并做种。仅支持 `trackerType=ntracker`。不可与 stargz 同时使用 | 否 | 镜像(seeder) |

## Tracker 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `tracker.replicaCount` | `1` | int | 副本数量 |
| `tracker.port` | `18951` | int | 服务端口 |
| `tracker.nodePort` | `30080` | int | NodePort 端口 |
| `tracker.debug` | `true` | boolean | 调试模式 |
| `tracker.storageName` | `"memory"` | string | 存储类型：memory/redis |
| `tracker.storageRedis` | `""` | string | 外部 Redis 连接字符串，storageName 为 redis 时必填 |
| `tracker.chihayaMetricsAddr` | `"0.0.0.0:19888"` | string | Chihaya 指标地址 |
| `tracker.chihayaServiceAddr` | `"0.0.0.0:19898"` | string | Chihaya 服务地址 |
| `tracker.service.type` | `NodePort` | string | 服务类型 |
| `tracker.service.annotations` | `{}` | object | 服务注解 |

## SeedServer 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `seedServer.replicaCount` | `1` | int | 副本数量 |
| `seedServer.port` | `11008` | int | 服务端口 |
| `seedServer.nodePort` | `30081` | int | NodePort 端口 |
| `seedServer.cosUrl` | `"minio-service:80"` | string | 对象存储地址 |
| `seedServer.cosId` | `"admin"` | string | 对象存储用户名 |
| `seedServer.cosKey` | `"P2PAgent"` | string | 对象存储密钥 |
| `seedServer.service.type` | `NodePort` | string | 服务类型 |
| `seedServer.service.annotations` | `{}` | object | 服务注解 |

## Watcher 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `watcher.enabled` | `false` | boolean | 是否启用 |
| `watcher.replicaCount` | `1` | int | 副本数量 |
| `watcher.port` | `11378` | int | 服务端口 |
| `watcher.nodePort` | `30082` | int | NodePort 端口 |
| `watcher.preheatReplicas` | `1` | int | 预热副本数 |
| `watcher.preheatSuccessThreshold` | `95` | float | 预热成功比例阈值（0~100），达到 `ceil(target×ratio%)` 即完成，不再补齐到 target, 当target较小时，`ceil(target×ratio%)` 可能和target相同，从而导致该配置不生效 |
| `watcher.maxConcurrency` | `10` | int | 单轮最多同时触发的 layer 数；seeder 很少时可调低，避免排队超过层超时 |
| `watcher.maxLayerRetries` | `5` | int | 单 layer 最大重试次数 |
| `watcher.imageRetryTTL` | `15` | int | 镜像失败 layer 重试的最长分钟数 |
| `watcher.summaryInterval` | `300` | int | 集群预热效果摘要日志间隔（秒） |
| `watcher.preheatInterval` | `15` | int | 预热间隔（秒） |
| `watcher.passivePreheatTimeWindow` | `60` | int | 被动预热时间窗大小（秒） |
| `watcher.passivePreheatThreshold` | `2` | int | 在`passivePreheatTimeWindow`时间窗内接收到`passivePreheatThreshold`次旁路预热请求，启动旁路预热 |
| `watcher.registryUsername` | `""` | string | 注册表用户名 |
| `watcher.registryPassword` | `""` | string | 注册表密码 |
| `watcher.logPath` | `"/app/watcher.log"` | string | 日志文件路径 |
| `watcher.logLevel` | `"info"` | string | 日志级别 |
| `watcher.manager.clusterId` | `1` | int | p2p 集群 ID |
| `watcher.manager.limit` | `20` | int | 每轮从 manager 拉取的 image/blob 上限；略高于纯冷下载吞吐，以便公共层 cache-hit 可突发；队列接近满时内部会跳过拉取 |
| `watcher.manager.token` | `""` | string | p2p 集群 Token |
| `watcher.manager.endpoints` | `["http://p2p-manager-service:8080"]` | list | p2p manager 地址列表 |
| `watcher.manager.seederCleanupInterval` | `1200` | int | Seeder 清理间隔（秒） |
| `watcher.service.type` | `NodePort` | string | 服务类型 |
| `watcher.service.annotations` | `{}` | object | 服务注解 |
| `watcher.persistence.enabled` | `true` | boolean | 是否启用持久化存储 |
| `watcher.persistence.size` | `10Gi` | string | 持久化存储卷大小 |
| `watcher.persistence.accessMode` | `ReadWriteOnce` | string | 存储访问模式（ReadWriteOnce/ReadOnlyMany/ReadWriteMany） |
| `watcher.persistence.storageClass` | `""` | string | 存储类名称，为空则使用集群默认存储类 |

## NTracker 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `ntracker.enabled` | `true` | boolean | 是否启用 ntracker（新一代 Tracker） |
| `ntracker.replicaCount` | `1` | int | 副本数量；不能超过 Ready 可选节点数（`p2p-ntracker=true` ∪ `p2p-role=seeder`），否则 `helm install/upgrade` 失败 |
| `ntracker.port` | `58080` | int | 服务端口 |
| `ntracker.nodePort` | `30083` | int | NodePort 端口 |
| `ntracker.hostNetwork` | `false` | boolean | 是否启用 hostNetwork |
| `ntracker.shardCount` | `1024` | int | 分片锁数量 |
| `ntracker.cleanupInterval` | `120` | int | 清理间隔（秒），定期检查过期数据 |
| `ntracker.infoHashLimit` | `200000` | int | 最大 info hash 数量，超过则触发 LRU 清理 |
| `ntracker.tombstoneTTL` | `1800` | int | 离线 peer 墓碑条目 TTL（秒），用于过滤已下线 peer，触发位图懒清理 |
| `ntracker.unreachableWindow` | `20` | int | 判定 peer 不可达的时间窗口（秒） |
| `ntracker.unreachableThreshold` | `2` | int | 窗口内失败次数达到该值后标记 peer 不可达 |
| `ntracker.aofPath` | `"/app/data/ntracker.aof"` | string | AOF 持久化文件路径 |
| `ntracker.aofSyncInterval` | `5` | int | AOF 同步间隔（秒） |
| `ntracker.hotThreshold` | `500` | int | 热点数据阈值，访问次数超过此值视为热点 |
| `ntracker.hotCacheSize` | `1000` | int | 热点数据缓存大小 |
| `ntracker.peerHotThreshold` | `1000` | int | Peer CMS 频率阈值，用于热点检测（hard-hot = 4x 此值） |
| `ntracker.peerNumber` | `8192` | int | Peer 数量：全局 peer 存储容量及每个 info hash 的 peer bitmap 大小 |
| `ntracker.originMaxConcurrentPerSlice` | `2` | int | 同一个 slice 允许同时回源的 p2pagent 数量；`0` 关闭回源 permit（完全放行），`N>0` 启用并限制为 N |
| `ntracker.originPermitLeaseTTL` | `300` | int | 回源 permit 租约 TTL（秒），用于 agent 异常退出后的自动释放 |
| `ntracker.logPath` | `"/app/ntracker.log"` | string | 日志文件路径 |
| `ntracker.logLevel` | `"info"` | string | 日志级别 |
| `ntracker.persistence.size` | `10Gi` | string | 持久化存储卷大小 |
| `ntracker.persistence.accessMode` | `ReadWriteOnce` | string | 存储访问模式 |
| `ntracker.persistence.storageClass` | `""` | string | 存储类名称，为空则使用集群默认存储类 |
| `ntracker.service.type` | `NodePort` | string | 服务类型 |
| `ntracker.service.annotations` | `{}` | object | 服务注解 |

### Agent headless service

chart 在所有部署模式（`seeder`/`leecher`/`mixed`）下都会渲染三个 headless service，agent Pod 统一带 `role` 标签，因此按角色选取节点与 `deployMode` 无关：

| Service | 选中的 Pod |
|---------|-----------|
| `p2p-agent-service` | 全部 agent |
| `p2p-agent-seeder-service` | 仅 seeder |
| `p2p-agent-leecher-service` | 仅 leecher |

选不到 Pod 的 service 只是 DNS 解析为空，不影响使用。

## Spread (主动扩散) 配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `spread.enabled` | `false` | boolean | 主动扩散总开关。启用后agent上报热点层，watcher统计热点情况执行扩散。必须同时设置 `watcher.enabled=true`，否则 `helm install/upgrade` 失败 |
| `spread.agent.hotLayerWindow` | `12` | int | agent 热点层检测的时间窗口（秒），窗口内统计请求来源IP数 |
| `spread.agent.hotLayerThreshold` | `3` | int | agent 触发上报的最小独立 IP 数，达到后向 watcher 上报热点层 |
| `spread.watcher.windowDuration` | `15` | int | watcher 扩散收集的窗口（秒），每窗口执行一次扩散 |
| `spread.watcher.cooldownPeriod` | `120` | int | 特定层扩散成功后的冷却时间（秒），冷却期内忽略重复扩散请求 |
| `spread.watcher.pressureThreshold` | `3` | int | 单副本目标服务节点数，用于计算需扩散的副本数(扩散后副本数尽量匹配服务节点数) |
| `spread.watcher.maxReplicasPerLayer` | `30` | int | 单层一次扩散的最大副本数；调大时请同步调大 `maxGlobalReplicas`（建议 `maxGlobalReplicas >= maxReplicasPerLayer`） |
| `spread.watcher.maxGlobalReplicas` | `20` | int | 单窗口内全局扩散副本总预算上限；调大时请与 `maxReplicasPerLayer` 同步，否则单层目标会被全局预算削掉 |

## PodMonitor 配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `podMonitor.enabled` | `false` | boolean | 是否启用 PodMonitor |
| `podMonitor.interval` | `30s` | string | 监控间隔 |
| `podMonitor.scrapeTimeout` | `10s` | string | 抓取超时 |

## LocalPathProvisioner 配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `localPathProvisioner.enabled` | `true` | boolean | 是否部署内置 local-path-provisioner（为 NTracker/Watcher 提供本地持久化存储） |
| `localPathProvisioner.hostNetwork` | `true` | boolean | 是否启用 hostNetwork，在无法分配 Pod IP 的环境中需要开启 |

## Minio 配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `minio.enabled` | `false` | boolean | 是否启用内置 Minio（仅 `trackerType=tracker` 时 SeedServer 需要；默认 NTracker 模式不用开启） |
