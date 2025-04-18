# dynamo

`tke-dynamo` 是用于在 TKE 上快速尝试 [dynamo](https://github.com/ai-dynamo/dynamo) 的 PD 分离部署。

## 架构说明

在 [dynamo](https://github.com/ai-dynamo/dynamo) 的部署逻辑中，一个典型的推理服务通常应该包括以下组件：
- **FrontEnd**：与 OpenAI 兼容的 HTTP 服务器，用于处理传入请求。
- **Processor**：处理请求，然后再将请求传递给 Worker。
- **Router**：根据指定策略将请求路由到适当的 Worker。
- **Worker**：处理实际的 LLM 推理（包括预填充和解码阶段）。

根据以上信息，`tke-dynamo` 使用 vLLM 作为下游推理引擎，将上述组件主要分为了以下两个 Deployment 进行部署。
- **frontend**：包含上述的 **FrontEnd**、**Processor**、**Router**，以及主要负责 LLM 推理中的解码阶段的 **VllmWorker**。
- **prefill-worker（可选）**：属于 **Worker** 组件，处理 LLM 推理中的预填充阶段。

## 配置说明

以下是主要可配置的参数及默认值：

### 依赖项配置

Chart 依赖以下服务：

| **依赖项** | **版本** | **默认启用** | **说明** |
| ---- | ---- | ---- | ---- |
| **etcd** | **11.2.1** | **true** | 分布式键值存储 |
| **nats** | **1.3.1** | **true** | 消息队列 |

依赖项的完整参数配置请参考：
- etcd: [https://github.com/bitnami/charts/tree/main/bitnami/etcd](https://github.com/bitnami/charts/tree/main/bitnami/etcd)
- nats: [https://github.com/nats-io/k8s/tree/main/helm/charts/nats](https://github.com/nats-io/k8s/tree/main/helm/charts/nats)

### 镜像配置
| Key               | Description                                                     | Default                                             |
|-------------------|-----------------------------------------------------------------|-----------------------------------------------------|
| image.repository  | Docker image repository for the Dynamo component.               | ccr.ccs.tencentyun.com/nack/dynamo                  |
| image.tag         | Tag version of the Dynamo Docker image.                         | 202504151804                                        |
| image.pullPolicy  | Image pull policy for Dynamo containers.                        | IfNotPresent                                        |
| imagePullSecrets  | Kubernetes secrets for authenticating private image registries. | []                                                  |

### Service 配置
| Key               | Description                                          | Default       |
|-------------------|------------------------------------------------------|---------------|
| service.type      | Network service type for the **frontend** component. | ClusterIP     |
| service.port      | Exposed port number of the **frontend** service.     | 80            |

### 模型 PVC 配置
| Key                | Description                                          | Default  |
|--------------------|------------------------------------------------------|----------|
| modelPVC.enable    | Controls whether to mount PVC to the LLM deployment. | true     |
| modelPVC.name      | Name of the Persistent Volume Claim (PVC).           | ai-model |
| modelPVC.mountPath | Mount path for the PVC in the LLM deployment.        | /data    |

### dynamo serve 配置信息
| Key                      | Description                                                    | Default           |
|--------------------------|----------------------------------------------------------------|-------------------|
| configs                  | Configuration parameters for `single` and `multinode.frontend` | See `values.yaml` |
| prefillConfigs           | Configuration parameters for `multinode.prefill-worker`        | See `values.yaml` |
| graphs."single.py"       | Graph definition file for `single` deployment mode             | See `values.yaml` |
| graphs."frontend.py"     | Graph definition file for `multinode.frontend` component       | See `values.yaml` |

### TKE RDMA 相关配置
| Key               | Description                                                                      | Default         |
|-------------------|----------------------------------------------------------------------------------|-----------------|
| rdma.enable       | Controls whether to enable RDMA support.                                         | true            |
| rdma.networkMode  | Network mode annotation to be added to Pod specifications.                       | tke-route-eni   |
| hostNetwork       | Controls whether to use hostNetwork (only effective when `rdma.enable` is true). | true            |

### 单节点部署相关配置
| Key                             | Description                                                         | Default                            |
|---------------------------------|---------------------------------------------------------------------|------------------------------------|
| single.enable                   | Controls whether to enable single-node deployment mode.             | true                               |
| single.metrics.enable           | Controls whether to expose metrics in single-node deployments.      | false                              |
| single.metrics.port             | Exposed port for metrics service.                                   | 9091                               |
| single.metrics.image.repository | Docker image repository for metrics component.                      | ccr.ccs.tencentyun.com/nack/dynamo |
| single.metrics.image.pullPolicy | Image pull policy for metrics containers.                           | IfNotPresent                       |
| single.metrics.image.tag        | Tag version of metrics component Docker image.                      | metrics-202504121542               |
| single.metrics.serviceMonitor   | Configuration for Prometheus ServiceMonitor integration.            | See `values.yaml`                  |
| single.labels                   | Extra labels to attach to single-node pods.                         | {}                                 |
| single.annotations              | Extra annotations to apply to single-node pods.                     | {}                                 |
| single.resources                | Resource allocation constraints for single-node deployments.        | See `values.yaml`                  |

### 多节点部署相关配置
| Key                               | Description                                                | Default                            |
|-----------------------------------|------------------------------------------------------------|------------------------------------|
| multinode.enable                  | Controls whether to enable multi-node deployment mode.     | true                               |
| multinode.replicas                | Number of replicas for `multinode.frontend` component.     | 1                                  |
| multinode.metrics.enable          | Controls whether to expose metrics in multi-node mode.     | false                              |
| multinode.metrics.port            | Exposed port for metrics service.                          | 9091                               |
| multinode.metrics.image.repository| Docker image repository for metrics component.             | ccr.ccs.tencentyun.com/nack/dynamo |
| multinode.metrics.image.pullPolicy| Image pull policy for metrics containers.                  | IfNotPresent                       |
| multinode.metrics.image.tag       | Tag version of metrics component Docker image.             | metrics-202504121542               |
| multinode.metrics.serviceMonitor  | Configuration for Prometheus ServiceMonitor integration.   | See `values.yaml`                  |
| multinode.labels                  | Extra labels to attach to multi-node pods.                 | {}                                 |
| multinode.annotations             | Extra annotations to apply to multi-node pods.             | {}                                 |
| multinode.resources               | Resource allocation for `multinode.frontend` containers.   | See `values.yaml`                  |
| multinode.prefill.replicas        | Number of `multinode.prefill-worker` replicas.             | 1                                  |
| multinode.prefill.resources       | Resource allocation for `multinode.prefill-worker` pods.   | See `values.yaml`                  |

## 示例

### 单节点 PD 分离

前提条件：
- 集群内存在一台 H20 * 8 的 GPU 机器，且已经开启了 RDMA。
- 已经下载好模型 neuralmagic/DeepSeek-R1-Distill-Llama-70B-FP8-dynamic 到名为 'ai-model' 的 PVC 的 /data 路径下。

使用以下命令可以快速拉取一个单节点 PD 分离的示例, 其中包含：
-  1 个使用 4 GPU 核心，负责解码阶段的 VllmWorker。
-  4 个使用 1 GPU 核心，负责预填充阶段的 PrefillWorker。

```bash
# 有开启 RDMA
helm install deepseek-r1-llama-70b . -f values.yaml

# 没有开启 RDMA
helm install deepseek-r1-llama-70b . -f values.yaml --set rdma.enable=false
```


### 多节点 PD 分离

前提条件：
- 集群内存在三台 H20 * 8 的 GPU 机器。
- 已经下载好模型 neuralmagic/DeepSeek-R1-Distill-Llama-70B-FP8-dynamic 到名为 'ai-model' 的 PVC 的 /data 路径下。

使用以下命令可以快速拉起一个多节点 PD 分离的示例，其中包含：
- **Node 1**: 1 个使用 4 GPU 核心，负责解码阶段的 VllmWorker；4 个使用 1 GPU 核心，负责预填充阶段的 PrefillWorker。
- **Node 2**: 8 个使用 1 GPU 核心的 PrefillWorker。
- **Node 3**: 8 个使用 1 GPU 核心的 PrefillWorker。

也就是说，在这个示例中我们一共拥有 24 个 GPU 核心，其中 4 个为 Decode Worker 使用，20 个为 Prefill Worker 使用。

```bash
# 开启了 RDMA
helm install deepseek-r1-llama-70b . -f multi-values.yaml

# 没有开启 RDMA
helm install deepseek-r1-llama-70b . -f multi-values.yaml --set rdma.enable=false
```
