## 背景

当 TKE 集群配置了节点池并启用了弹性伸缩，在节点资源不够时可以触发节点的自动扩容 (自动买机器并加入集群)，但这个扩容流程需要一定的时间才能完成，在一些流量突高的场景，这个扩容速度可能会显得太慢，影响业务。 `tke-autoscaling-placeholder` 可以用于在 TKE 上实现秒级伸缩，应对这种流量突高的场景。

## 实现原理

`tke-autoscaling-placeholder` 实际就是利用低优先级的 Pod 对资源进行提前占位，为一些可能会出现流量突高的高优先级业务预留部分资源作为缓冲，当需要扩容 Pod 时，高优先级的 Pod 就可以快速抢占低优先级 Pod 的资源进行调度，而低优先级的 `tke-autoscaling-placeholder` 的 Pod 则会被 "挤走"，状态变成 Pending，如果配置了节点池并启用弹性伸缩，就会触发节点的扩容。这样，由于有了一些资源作为缓冲，即使节点扩容慢，也能保证一些 Pod 能够快速扩容并调度上，实现秒级伸缩。要调整预留的缓冲资源多少，可根据实际需求调整 `tke-autoscaling-placeholder` 的 request 或副本数。

## 使用限制

使用该应用要求集群版本在 1.18 以上。

## 配置

以下表格列出了 `tke-autoscaling-placeholder` 的配置参数及其默认值:

| 参数                        | 描述                                                       | 默认值                                        |
|-----------------------------|------------------------------------------------------------|-----------------------------------------------|
| `replicaCount`              | placeholder 的副本数                                       | `10`                                          |
| `image`                     | placeholder 的镜像地址                                     | `ccr.ccs.tencentyun.com/tke-market/pause:latest` |
| `resources.requests.cpu`    | 单个 placeholder 副本占位的 cpu 资源大小                   | `300m`                                        |
| `resources.requests.memory` | 单个 placeholder 副本占位的内存大小                        | `600Mi`                                       |
| `lowPriorityClass.create`   | 是否创建低优先级的 PriorityClass (用于被 placeholder 引用) | `true`                                        |
| `lowPriorityClass.name`     | 低优先级的 PriorityClass 的名称                            | `low-priority`                                |
| `nodeSelector`              | 指定 placeholder 被调度到带有特定 label 的节点             | `{}`                                          |
| `tolerations`               | 指定 placeholder 要容忍的污点                              | `[]`                                          |
| `affinity`                  | 指定 placeholder 的亲和性配置                              | `{}`                                          |
