# DNS Controller Helm Chart

自动同步 Kubernetes Service 到腾讯云 PrivateDNS 的 Helm Chart。

## 功能特性

- ✅ 自动同步 ClusterIP/NodePort/LoadBalancer Service 到 PrivateDNS
- ✅ 支持 Headless Service (StatefulSet Pod DNS)
- ✅ 支持 ExternalName Service
- ✅ Pod DNS 自动注入（通过 Webhook）
- ✅ DNS 记录垃圾回收
- ✅ 高可用部署（Leader Election）
- ✅ Prometheus 指标监控

## 安装前准备

### 必需参数

- `config.clusterId`: 集群 ID
- `config.vpcId`: VPC ID
- `config.region`: 腾讯云地域
- `credentials.secretId`: 腾讯云 Secret ID
- `credentials.secretKey`: 腾讯云 Secret Key

### 可选参数

- `config.dnsSuffix`: DNS 后缀 (默认: local)
- `webhook.enabled`: 是否启用 Webhook (默认: true)
- `privateDNS.enableGlobal`: 是否覆盖 kube-dns (默认: false)

## 安装方式

### 使用 values 文件 (推荐)

创建 `my-values.yaml`:

```yaml
config:
  clusterId: "cls-xxxxxxxx"
  vpcId: "vpc-xxxxxxxx"
  region: "ap-guangzhou"

credentials:
  secretId: "AKIDxxxxxx"
  secretKey: "xxxxxx"

# 可选: 启用全局 DNS
privateDNS:
  enableGlobal: false

# 可选: 禁用 Webhook
webhook:
  enabled: true
```

安装:

```bash
helm install dns-controller . -n kube-system \
  -f my-values.yaml
```

### 使用命令行参数

```bash
helm install dns-controller . -n kube-system \
  --set config.clusterId=cls-xxxxxxxx \
  --set config.vpcId=vpc-xxxxxxxx \
  --set config.region=ap-guangzhou \
  --set credentials.secretId=AKIDxxxxxx \
  --set credentials.secretKey=xxxxxx
```

## 验证安装

查看 Pod 状态:

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=dns-controller
```

查看日志:

```bash
kubectl logs -n kube-system -l app.kubernetes.io/name=dns-controller -f
```

## 升级

```bash
helm upgrade dns-controller . -n kube-system \
  -f my-values.yaml
```

## 卸载

```bash
helm uninstall dns-controller
```

## 配置参数

### 基本配置

| 参数 | 描述 | 默认值 | 必需 |
|------|------|--------|------|
| `image.repository` | 镜像仓库 | `ccr.ccs.tencentyun.com/tke-market/dns-controller` | 否 |
| `image.tag` | 镜像标签 | `v1.1.1` | 否 |
| `image.pullPolicy` | 镜像拉取策略 | `IfNotPresent` | 否 |
| `replicas` | 副本数 | `2` | 否 |
| `config.clusterId` | 集群 ID | `""` | 是 |
| `config.vpcId` | VPC ID | `""` | 是 |
| `config.region` | 腾讯云地域 | `ap-guangzhou` | 是 |
| `config.dnsSuffix` | DNS 后缀 | `local` | 否 |

### 凭证配置

| 参数 | 描述 | 默认值 | 必需 |
|------|------|--------|------|
| `credentials.secretId` | 腾讯云 Secret ID | `""` | 是 |
| `credentials.secretKey` | 腾讯云 Secret Key | `""` | 是 |

### 日志和监控

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `log.level` | 日志级别 (debug/info/warn/error) | `info` |
| `metrics.enabled` | 是否启用指标 | `true` |
| `metrics.addr` | 指标服务地址 | `:8080` |
| `health.addr` | 健康检查地址 | `:8081` |

### PrivateDNS 配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `privateDNS.qps` | QPS 限制 | `90.0` |
| `privateDNS.timeout` | API 超时时间 | `10s` |
| `privateDNS.debug` | 是否启用 debug 日志 | `false` |
| `privateDNS.enableGlobal` | 是否覆盖 kube-dns | `false` |
| `privateDNS.nameservers` | Nameserver 地址列表 | `[183.60.83.19, 183.60.82.98]` |

### 控制器配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `controller.leaderElection` | 是否启用 Leader 选举 | `true` |
| `controller.concurrentWorkers` | 并发 worker 数 | `10` |
| `controller.reconcileInterval` | 全量对账间隔 | `10m` |
| `controller.requeueAfter` | 失败重试间隔 | `30s` |
| `controller.maxConcurrentApi` | 最大并发 API 数 | `10` |

### Webhook 配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `webhook.enabled` | 是否启用 Webhook | `true` |
| `webhook.port` | Webhook 服务端口 | `9443` |

### 垃圾回收配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `gc.enabled` | 是否启用 GC | `true` |
| `gc.interval` | GC 运行间隔 | `30m` |
| `gc.safetyPeriod` | 安全期 | `5m` |
| `gc.concurrency` | GC 并发数 | `3` |
| `gc.maxDeletePerRun` | 每次最多删除数 | `100` |
| `gc.dryRun` | 是否为 Dry Run 模式 | `false` |

### 资源配置

| 参数 | 描述 | 默认值 |
|------|------|--------|
| `resources.limits.cpu` | CPU 限制 | `200m` |
| `resources.limits.memory` | 内存限制 | `256Mi` |
| `resources.requests.cpu` | CPU 请求 | `50m` |
| `resources.requests.memory` | 内存请求 | `128Mi` |

## 故障排查

### Pod 启动失败

```bash
# 查看 Pod 事件
kubectl describe pod -n kube-system -l app.kubernetes.io/name=dns-controller

# 查看日志
kubectl logs -n kube-system -l app.kubernetes.io/name=dns-controller
```

### 权限问题

确认 ServiceAccount 和 ClusterRole 已创建:

```bash
kubectl get sa dns-controller -n kube-system
kubectl get clusterrole dns-controller
kubectl get clusterrolebinding dns-controller
```

### DNS 同步失败

检查配置和凭证:

```bash
kubectl get configmap dns-controller-config -n kube-system -o yaml
kubectl get secret privatedns-credentials -n kube-system
```

## 更多信息

- 项目地址: https://git.woa.com/kateway/dns-controller
