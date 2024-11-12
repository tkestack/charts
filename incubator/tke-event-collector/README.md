# TKE Event Collector

## Introduction

`tke-event-collector` is responsible for collect events of a k8s cluster and push the events to CLS for persistence.

## Prerequisites

- Helm 3.1.0+
- TKE Resilience v1.0.0+

## Installing the Chart

```console
helm -n kube-system install tke-event-collector ./tke-event-collector
```

## Uninstalling the Chart

To uninstall/delete the `tke-event-collector` deployment:

```console
helm -n kube-system uninstall tke-event-collector
```

## Parameters

| Name                | Description            | Value                                     |
| --------------------| -----------------------| ------------------------------------------|
| `replicas`          | 容器副本数               | 1                                         |
| `topicId`           | 事件上报的日志主题        | `5450c7b5-xxxx-xxxx-xxxx-xxxxxxxxxxxx`    |
| `clsHost`           | 事件上报服务器地址        | `ap-beijing.cls.tencentyun.com`           |
| `requestRegion`     | 事件上报地域             | `ap-beijing`                              |
| `clusterId`         | 集群 ID 标识            | `xxxx`                                    |
| `logLevel`          | 日志等级                | 5                                         |
| `imageTag`          | 容器镜像版本             | `v0.0.6`                                  |
| `imagePullPolicy`   | 容器镜像更新策略          | `IfNotPresent`                            |
