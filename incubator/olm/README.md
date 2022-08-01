<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Operator Lifecycle Manager Chart](#operator-lifecycle-manager-chart)
  - [OLM 组件定义](#olm-组件定义)
  - [安装 OLM](#安装-olm)
  - [卸载 OLM](#卸载-olm)
  - [配置及默认值](#配置及默认值)
  - [部署在集群内Kubernetes对象](#部署在集群内kubernetes对象)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Operator Lifecycle Manager Chart

OLM(Operator Lifecycle Manager) 作为 Operator Framework 的一部分，可以帮助用户进行 Operator 的自动安装，升级及其生命周期的管理。同时 OLM 自身也是以 Operator 的形式进行安装部署，可以说它的工作方式是以 Operators 来管理 Operators，而它面向 Operator 提供了声明式 (declarative) 的自动化管理能力也完全符合 Kubernetes 交互的设计理念。

## OLM 组件定义

OLM 自身是由两个 Operator 构成：OLM Operator 和 Catalog Operator。它们分别管理了如下几个的基础 CRD 模型：

| 资名称                | 简称   | 所属 Operator | 描述                                                                                                 |
| --------------------- | ------ | ------------- | ---------------------------------------------------------------------------------------------------- |
| ClusterServiceVersion | csv    | OLM           | 业务应用元数据，包括：应用名称，版本，图标，依赖资源，安装方式等                                     |
| InstallPlan           | ip     | Catalog       | 计算自动安装或升级csv过程中需要创建的资源集                                                          |
| CatalogSource         | catsrc | Catalog       | 用于定义应用的CSVs，CRDs，安装包的仓库                                                               |
| Subscription          | sub    | Catalog       | 通过跟踪安装包中的channel保证CSVs的版本更新                                                          |
| OperatorGroup         | og     | OLM           | 用于Operators安装过程中的多租户配置，可以定义一组目标namespaces指定创建Operators所需的RBAC等资源配置 |

## 安装 OLM

这里以版本`v0.17.0`为例，通过helm chart 安装 OLM

```bash
helm install olm ./olm -n kube-system
```

## 卸载 OLM

```bash
helm uninstall olm -n kube-system
```

## 配置及默认值

配置参数及其默认值:

| 参数                                | 描述                                        | 默认值                       |
| ----------------------------------- | ------------------------------------------- | ---------------------------- |
| `olm_namespace`                     | olm 与 catalog operator 运行的名字空间      | `operator-lifecycle-manager` |
| `olm.replicaCount`                  | olm controller 的副本数                     | `1`                          |
| `olm.resources.requests.cpu`        | olm controller 运行的CPU 使用上限           | `10m`                        |
| `olm.resources.requests.memory`     | olm controller  运行最小内存配额            | `160Mi`                      |
| `olm.image.ref`                     | olm controller 运行时镜像                   |                              |
| `olm.image.pullPolicy`              | olm controller 镜像拉取策略                 | `IfNotPresent`               |
| `catalog.replicaCount`              | catalog controller 的副本                   | `1`                          |
| `catalog.resources.requests.cpu`    | catalog controller 运行的CPU 使用上限       | `10m`                        |
| `catalog.resources.requests.memory` | catalog controller  运行最小内存配额        | `80Mi`                       |
| `catalog.image.ref`                 | catalog controller 运行时镜像               |                              |
| `catalog.image.pullPolicy`          | catalog controller 镜像拉取策略             | `IfNotPresent`               |
| `package.replicaCount`              | packageserver controller 的副本             | `1`                          |
| `package.resources.requests.cpu`    | packageserver controller 运行的CPU 使用上限 | `10m`                        |
| `package.resources.requests.memory` | packageserver controller  运行最小内存配额  | `50Mi`                       |
| `package.image.ref`                 | packageserver controller 运行时镜像         |                              |
| `package.image.pullPolicy`          | packageserver controller 镜像拉取策略       | `IfNotPresent`               |

## 部署在集群内Kubernetes对象

| Kubernetes 对象名称                             | 类型                     | 请求资源                                | 所属 Namespace             |
| ----------------------------------------------- | ------------------------ | --------------------------------------- | -------------------------- |
| catalogsources.operators.coreos.com             | CustomResourceDefinition |                                         |                            |
| clusterserviceversions.operators.coreos.com     | CustomResourceDefinition |                                         |                            |
| installplans.operators.coreos.com               | CustomResourceDefinition |                                         |                            |
| operatorgroups.operators.coreos.com             | CustomResourceDefinition |                                         |                            |
| operators.operators.coreos.com                  | CustomResourceDefinition |                                         |                            |
| subscriptions.operators.coreos.com              | CustomResourceDefinition |                                         |                            |
| olm-operator                                    | Deployment               | cpu request: 10m, memory request: 160Mi | operator-lifecycle-manager |
| catalog-operator                                | Deployment               | cpu request: 10m, memory request: 80Mi  | operator-lifecycle-manager |
| system:controller:operator-lifecycle-manager    | ClusterRole              |                                         |                            |
| aggregate-olm-view                              | ClusterRole              |                                         |                            |
| aggregate-olm-edit                              | ClusterRole              |                                         |                            |
| olm-operator-binding-operator-lifecycle-manager | ClusterRoleBinding       |                                         |                            |
| olm-operator                                    | ServiceAccount           |                                         | operator-lifecycle-manager |
| operators                                       | Namespace                |                                         |                            |
| operator-lifecycle-manager                      | Namespace                |                                         |                            |
| packageserver                                   | ClusterServiceVersion    |                                         | operator-lifecycle-manager |
| olm-operators                                   | OperatorGroup            |                                         | operator-lifecycle-manager |
| global-operators                                | OperatorGroup            |                                         | operators                  |
