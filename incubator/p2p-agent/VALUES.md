# P2P Agent

## 📊 Values 配置参数表

### 全局配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `global.namespace` | `p2pagent` | string | 部署命名空间 |
| `global.imagePullPolicy` | `IfNotPresent` | string | 镜像拉取策略 |
| `global.deployMode` | `"mixed"` | string | 部署模式：seeder/mixed/leecher |

### 镜像配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `images.agent.image` | `ccr.ccs.tencentyun.com/tke-market/p2p-agent` | string | Agent 镜像地址 |
| `images.agent.tag` | `0.2.0` | string | Agent 镜像版本 |
| `images.agent.pullPolicy` | `IfNotPresent` | string | Agent 镜像拉取策略 |
| `images.tracker.image` | `ccr.ccs.tencentyun.com/tke-market/tracker` | string | Tracker 镜像地址 |
| `images.tracker.tag` | `0.2.0` | string | Tracker 镜像版本 |
| `images.tracker.pullPolicy` | `IfNotPresent` | string | Tracker 镜像拉取策略 |
| `images.seedServer.image` | `ccr.ccs.tencentyun.com/tke-market/seed-server` | string | SeedServer 镜像地址 |
| `images.seedServer.tag` | `0.2.0` | string | SeedServer 镜像版本 |
| `images.seedServer.pullPolicy` | `IfNotPresent` | string | SeedServer 镜像拉取策略 |
| `images.watcher.image` | `ccr.ccs.tencentyun.com/tke-market/watcher` | string | Watcher 镜像地址 |
| `images.watcher.tag` | `0.2.0` | string | Watcher 镜像版本 |
| `images.watcher.pullPolicy` | `IfNotPresent` | string | Watcher 镜像拉取策略 |

### 资源配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `resources.agent` | `{}` | object | Agent 组件资源配置 |
| `resources.tracker` | `{}` | object | Tracker 组件资源配置 |
| `resources.seedServer` | `{}` | object | SeedServer 组件资源配置 |
| `resources.watcher` | `{}` | object | Watcher 组件资源配置 |

### 亲和性配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `affinity.seeder` | 见下方 | object | Seeder 节点亲和性配置 |
| `affinity.leecher` | 见下方 | object | Leecher 节点亲和性配置 |

**默认亲和性配置**：
```yaml
seeder:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: tke.cloud.tencent.com/p2p-role
              operator: In
              values:
                - "seeder"
```

### 基础配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `imagePullSecrets` | `[]` | array | 镜像拉取密钥列表 |
| `nameOverride` | `""` | string | 名称覆盖 |
| `fullnameOverride` | `""` | string | 完整名称覆盖 |

### Agent 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| **P2P 核心配置** | | | |
| `agent.adminPort` | `65100` | int | 管理端口 |
| `agent.dataUnitPort` | `65101` | int | 数据单元端口 |
| `agent.preheatPort` | `65102` | int | 预热端口 |
| `agent.portHTTP` | `65001` | int | HTTP 代理端口 |
| `agent.socketDir` | `/run/p2p-agent` | string | Socket 目录 |
| `agent.hostSocketDir` | `/run/p2p-agent` | string | 主机 Socket 目录 |
| **`agent.agentDataDir`** | `""` | string | ⚠️ Agent 数据目录，请设置为主机 NVME 挂载点 |
| `agent.maxConcurrent` | `8` | int | 最大并发数 |
| `agent.shuffleSize` | `8` | int | 洗牌大小 |
| `agent.minSliceSize` | `4` | int | 最小分片大小 |
| `agent.maxSliceSize` | `128` | int | 最大分片大小 |
| `agent.sliceSizeRate` | `2.0` | float | 分片大小比率 |
| `agent.minP2PTimeout` | `10` | int | 最小 P2P 超时时间 |
| `agent.minP2PDownloadSpeed` | `"5242880"` | string | 最小 P2P 下载速度 |
| `agent.LRUSizeGB` | `50` | int | LRU 缓存大小（GB） |
| `agent.trackersAddr` | `"http://tracker-service/announce"` | string | Tracker 地址 |
| `agent.torrentServerAddr` | `"http://seed-server-service"` | string | 种子服务器地址 |
| `agent.maxMemoryUsageMB` | `2048` | int | 最大内存使用（MB） |
| **注册表配置** | | | |
| `agent.registryHttps` | `"ccr.ccs.tencentyun.com"` | string | HTTPS 注册表列表 |
| `agent.defaultRegistry` | `"ccr.ccs.tencentyun.com"` | string | 默认注册表 |
| **BitTorrent 配置** | | | |
| `agent.btPortRange` | `"50001-80001"` | string | BT 端口范围 |
| `agent.maxPeerConnection` | `35` | int | 最大对等连接数 |
| `agent.requestBlockSize` | `1024` | int | 请求块大小 |
| **工作流配置** | | | |
| `agent.maxBtConcurrentFlow` | `32` | int | 最大 BT 并发流 |
| `agent.maxCpuPercentage` | `75` | int | 最大 CPU 使用率 |
| `agent.maxMemoryPercentage` | `75` | int | 最大内存使用率 |
| `agent.maxCpuUpperBound` | `300` | int | CPU 上限 |
| `agent.maxMemoryUpperBound` | `"3221225472"` | string | 内存上限 |
| `agent.overloadStrategy` | `0` | int | 过载策略 |
| **GC 配置** | | | |
| `agent.expireTime` | `10800` | int | 过期时间 |
| `agent.detectionInterval` | `1800` | int | 检测间隔 |
| `agent.protectionTime` | `3600` | int | 保护时间 |
| `agent.maxFilesNum` | `200` | int | 最大文件数 |
| `agent.diskMinRemainRatio` | `50` | int | 磁盘最小剩余比例 |
| `agent.maxGcNumWhenDiskClear` | `50` | int | 磁盘清理时最大 GC 数 |
| **日志配置** | | | |
| `agent.debug` | `"true"` | string | 调试模式 |
| `agent.logPath` | `""` | string | 日志路径 |
| `agent.logMaxSize` | `500` | int | 日志最大大小 |
| `agent.logMaxNum` | `10` | int | 日志最大数量 |
| **Watcher 配置** | | | |
| `agent.watcherUrl` | `""` | string | Watcher 地址，腾讯内部功能，默认不启用 |
| `agent.heartbeatInterval` | `5` | int | 心跳间隔 |
| `agent.heartbeatTimeout` | `10` | int | 心跳超时 |
| `agent.maxFailedHeartbeats` | `5` | int | 最大失败心跳次数 |
| **限速配置** | | | |
| `agent.leecherReadRateLimit` | `500` | int | Leecher 读取限速 |
| `agent.leecherWriteRateLimit` | `750` | int | Leecher 写入限速 |
| `agent.seederReadRateLimit` | `500` | int | Seeder 读取限速 |
| `agent.seederWriteRateLimit` | `750` | int | Seeder 写入限速 |
| **其他配置** | | | |
| `agent.enableLayerP2PMetrics` | `false` | boolean | 是否启用层 P2P 指标 |

### Tracker 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `tracker.replicaCount` | `1` | int | 副本数量 |
| `tracker.port` | `18951` | int | 服务端口 |
| `tracker.nodePort` | `30080` | int | NodePort 端口 |
| `tracker.debug` | `"true"` | string | 调试模式 |
| `tracker.storageName` | `"memory"` | string | 存储类型：memory/redis |
| `tracker.storageRedis` | `"rediscluster://P2PAgent@redis-cluster-service:6379"` | string | Redis 存储连接字符串 |
| `tracker.chihayaMetricsAddr` | `"0.0.0.0:19888"` | string | Chihaya 指标地址 |
| `tracker.chihayaServiceAddr` | `"0.0.0.0:19898"` | string | Chihaya 服务地址 |
| `tracker.service.type` | `NodePort` | string | 服务类型 |
| `tracker.service.annotations` | `{}` | object | 服务注解 |

### SeedServer 组件配置

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

### Watcher 组件配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `watcher.enabled` | `false` | boolean | 是否启用 |
| `watcher.replicaCount` | `1` | int | 副本数量 |
| `watcher.port` | `11378` | int | 服务端口 |
| `watcher.nodePort` | `30082` | int | NodePort 端口 |
| `watcher.preheatReplicas` | `1` | int | 预热副本数 |
| `watcher.preheatInterval` | `3600` | int | 预热间隔 |
| `watcher.heartbeatInterval` | `5` | int | 心跳间隔 |
| `watcher.heartbeatTimeout` | `10` | int | 心跳超时 |
| `watcher.maxFailedHeartbeats` | `5` | int | 最大失败心跳次数 |
| `watcher.registryEnabled` | `false` | boolean | 是否启用注册表 |
| `watcher.registryUsername` | `""` | string | 注册表用户名 |
| `watcher.registryPassword` | `""` | string | 注册表密码 |
| `watcher.service.type` | `NodePort` | string | 服务类型 |
| `watcher.service.annotations` | `{}` | object | 服务注解 |
| `watcher.manager.clusterId` | `1` | int | p2p 集群 ID |
| `watcher.manager.token` | `""` | string | p2p 集群 Token |
| `watcher.manager.endpoints` | `""` | string | p2p manager 地址 |

### PodMonitor 配置

| 参数 | 默认值 | 类型 | 说明 |
|------|--------|------|------|
| `podMonitor.enabled` | `false` | boolean | 是否启用 PodMonitor |
| `podMonitor.interval` | `30s` | string | 监控间隔 |
| `podMonitor.scrapeTimeout` | `10s` | string | 抓取超时 |
