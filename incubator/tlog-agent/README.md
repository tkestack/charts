## 简介

tlog-agent是由腾讯云监控团队开发，用以支持在 Kubernetes 集群上快捷部署组件，采集pod中指定路径的日志。

在部署完成之后，用户可以在腾讯云控制台业务日志页面查看采集上来的日志。

*当前版本的 tlog-agent 依赖 Kubernetes 1.14+*

## 部署

在通过 Helm 部署的过程中，所有的配置项都集中于 `values.yaml`。

下面是部分需要自定义的字段：

| 参数              | 描述     |
|-----------------| -------- |
| `clusterID`     | 准备安装此应用的Kubernetes 集群ID |
| `region`        | 准备安装此应用的Kubernetes 集群所在地域 |
