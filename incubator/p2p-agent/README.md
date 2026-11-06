# P2P Agent Helm Chart

P2P Agent 是一个容器镜像与文件加速系统。节点之间按分片互传数据，降低对镜像仓库 / 对象存储的回源压力。典型场景下，50GB 镜像端到端拉取可从约 10 分钟降到约 5 分钟。

当前版本默认使用 **NTracker** 做 Peer 调度，不再依赖旧版 BitTorrent Tracker 与 SeedServer。

## 功能特性

- **NTracker 调度**：高 QPS、可多副本高可用，按热度返回 Peer；限制集群同时回源的节点数，避免打爆源仓库
- **镜像 P2P**：拦截 containerd / docker 的 registry 请求，按层分片在节点间传输
- **文件 P2P**：对接 S3 / COS（含 path-style 自建站点），分片校验后互传
- **Mixed 部署**：同一集群按节点标签同时部署 Seeder 与 Leecher
- **胖瘦分离**：Leecher 使用内存缓存，降低磁盘占用；Seeder 可复用 containerd content store，避免再拷一份层数据
- **自动接入**：可选自动配置 containerd registry mirror，把指定仓库的拉取转到本机 Agent
- **热点扩散**：按下载热度主动增加副本（需开启 Watcher）
- **可治理**：按仓库 / namespace 过滤、私有仓认证、配置热更新、脏数据清理
- **监控**：内置 Prometheus 指标
- **镜像预热**：支持主动预热（腾讯内部功能，TCR 暂不支持）

## 部署模式

推荐使用 Mixed 模式（`global.deployMode=mixed`）：同一集群内按节点标签同时部署 Seeder 与 Leecher。

```text
同一 Kubernetes 集群

       业务节点                      其他 seeder 节点
[containerd / docker]
          |
      本机 mirror
          v
 [seeder / leecher] <-- 下载分片 -- [seeder 1] <-- 互传分片 --> [seeder 2]
          |                              |                           |
      查询分片位置                   查询 / 注册                 查询 / 注册
          |                              |                           |
          +------------------------------+---------------------------+
                                         |
                          +--------------+--------------+
                          | 始终                        | 仅缺失分片
                          v                             v
                     [ntracker]                  [上游镜像仓库]
```

- 资源充足、愿意承担做种上传的节点打 `p2p-role=seeder`：落盘缓存并做种，NTracker 也调度到这类节点
- 希望减少上传与长期缓存开销的节点打 `p2p-role=leecher`：用内存做分片缓冲，不做种

两种角色都向 NTracker 查询分片位置，再从其他 Seeder 下载；Seeder 之间也互传分片。缺失分片时由 Agent 回源到上游镜像仓库。

- **适用**：单个业务集群，可以在节点部署 Agent，按资源条件选择 Seeder 或 Leecher 角色
- **优点**：同集群内节点网络一般互通，无需额外打通跨集群链路
- **代价**：业务节点有 Agent 资源开销，Seeder 还要承担缓存与上传；缓存容量、带宽与业务共享

旧版 `trackerType=tracker`（BitTorrent Tracker + SeedServer）仍可兼容，新部署请使用默认的 NTracker。

## 架构概览

默认架构以 **P2P Agent + NTracker** 为核心，Watcher 按需开启：

```
                        ┌──────────────────┐
                        │     Watcher      │  optional
                        └────────┬─────────┘
                                 │
    ┌────────────────┐   ┌───────▼────────┐   ┌──────────────────┐
    │    Leecher     │◄─►│    NTracker    │◄─►│      Seeder      │
    │  memory cache  │   │    schedule    │   │  disk or reuse   │
    └───────▲────────┘   │  origin admit  │   └────────▲─────────┘
            │            └────────────────┘            │
            │            P2P slice transfer            │
            └──────────────────────────────────────────┘

                 origin: TCR / private registry / S3
```

- **P2P Agent**（DaemonSet）：每个节点上的代理。Seeder 落盘做种并对外提供分片；Leecher 用内存缓存，向 Seeder / 其他 Peer 要数据。监听 `65001`（HTTP）/ `65002`（HTTPS），由 containerd / docker 的 registry mirror 接入。
- **NTracker**（StatefulSet）：Peer 发现与调度。按热度返回节点，限制同一分片的回源并发，持久化注册信息，支持跨集群和崩溃恢复。默认调度到 `p2p-role=seeder` 节点；需要固定入口时再打 `tke.cloud.tencent.com/p2p-ntracker=true`。
- **Watcher**（可选）：主动 / 旁路预热，以及热点层扩散。
- **HAProxy**（可选，DaemonSet）：跨集群无客户端场景的四层入口，把对端集群的镜像流量均衡到本集群 Seeder。

旧版组件 **Tracker / SeedServer / MinIO** 仅在 `agent.trackerType=tracker` 时部署。

## 快速开始

### 前置条件

- Helm 3.0+
- Kubernetes 1.18+
- 至少 1 个 Seeder 节点（NTracker 要调度到 Seeder 或 `p2p-ntracker` 节点）

### 1. 给节点打角色标签

```bash
# 资源充足的节点
kubectl label node <seeder-node> tke.cloud.tencent.com/p2p-role=seeder

# 资源受限的节点
kubectl label node <leecher-node> tke.cloud.tencent.com/p2p-role=leecher
```

未打标签的节点不会调度对应 Agent。

### 2. 安装 Chart

```bash
kubectl create namespace p2pagent

cat > custom-values.yaml << EOF
global:
  deployMode: "mixed"

agent:
  # 改为实际镜像仓库，建议同地域 TCR / CCR
  registryHttps: "ccr.ccs.tencentyun.com"
  defaultRegistry: "ccr.ccs.tencentyun.com"
  # 自动给上述仓库写入 containerd registry mirror
  containerdProxyAutoConfig: true
  # Seeder 建议设为主机 NVMe 挂载点
  # agentDataDir: "/data/p2p"

ntracker:
  enabled: true
EOF

helm install p2p-agent ./incubator/p2p-agent -n p2pagent -f custom-values.yaml --create-namespace
```

默认 NTracker 模式不需要配置 Tracker 存储，也不需要 SeedServer / COS。

### 3. 验证

```bash
kubectl get pods -n p2pagent
kubectl get svc -n p2pagent
```

Mixed 模式下应能看到 `p2pagent-seeder`、`p2pagent-leecher` 和 `ntracker`。

### 4. 拉取验证

已打开 `containerdProxyAutoConfig` 时，把镜像地址换成你配置的仓库即可：

```bash
crictl pull ccr.ccs.tencentyun.com/<namespace>/<image>:<tag>
```

未打开自动配置时，需要在节点上把对应仓库的 mirror 指到本机 Agent：

```bash
# containerd 1.7+（certs.d）
mkdir -p /etc/containerd/certs.d/ccr.ccs.tencentyun.com
cat << EOF | sudo tee /etc/containerd/certs.d/ccr.ccs.tencentyun.com/hosts.toml
server = "https://ccr.ccs.tencentyun.com"

[host."http://127.0.0.1:65001"]
  capabilities = ["pull", "resolve"]
EOF
sudo systemctl restart containerd

# Docker
sudo mkdir -p /etc/docker
cat << EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": ["http://127.0.0.1:65001"]
}
EOF
sudo systemctl restart docker
```

## 常见进阶用法

### 文件 P2P

`agent.featureMode` 默认包含 `file`。客户端按 S3 协议下载时走 Agent，节点间分片互传；支持腾讯云 COS，以及 path-style 的自建站点。

### 跨集群无客户端（HAProxy）

对端集群不部署 Agent，直接把 registry mirror 指向本集群的 HAProxy：

```text
业务集群                                 seeder 集群
--------------------                     --------------------------------------
[containerd / docker] --------mirror --> [haproxy]
                                             |
                                       转发镜像请求
                                             v
                                        [seeder 1] <-- 互传分片 --> [seeder 2]
                                             |                           |
                                         查询 / 注册                 查询 / 注册
                                             +---------------------------+
                                             |
                              +--------------+--------------+
                              | 始终                        | 仅缺失分片
                              v                             v
                         [ntracker]                  [上游镜像仓库]

可选 blob 直连：容器运行时 ----------> seeder
```

- 本集群设置 `haproxy.enabled=true`，并给入口节点打 `tke.cloud.tencent.com/p2p-component-haproxy=true`；HAProxy 监听 `65003`，按源地址一致性哈希转发到 Seeder，并用 PROXY v2 透传真实源 IP。
- Agent 侧设置 `agent.remoteMirrorCIDR` 放行对端客户端网段；开启 `agent.enableProxyProtocol=true` 并把 `agent.trustedProxyCIDR` 设为 HAProxy 节点地址。
- 可选 `agent.enableBlobRedirect=true`：大 blob 以 307 重定向让客户端直连 Seeder，数据面不再经过 HAProxy。

详细配置见 [VALUES.md](./VALUES.md)。