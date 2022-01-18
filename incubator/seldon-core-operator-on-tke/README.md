# seldon-core-operator

![Version: 1.12.0](https://img.shields.io/static/v1?label=Version&message=1.12.0&color=informational&style=flat-square)

Seldon Core CRD and controller helm chart for Kubernetes.

## 简介

[Seldon-Core-Operator](https://github.com/SeldonIO/seldon-core/tree/master/helm-charts/seldon-core-operator) 是 [SeldonIO](https://github.com/SeldonIO) 社区开发，用于在 Kubernetes 上大规模部署您的机器学习模型。

Seldon-Core 将您的 ML 模型（Tensorflow、Pytorch、H2o 等）或语言包装器（Python、Java 等）转换为生产 REST/GRPC 微服务。

Seldon 处理数千个生产机器学习模型的扩展，并提供开箱即用的高级机器学习功能，包括高级指标、请求日志、解释器、异常值检测器、A/B 测试、金丝雀等。是用于打包、部署、监控以及管理海量机器学习模型推理服务的 MLOps 框架。

## 部署

在通过 Helm 部署的过程中，所有的配置项都集中于 `values.yaml`。

面是部分较为可能需要自定义的字段：

| 参数值 | 类型 | 默认值 | 描述 |
|-----|------|---------|-------------|
| ambassador.enabled | bool | `true` |  如果你安装了 ambassador ，可以开启此选项 |
| ambassador.singleNamespace | bool | `false` |  设置为 true 暴露的 ambassador 端口受限于 seldon core 的 namespace |
| certManager.enabled | bool | `false` |  是否开启 certManager |
| controllerId | string | `""` |  如果你想确保 seldon-core-controller 只能看到指定命名空间，你可以设置 controllerId |
| crd.annotations | object | `{}` | 如果不是由管理器创建，则添加到 CRD 的注释 |
| crd.create | bool | `true` | 是否创建 crd |
| crd.forceV1 | bool | `false` | crd 是否强制使用 V1 版本 |
| crd.forceV1beta1 | bool | `false` |  crd 是否强制使用 V1beta1 |
| credentials.gcs.gcsCredentialFileName | string | `"gcloud-application-credentials.json"` |  gcs credential json 文件名 |
| credentials.s3.s3AccessKeyIDName | string | `"awsAccessKeyID"` | s3 access key |
| credentials.s3.s3SecretAccessKeyName | string | `"awsSecretAccessKey"` | s3 access secret |
| defaultUserID | string | `"8888"` |  默认用户的 id |
| engine.grpc.port | int | `5001` | engine 默认 grpc 端口 |
| engine.image.pullPolicy | string | `"IfNotPresent"` | engine 默认镜像拉取策略 |
| engine.image.registry | string | `"ccr.ccs.tencent.yun"` | 默认 engine 镜像拉取仓库地址 |
| engine.image.repository | string | `"tke-market/seldon-engine"` | 默认 engine 镜像名 |
| engine.image.tag | string | `"1.12.0"` | 默认 engine tag |
| engine.logMessagesExternally | bool | `false` |  导出日志文件 |
| engine.port | int | `8000` |  engine 的端口 |
| engine.prometheus.path | string | `"/prometheus"` | engine prometheus 的访问路径 |
| engine.resources.cpuLimit | string | `"500m"` | engine 的资源 cpu 限制 |
| engine.resources.cpuRequest | string | `"500m"` | engine 的资源 cpu 请求 |
| engine.resources.memoryLimit | string | `"512Mi"` | engine 的资源 memory 限制 |
| engine.resources.memoryRequest | string | `"512Mi"` | engine 的资源 memory 请求 |
| engine.serviceAccount.name | string | `"default"` | serviceaccount 的名字 |
| engine.user | int | `8888` | engine user id |
| executor.image.pullPolicy | string | `"IfNotPresent"` | executor 的镜像拉去策略 |
| executor.image.registry | string | `"ccr.ccs.tencent.yun"` | executor 的镜像仓库地址 |
| executor.image.repository | string | `"tke-market/seldon-core-executor"` | executor 的镜像仓库名称  |
| executor.image.tag | string | `"1.12.0"` | executor 的镜像 tag  |
| executor.metricsPortName | string | `"metrics"` | executor metrics 的 port 名称 |
| executor.port | int | `8000` | executor 的 port |
| executor.prometheus.path | string | `"/prometheus"` | executor prometheus 的访问路径 |
| executor.requestLogger.defaultEndpoint | string | `"http://default-broker"` | 自定义的 log 服务 url 端口,例如 ELK |
| executor.requestLogger.workQueueSize | int | `10000` | log request 的工作队列大小 |
| executor.requestLogger.writeTimeoutMs | int | `2000` | log request 时间超时，单位 ms |
| executor.resources.cpuLimit | string | `"500m"` | executor 的资源 cpu 限制  |
| executor.resources.cpuRequest | string | `"500m"` | executor 的资源 cpu 请求  |
| executor.resources.memoryLimit | string | `"512Mi"` | executor 的资源 memory 限制 |
| executor.resources.memoryRequest | string | `"512Mi"` | executor 的资源 memory 请求 |
| executor.serviceAccount.name | string | `"default"` | executor 的 serviceaccount 名称  |
| executor.user | int | `8888` | executor 的 user id |
| explainer.image | string | `"ccr.ccs.tencent.yun/tke-market/alibiexplainer:1.12.0"` | explainer 镜像 |
| explainer.image_v2 | string | `"ccr.ccs.tencent.yun/tke-market/mlserver:1.0.0.rc1-alibi-explain"` | explainer v2 镜像地址 |
| image.pullPolicy | string | `"IfNotPresent"` | seldon core operator 镜像拉取策略 |
| image.registry | string | `"ccr.ccs.tencent.yun"` | seldon core operator 镜像地址 |
| image.repository | string | `"ccr.ccs.tencent.yun/tke-market/seldon-core-operator"` | seldon core operator 镜像地址 |
| image.tag | string | `"1.12.0"` | seldon core operator 镜像 tag |
| istio.enabled | bool | `false` | 是否使用 istio |
| istio.gateway | string | `"istio-system/seldon-gateway"` | istio gateway 名称 |
| istio.tlsMode | string | `""` | istio tls 模式,例如 ISTIO_MUTUAL |
| keda.enabled | bool | `false` | 是否开启 keda |
| kubeflow | bool | `false` | 和 kubeflow 一起安装 |
| manager.annotations | object | `{}` | manager 的 annotations |
| manager.containerSecurityContext | object | `{}` | manager 的 containerSecurityContext |
| manager.cpuLimit | string | `"500m"` | seldon manager controller 的资源 cpu 限制  |
| manager.cpuRequest | string | `"100m"` | seldon manager controller 的资源 cpu 请求 |
| manager.deploymentNameAsPrefix | bool | `false` | 将 deployment 的名字作为 prefix |
| manager.leaderElectionID | string | `"a33bd623.machinelearning.seldon.io"` | leaderElectionID |
| manager.logLevel | string | `"INFO"` | log 级别 |
| manager.memoryLimit | string | `"300Mi"` | seldon manager controller 的资源 memory 限制 |
| manager.memoryRequest | string | `"200Mi"` | seldon manager controller 的资源 memory 请求 |
| managerCreateResources | bool | `false` | 如果设置为 true 则只会在 crd 不存在时 controller 创建会创建 crd |
| managerUserID | int | `8888` | seldon controller manager 的 user id  |
| namespaceOverride | string | `""` | released namespace |
| predictiveUnit.defaultEnvSecretRefName | string | `""` | seldon init container secret |
| predictiveUnit.grpcPort | int | `9500` | predictiveUnit 的 grpc 端口 |
| predictiveUnit.httpPort | int | `9000` | predictiveUnit 的 http 端口 |
| predictiveUnit.metricsPortName | string | `"metrics"` | predictiveUnit 的 metrics 端口名称 |
| predictor_servers.MLFLOW_SERVER.protocols.kfserving.defaultImageVersion | string | `"1.0.0.rc1-mlflow"` | kfserving v2 protocol for mlflow server 镜像地址 |
| predictor_servers.MLFLOW_SERVER.protocols.kfserving.image | string | `"ccr.ccs.tencent.yun/tke-market/mlserver"` | kfserving v2 protocol for mlflow server 镜像 tag |
| predictor_servers.MLFLOW_SERVER.protocols.seldon.defaultImageVersion | string | `"1.12.0"` | seldon protocol for mlflow server 镜像 tag |
| predictor_servers.MLFLOW_SERVER.protocols.seldon.image | string | `"ccr.ccs.tencent.yun/tke-market/mlflowserver"` | seldon protocol for mlflow server 镜像地址 |
| predictor_servers.SKLEARN_SERVER.protocols.kfserving.defaultImageVersion | string | `"1.0.0.rc1-sklearn"` |  |
| predictor_servers.SKLEARN_SERVER.protocols.kfserving.image | string | `"ccr.ccs.tencent.yun/tke-market/mlserver"` | kfserving v2 protocol for sklearn server 镜像地址 |
| predictor_servers.SKLEARN_SERVER.protocols.seldon.defaultImageVersion | string | `"1.12.0"` | seldon protocol for sklearn server 镜像 tag |
| predictor_servers.SKLEARN_SERVER.protocols.seldon.image | string | `"ccr.ccs.tencent.yun/tke-market/sklearnserver"` | seldon protocol for sklearn server 镜像地址 |
| predictor_servers.TEMPO_SERVER.protocols.kfserving.defaultImageVersion | string | `"1.0.0.rc1-slim"` | kfserving protocol for tempo server 镜像 tag |
| predictor_servers.TEMPO_SERVER.protocols.kfserving.image | string | `"ccr.ccs.tencent.yun/tke-market/mlserver"` | kfserving protocol for tempo server 镜像地址 |
| predictor_servers.TENSORFLOW_SERVER.protocols.seldon.defaultImageVersion | string | `"1.12.0"` | seldon protocol for tensorflow server 镜像 tag |
| predictor_servers.TENSORFLOW_SERVER.protocols.seldon.image | string | `"ccr.ccs.tencent.yun/tke-market/tfserving-proxy"` | seldon protocol for tensorflow server 镜像地址 |
| predictor_servers.TENSORFLOW_SERVER.protocols.tensorflow.defaultImageVersion | string | `"2.1.0"` | tensorflow protocol for tensorflow server 镜像 tag |
| predictor_servers.TENSORFLOW_SERVER.protocols.tensorflow.image | string | `"ccr.ccs.tencent.yun/tke-market/serving"` | tensorflow protocol for tensorflow server 镜像名称 |
| predictor_servers.TRITON_SERVER.protocols.kfserving.defaultImageVersion | string | `"21.08-py3"` | kfserving protocol for triton server 镜像 tag  |
| predictor_servers.TRITON_SERVER.protocols.kfserving.image | string | `"ccr.ccs.tencent.yun/tke-market/tritonserver"` | kfserving protocol for triton server 镜像名称 |
| predictor_servers.XGBOOST_SERVER.protocols.kfserving.defaultImageVersion | string | `"1.0.0.rc1-xgboost"` | kfserving protocol for xgboost server 镜像 tag |
| predictor_servers.XGBOOST_SERVER.protocols.kfserving.image | string | `"ccr.ccs.tencent.yun/tke-market/mlserver"` | kfserving protocol for xgboost server 镜像名称 |
| predictor_servers.XGBOOST_SERVER.protocols.seldon.defaultImageVersion | string | `"1.12.0"` | seldon protocol for xgboost server 镜像 tag |
| predictor_servers.XGBOOST_SERVER.protocols.seldon.image | string | `"ccr.ccs.tencent.yun/tke-market/xgboostserver"` | seldon protocol for xgboost server 镜像名称 |
| rbac.configmap.create | bool | `true` | 是否创建 rbac 的 configmap |
| rbac.create | bool | `true` | 是否创建 rbac  |
| serviceAccount.create | bool | `true` | 是否创建 serviceaccount |
| serviceAccount.name | string | `"seldon-manager"` | 创建 serviceaccount 的名称  |
| singleNamespace | bool | `false` | namespace  |
| storageInitializer.cpuLimit | string | `"1"` | storageInitializer 的资源 cpu 限制 |
| storageInitializer.cpuRequest | string | `"100m"` | storageInitializer 的资源 cpu 限制 |
| storageInitializer.image | string | `"ccr.ccs.tencent.yun/tke-market/rclone-storage-initializer:1.12.0"` | storageInitializer 的镜像地址  |
| storageInitializer.memoryLimit | string | `"1Gi"` | storageInitializer 的资源 memory 限制 |
| storageInitializer.memoryRequest | string | `"100Mi"` | storageInitializer 的资源 memory 请求 |
| usageMetrics.enabled | bool | `false` | 是否开启 metrics |
| webhook.port | int | `4443` | webhook 的 port |

## Seldon 使用

Seldon 使用请参考[官方文档](https://docs.seldon.io/projects/seldon-core/en/latest/index.html).