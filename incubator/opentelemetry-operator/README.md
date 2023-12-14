## 简介

opentelemetry-operator是由腾讯云监控团队基于开源opentelemetry-operator，对TKE的容器环境进行单独适配，用以支持在 Kubernetes 集群上快捷部署组件，为集群中的pod自动添加特定的标签，开启探针注入能力。

在部署完成之后，用户可以在腾讯云控制台应用性能监控页面查看监控采集数据。

*当前版本的 tapm-operator 依赖 Kubernetes v1.19 to v1.28

## 部署

在通过 Helm 部署的过程中，所有的配置项都集中于 `values.yaml`。

下面是部分需要自定义的字段：

| 参数     | 描述     | 
| ------- | -------- |
| `env.CLUSTER_ID` | 准备安装此应用的Kubernetes 集群ID | 
| `env.TKE_REGION` | 准备安装此应用的Kubernetes 集群所在地域 |
| `env.APM_TOKEN` | 您的tapm实例对应的上报token |

