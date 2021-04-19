<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*


- [TKE Resilience Chart](#tke-resilience-chart)
  - [TKE Resilience Chart 组件定义](#tke-resilience-chart-组件定义)
  - [安装 TKE Resilience Chart](#安装-tke-resilience-chart)
  - [卸载 TKE Resilience Chart](#卸载-tke-resilience-chart)
  - [配置及默认值](#配置及默认值)
  - [主要特性](#主要特性)
  - [测试用例](#测试用例)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# TKE Resilience Chart
 
部署在IDC/私有云中的Kubernetes集群资源是有限的，随着用户workload数量和规模的不断增大，计算，网络，存储等资源最终会被消耗殆尽，而TKE Resilience Chart利用Tencent公有云EKS技术，基于自定义的调度策略，将用户集群中的workload弹性上云，从而将用户集群资源容量扩展到无限，并带来以下好处：

1. 用户IDC/私有云的硬件和维护成本保持不变
2. 实现了用户IDC/私有云和公有云级别的workload高可用
3. 用户对公有云的资源是按需使用，按需付费

## TKE Resilience Chart 组件定义

TKE Resilience Chart主要是由虚拟节点管理器，调度器，污点控制器3部分组成，如下表格：
| 简称                 | 组件名称       | 描述                                                                 |
| -------------------- | -------------- | -------------------------------------------------------------------- |
| eklet                | 虚拟节点管理器 | 负责podsandbox生命周期的管理，并对外提供原生kubelet与节点相关的接口  |
| tke-scheduler        | 调度器         | 负责根据调度策略将workload弹性上云, 仅会安装在非tke发行版的k8s集群上 |
| admission-controller | 容忍控制器     | 负将处于 `pending` 状态的pod添加容忍，使其可以调度到虚拟节点上       |

## 安装 TKE Resilience Chart  

这里以 Chart 版本`v0.0.1`为例，通过helm chart安装

```bash
 helm install tke-resilience  --namespace kube-system ./tke-resilience --debug
```

## 卸载 TKE Resilience Chart  

```bash
helm delete tke-resilience -n kube-system 
```

## 配置及默认值

| 参数                              | 描述                                             | 默认值                            |
| --------------------------------- | ------------------------------------------------ | --------------------------------- |
| `cloud.appID`                     | 腾讯云用户appID                                  | ""                                |
| `cloud.ownerUIN`                  | 腾讯云用户账号ID                                 | ""                                |
| `cloud.secretID`                  | 腾讯云API密钥SecretId                            | ""                                |
| `cloud.secretKey`                 | 腾讯云API密钥SecretKey                           | ""                                |
| `cloud.vpcID`                     | 腾讯云VPC ID                                     | ""                                |
| `cloud.regionShort`               | 腾讯云Region短名                                 | `cq`                              |
| `cloud.regionLong`                | 腾讯云Region长名                                 | `ap-chongqing`                    |
| `cloud.apiDomain`                 | 腾讯云API域名                                    | `tencentcloudapi.com`             |
| `cloud.subnets.id[0...N]`         | 腾讯云VPC内子网ID,可以指定多个subnetID           | `subnet-xxx`                      |
| `eklet.waitSandboxRunningTimeout` | eklet等待Pod运行的超时时间                       | `24h`                             |
| `eklet.podUsedApiserver`          | eklet连接用户集群的API server地址，需VPC内网可达 | `https://127.0.0.1:6443`          |
| `eklet.replicaCount`              | eklet副本数量                                    | `1`                               |
| `eklet.image.ref`                 | eklet运行时镜像                                  | `eklet-amd64:v2.5.0-rc7`          |
| `eklet.image.pullPolicy`          | eklet镜像拉取策略                                | `IfNotPresent`                    |
| `eklet.service.type`              | eklet service类型,                               | `NodePort`                        |
| `eklet.nodeSelector`              | eklet节点选择器                                  | `os=linux and arch=amd64`         |
| `eklet.resources.limits`          | eklet资源上限配额                                | `cpu: "1", memory: 1Gi`           |
| `eklet.resources.requests`        | eklet资源请求配额                                | `cpu: "200m", memory: 200Mi`      |
| `scheduler.replicaCount`          | scheduler副本数量                                | `1`                               |
| `scheduler.image.ref`             | scheduler运行时镜像                              | `kube-scheduler:v1.20.4-tke.1`    |
| `scheduler.image.pullPolicy`      | scheduler镜像拉取策略                            | `IfNotPresent`                    |
| `scheduler.nodeSelector`          | scheduler节点选择器                              | `os=linux and arch=amd64`         |
| `scheduler.resources.requests`    | scheduler资源请求配额                            | `cpu: 100m`                       |
| `eksAdmission.replicaCount`       | eksAdmission副本数量                             | `1`                               |
| `eksAdmission.image.ref`          | eksAdmission运行时镜像                           | `eks-admission-controller:v0.1.0` |
| `eksAdmission.image.pullPolicy`   | eksAdmission镜像拉取策略                         | `IfNotPresent`                    |
| `eksAdmission.nodeSelector`       | eksAdmission节点选择器                           | `os=linux and arch=amd64`         |
| `eksAdmission.resources.requests` | eksAdmission资源请求配额                         | `cpu: "300m", memory: 300Mi`      |
| `eksAdmission.resources.limits`   | eksAdmission资源上限配额                         | `cpu: "500m", memory: 500Mi`      |

## 主要特性

1. Worklaod resilience特性控制开关分为全局开关和局部开关`AUTO_SCALE_EKS=true|false`, 用来控制本地的workload在`pending`的情况下是否弹性调度到腾讯云EKS
- 全局开关：`kubectl get cm -n kube-system eks-config` 中 `AUTO_SCALE_EKS`
- 局部开关：`spec.template.metadata.annotations['AUTO_SCALE_EKS']`


| 全局开关               | 局部开关               | 行为       |
| ---------------------- | ---------------------- | ---------- |
| `AUTO_SCALE_EKS=true`  | `AUTO_SCALE_EKS=false` | `调度成功` |
| `AUTO_SCALE_EKS=true`  | `未定义`               | `调度成功` |
| `AUTO_SCALE_EKS=true`  | `AUTO_SCALE_EKS=true`  | `调度成功` |
| `AUTO_SCALE_EKS=false` | `AUTO_SCALE_EKS=false` | `调度失败` |
| `AUTO_SCALE_EKS=false` | `未定义`               | `调度失败` |
| `AUTO_SCALE_EKS=false` | `AUTO_SCALE_EKS=true`  | `调度成功` |
| `未定义`               | `AUTO_SCALE_EKS=false` | `调度成功` |
| `未定义`               | `未定义`               | `调度成功` |
| `未定义`               | `AUTO_SCALE_EKS=true`  | `调度成功` |

2. 设定本地保留副本数量 `LOCAL_REPLICAS: N`

 - 当replicas大于N时，workload扩容到腾讯云EKS
 - 本地资源不足，但replicas小于N时，workload也可以扩容到腾讯云EKS

3. 优先缩容腾讯云EKS上的实例，此特性只在tke发行版k8s有效，社区版k8s会随机缩容workload
4. 当使用社区版k8s时候，需要在wokload中指定调度器为 `schedulerName: tke-scheduler`, 而tke发行版k8s则不需要指定调度器

## 测试用例

此用例yaml可以使用默认安装配置，`busybox` 的4个实例创建成功`running`, 其中3个在腾讯云EKS，1个在本地集群

1. 创建demo busybox deployment, 共4个`busybox`副本
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: busybox-deployment
  labels:
    app: busybox
spec:
  replicas: 4
  strategy: 
    type: RollingUpdate
  selector:
    matchLabels:
      app: busybox
  template:
    metadata:
      annotations:
        AUTO_SCALE_EKS: "true"
        LOCAL_REPLICAS: "1"
      labels:
        app: busybox
    spec:
      containers:
      - name: busybox
        image: busybox
        imagePullPolicy: IfNotPresent
        command: ['sh', '-c', 'echo Container 1 is Running ; sleep 3600']
```
2. 检查副本状态, 满足预期

```
root@VM-0-34-ubuntu:~/yamls# kubectl get po -o wide
NAME                                  READY   STATUS    RESTARTS   AGE   IP            NODE                    NOMINATED NODE   READINESS GATES
busybox-deployment-6cdfc4ffcb-4l6lz   1/1     Running   8          8h    172.30.0.35   eklet-subnet-bu17jw8a   <none>           <none>
busybox-deployment-6cdfc4ffcb-5dtnq   1/1     Running   8          8h    172.30.0.20   eklet-subnet-bu17jw8a   <none>           <none>
busybox-deployment-6cdfc4ffcb-b5c72   1/1     Running   8          8h    10.244.1.4    172.30.0.81             <none>           <none>
busybox-deployment-6cdfc4ffcb-h29wd   1/1     Running   8          8h    172.30.0.39   eklet-subnet-bu17jw8a   <none>           <none>
root@VM-0-34-ubuntu:~/yamls# 
```

