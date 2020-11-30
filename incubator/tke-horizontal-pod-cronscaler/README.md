## HorizontalPodCronscaler (HPC) 说明

## 背景

很多应用，流量的突发是可以预知的，比如电商大促、活动运营期等等。通常做法是，在已知流量高峰前进行workload 的扩容，这些行为完全可以通过配置定时任务实现自动化，减轻用户的维护工作负担。HPC 是一种运行于 tke 集群，可以对k8s workload 副本数进行定时修改的自研组件，配合HPC CR 使用，最小支持秒级的定时任务。

## 实现原理

tke HPC 通过定义一种自定义资源，在自定义资源中添加需要被定时扩缩容的 workload 及对应任务的时间、目标副本或副本范围，后台controller 则监听这类资源的创建、更新、删除，及维护相关的定时任务的创建、更新、销毁，一个定时任务在指定时间启动，并调整workload的副本至目标副本或副本范围。一个HPC 资源负责管理一个workload, 定义多组定时任务。


## 功能

  - 支持设置“ 实例范围 ”（关联对象为HPA） 或 “ 目标实例数量 ”（关联对象为deployment和statefulset）

  - 支持开关“ 例外时间 ”，例外时间的最小的配置粒度是日期，支持设置多条

  - 支持定时任务是否只执行一次


## 使用限制

### 环境要求

kubernetes版本：1.12+
设置kube-apiserver的启动参数 --feature-gates=CustomResourceSubresources=true

### 节点要求

1. HPC 组件默认挂载主机的时区作为定时任务的参考时间。因此要求节点存在 /etc/localtime 文件
2. 默认会安装2个hpc pod 在不同节点，因此节点数推荐为2个及以上。

### 被控资源要求

在创建hpc 资源时，要求需要被控制的 workload(k8s 资源)存在于集群中，或同时创建。

## 配置及默认值

以下表格列出了  HorizontalPodCronscaler 的配置参数及其默认值:

| 参数                        | 描述                               | 默认值 |
| --------------------------- | ---------------------------------- | --------------------------------------------- |
| `replicas`                  | hpc controller 的副本数            | `2`                                           |
| `image`                     | hpc controller 的镜像地址          | `ccr.ccs.tencentyun.com/library/hpc-controller:v1.0.0` |
| `resources.requests.cpu`    | 单个 controller 运行最小 cpu 配额 | `100m`                                        |
| `resources.requests.memory` | 单个 controller  运行最小内存配额  | `20Mi`                                        |
| `resources.limits.cpu`      | 单个 controller 运行的CPU 使用上限 | `100m`                                        |
| `resources.limits.memory`   | 单个 controller 运行的内存使用上限 | `100Mi`                                       |
| `namespace` | hpc controller 运行的名字空间 | `kube-system`                         |
| `ImagePullPolicy` | hpc controller 启动时镜像拉取策略 | ` IfNotPresent`                        |