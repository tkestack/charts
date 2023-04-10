<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*


- [TKE Resilience Chart](#tke-resilience-chart)
  - [TKE Resilience Chart 组件定义](#tke-resilience-chart-组件定义)
  - [先决条件](#先决条件)
  - [安装 TKE Resilience Chart](#安装-tke-resilience-chart)
  - [卸载 TKE Resilience Chart](#卸载-tke-resilience-chart)
  - [配置及默认值](#配置及默认值)
  - [主要特性](#主要特性)
  - [地域与可用区](#地域与可用区)
  - [测试用例](#测试用例)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# TKE Resilience Chart
 
部署在IDC/私有云中的Kubernetes集群资源是有限的，随着用户workload数量和规模的不断增大，计算，网络，存储等资源最终会被消耗殆尽。TKE Resilience Chart利用腾讯公有云EKS服务，基于自定义的调度策略，通过添加虚拟节点的方式，将用户集群中的workload弹性上云，从而将用户集群的资源容量扩展到无限，并带来以下好处：

1. 用户IDC/私有云的硬件和维护成本保持不变
2. 实现了用户IDC/私有云和公有云级别的workload高可用
3. 用户对公有云的资源是按需使用，按需付费

## TKE Resilience Chart 组件定义

TKE Resilience Chart主要是由虚拟节点管理器，调度器，容忍控制器3部分组成，如下表格：

| 简称                 | 组件名称       | 描述                                                                 |
| -------------------- | -------------- | -------------------------------------------------------------------- |
| eklet                | 虚拟节点管理器 | 负责podsandbox生命周期的管理，并对外提供原生kubelet与节点相关的接口  |
| tke-scheduler        | 调度器         | 负责根据调度策略将workload弹性上云, 仅会安装在非tke发行版的k8s集群上 |
| admission-controller | 容忍控制器     | 负将处于 `pending` 状态的pod添加容忍，使其可以调度到虚拟节点上       |

## 先决条件
0. Kubernates `1.20` TKE发行版或者社区版集群Ready
1. 创建腾讯云 access secret id以及key，并且具备vpc产品的权限,具体接口列表如下
```
  {
  "version": "2.0",
  "statement": [
      {
          "effect": "allow",
          "resource": [
              "*"
          ],
          "action": [
              "vpc:DescribeSubnet"
          ]
      }
  ]
 }
```
2. 获取帐号信息appID，ownerUIN
3. 获取VPC信息 region，vpcID
4. 专线与腾讯云VPC内网链通
5. 用户集群API Server通过service将访问地址暴露出集群外，访问地址必须云VPC可达
6. 用户自有IDC需要部署EKS的集群可以访问公网，需要通过公网调用云API
7. 用户集群Pod IP必须与云VPC路由可达（使用Calico之类的基于BGP路由而不是SDN封装的CNI插件）

## 安装 TKE Resilience Chart

这里以 Chart 版本`v0.0.1`为例，通过helm chart安装

```bash
helm install tke-resilience --namespace kube-system ./tke-resilience --debug
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
| `cloud.subnets[0...N].id/zone`    | 腾讯云VPC子网ID/可用区英文名称，对应一个虚拟节点 | []                                |
| `eklet.waitSandboxRunningTimeout` | eklet等待Pod运行的超时时间                       | `24h`                             |
| `eklet.podUsedApiserver`          | eklet连接用户集群的API server地址，需VPC内网可达 | `https://172.1.2.3:6443`          |
| `eklet.replicaCount`              | eklet副本数量                                    | `1`                               |
| `eklet.image.ref`                 | eklet运行时镜像                                  | `eklet-amd64:v2.4.3`              |
| `eklet.image.pullPolicy`          | eklet镜像拉取策略                                | `IfNotPresent`                    |
| `eklet.service.type`              | eklet service类型                                | `NodePort`                        |
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

1. Workload resilience特性控制开关`AUTO_SCALE_EKS=true|false`分为全局开关和局部开关, 用来控制workload在`pending`的情况下是否弹性调度到腾讯云EKS，如下表格：

- 全局开关：`kubectl get cm -n kube-system eks-config` 中 `AUTO_SCALE_EKS`
- 局部开关：`spec.template.metadata.annotations['AUTO_SCALE_EKS']`,见[测试用例](#测试用例)

| 全局开关               | 局部开关               | 自动调度到eks       | LOCAL_REPLICAS 值是否生效 
| ---------------------- | ---------------------- | ---------- |-------------|
| `AUTO_SCALE_EKS=true`  | `AUTO_SCALE_EKS=false` | `调度失败` | `失效`        |
| `AUTO_SCALE_EKS=true`  | `未定义`               | `调度成功` | `局部值优先于全局值` |
| `AUTO_SCALE_EKS=true`  | `AUTO_SCALE_EKS=true`  | `调度成功` | `局部值优先于全局值` |
| `AUTO_SCALE_EKS=false` | `AUTO_SCALE_EKS=false` | `调度失败` | `失效`        |
| `AUTO_SCALE_EKS=false` | `未定义`               | `调度失败` | `失效`        |
| `AUTO_SCALE_EKS=false` | `AUTO_SCALE_EKS=true`  | `调度成功` | `局部值优先于全局值` |
| `未定义`               | `AUTO_SCALE_EKS=false` | `调度失败` | `失效`        |
| `未定义`               | `未定义`               | `调度成功` | `失效`        |
| `未定义`               | `AUTO_SCALE_EKS=true`  | `调度成功` | `局部值优先于全局值` |

2. 当使用社区版K8S的时候，需要在workload中指定调度器为 `tke-scheduler`, 而TKE发行版K8S则不需要指定调度器,见[测试用例](#测试用例)
3. Workload设定本地集群保留副本数量 `LOCAL_REPLICAS: N`, 见[测试用例](#测试用例)
4. Workload`扩容`
 - 当本地集群资源不足，并满足全局和局部开关中`调度成功`的行为设定，`pending`的workload将扩容到腾讯云EKS
 - 当实际创建workload副本数量达到N后，并满足全局和局部开关中`调度成功`的行为设定, `pending`的workload将扩容到腾讯云EKS
5. Workload`缩容`
 - TKE发行版K8S会优先缩容腾讯云EKS上的实例
 - 社区版K8S会随机缩容workload
6. 调度规则的限制条件
- 无法调度DaemonSet Pod到虚拟节点,此特性只在TKE发行版K8S有效，社区版K8S DaemonSet Pod会调度到虚拟节点，但会显示`DaemonsetForbidden`
- 无法调度 tke-eni-ip-webhook 命名空间下的Pod到虚拟节点
- 对 Volume 的限制
  - 仅支持 EmptyDir / PVC / Secret / NFS / ConfigMap / Downward API / HostPath / GitRepo / ISCSI / DownwardAPI / Projected / CSI / Ephemeral / PVC 类型的 Volume，其他的不支持 
  - 针对 PVC 类型对应的 Volume
    - 仅支持 NFS / CephFS / HostPath / 静态 cbs 类型的 PV，其他的不支持
    - 仅支持用户自定义 /cloud.tencent.com/qcloud-cbs / com.tencent.cloud.csi.cbs /  com.tencent.cloud.csi.cfs 类型的 Storageclass，其他的不支持
- 默认无法调度启用固定 IP 特性的pod到虚拟节点，可通过启动参数打开
- 对gpu的限制： 必须在annotation中指定 gpu-type字段，否则不支持
7. 虚拟节点支持自定义默认DNS配置：用户可以在虚拟节点上新增 `eks.tke.cloud.tencent.com/resolv-conf`的annotation后，生成的cxm子机里的/etc/resolv.conf就会被更新成用户定义的内容。注意会覆盖原来虚拟节点的dns配置,最终会以用户的配置为准。
```
eks.tke.cloud.tencent.com/resolv-conf: |  
   nameserver 4.4.4.4
   nameserver 8.8.8.8
```
 

## 地域与可用区

关于地域和可用区配置可参考：

```
https://cloud.tencent.com/document/product/215/20057
```

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
      #社区版K8S集群需要指定调度器
      schedulerName: tke-scheduler
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

