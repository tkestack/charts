## 简介

tencent-opentelemetry-operator 由腾讯云可观测团队在社区 opentelemetry-operator 基础上构建，用于部署在 TKE 的应用快速接入[腾讯云应用性能监控 APM](https://cloud.tencent.com/product/apm)。目前 tencent-opentelemetry-operator 支持的编程语言包括 Java, Python, Node.js 和 .Net

*当前版本的 tencent-opentelemetry-operator 依赖 Kubernetes v1.19+

## 配置项说明

tencent-opentelemetry-operator 通过 Helm 部署安装，所有的配置项都集中于 `values.yaml`。

下述为安装 tencent-opentelemetry-operator 的必填字段：

| 参数                   | 描述                                   | 
|----------------------|--------------------------------------|
| `env.TKE_CLUSTER_ID` | TKE 集群 ID                            | 
| `env.TKE_REGION`     | TKE 集群所在地域                           |
| `env.ENDPOINT`       | APM 内网接入点，每个集群必须指定唯一的 APM 内网接入点      |
| `env.APM_TOKEN`      | 默认的 APM 业务系统 token，可以在工作负载级别指定其他业务系统 |
| `env.INTL_SITE`      | 仅国际站用户需设置为"true"                     |


由于配置项的填写比较复杂，强烈建议您前往[APM控制台](https://console.cloud.tencent.com/monitor/apm)安装 tencent-opentelemetry-operator，以简化安装步骤。点击**接入应用**，选择对应的语言，选择 OpenTelemetry 接入方式，点击**一键安装 Operator**，即可快速完成安装，无需手工填写参数。

安装完成以后，tencent-opentelemetry-operator 会创建 `opentelemetry-operator-system`命名空间，并创建相关 Kubernetes 资源。在需要接入 APM 的工作负载中添加相关 annotation，就可以实现探针自动注入，并向 APM 上报监控数据，请参考 APM 控制台**接入应用**对话框获取需要添加的 annotation 详细信息。在同一个 TKE 集群中，只能安装最多一个 tencent-opentelemetry-operator 。


