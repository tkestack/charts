# log-cleaner

宿主机日志清理 DaemonSet，用于清理 Pod 重启/重建后遗留在宿主机 `hostPath` 目录的旧日志文件，避免单机磁盘被占满。

## 背景

ADP 各服务通过 `hostPath` 将日志落到宿主机：

```
/data/ti-platform/log/<service-name>/...
```

当 Pod 重启/重建时，旧 Pod 目录中的日志并不会被自动清理，日积月累会占满宿主机磁盘。

## 方案

- **形式**：DaemonSet（每节点一个 Pod）
- **触发**：容器内 busybox `crond` 每天 03:00 执行清理脚本
- **策略**：按 `mtime` 淘汰，默认删除 7 天前的文件；空目录一并清理
- **不删**：日志根目录 `/data/ti-platform/log/`、以及一级服务子目录本身（`-mindepth`）

## 安全约束

1. 清理根路径通过环境变量 `HOST_LOG_ROOT` 传入，但脚本内**白名单校验**必须以 `/host/logs` 前缀开头，否则拒绝执行。
2. `RETAIN_DAYS` 必须是正整数（正则校验），防命令注入。
3. `find -xdev -mindepth 2 -type f -delete`：不跨文件系统、不删根目录及一级服务目录，只 `find -delete` 不用 `rm -rf`。
4. 容器 `readOnlyRootFilesystem: true`，`capabilities: drop=[ALL]`，只 add 删除他人文件所需的最小 cap。
5. hostPath 只挂载 `/data/ti-platform/log`，不挂 `/` 或 `/data`。

## 配置

`values.yaml` 主要配置项：

| 字段 | 默认值 | 说明 |
|------|--------|------|
| `enabled` | `true` | 是否启用 |
| `hostLogPath` | `/data/ti-platform/log` | 宿主机日志根路径 |
| `retainDays` | `7` | 保留天数（`find -mtime +N`） |
| `schedule` | `0 3 * * *` | cron 表达式 |
| `timezone` | `Asia/Shanghai` | 容器时区（挂宿主机 `/etc/localtime`），置空则按 UTC |
| `tolerateAllTaints` | `true` | 是否容忍所有污点（保证每节点都跑） |
| `resources` | 20m/32Mi ~ 200m/128Mi | 资源限制 |

## 部署

已通过 `helmfile.yaml` 注册，随 ADP 整体部署一起安装。可通过环境变量禁用：

```bash
LOG_CLEANER_ENABLED=false helmfile apply
```

## 手动验证

```bash
# 查看 DaemonSet 每节点分布
kubectl -n <ns> get ds log-cleaner-log-cleaner -o wide
kubectl -n <ns> get pods -l app=log-cleaner -o wide

# 手动触发一次清理（不等 03:00）
POD=$(kubectl -n <ns> get pod -l app=log-cleaner -o jsonpath='{.items[0].metadata.name}')
kubectl -n <ns> exec $POD -- /scripts/cleanup.sh

# 预览模式（只列前 10 条将被删除的文件，不真删）
kubectl -n <ns> exec $POD -- /scripts/cleanup.sh --preview

# 查看清理日志（crond 会把清理输出写到 pid=1 的 stdout）
kubectl -n <ns> logs $POD --tail=100

# 上宿主机确认效果
ssh <node> "find /data/ti-platform/log -mtime +7 -type f | wc -l"
```

## 变更保留天数

修改 `values.yaml` 中 `retainDays`，或通过 helm/helmfile 参数覆盖：

```bash
helm upgrade log-cleaner ./charts/log-cleaner --set retainDays=14 -n <ns>
```

## 与 kubelet 内建日志清理的区别

- kubelet 会自动清理 **已删除 Pod 的容器 stdout 日志**（`/var/log/pods/`、`/var/log/containers/`），此部分**不需要** log-cleaner 处理。
- log-cleaner 处理的是**业务通过 hostPath 落盘到 `/data/ti-platform/log/` 的日志**，这部分 kubelet 不管。
