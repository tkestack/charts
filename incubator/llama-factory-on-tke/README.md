# llama-factory-on-tke

`llama-factory-on-tke` 是用于在 TKE 上快速部署 [LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory) 的 helm chart。

## 架构说明

[LLaMA-Factory](https://github.com/hiyouga/LLaMA-Factory) 是一个统一的大语言模型微调框架，支持多种模型的高效微调、推理和评估。在 TKE 部署中，`llama-factory-on-tke` 提供了以下功能：

- **Web UI**：提供友好的 Web 界面，用于单节点模型微调、推理和管理
- **API 服务**：提供 RESTful API 接口，支持程序化调用
- **GPU 支持**：原生支持 NVIDIA GPU 加速单节点训练和推理
- **模型管理**：支持多种预训练模型的加载和微调

该 Chart 将 LLaMA-Factory 部署为单个 Deployment，专注于单节点训练场景，同时暴露 Web UI 和 API 两个服务端口。

## 配置说明

以下是主要可配置的参数及默认值：

### 镜像配置
| Key               | Description                                                     | Default                                             |
|-------------------|-----------------------------------------------------------------|-----------------------------------------------------|
| image.repository  | Docker image repository for the LLaMA-Factory component.        | ccr.ccs.tencentyun.com/tke-market/llamafactory       |
| image.tag         | Tag version of the LLaMA-Factory Docker image.                  | v0.9.3-0924                                         |
| image.pullPolicy  | Image pull policy for LLaMA-Factory containers.                 | IfNotPresent                                        |
| imagePullSecrets  | Kubernetes secrets for authenticating private image registries. | []                                                  |

### Service 配置
| Key                | Description                                          | Default       |
|--------------------|------------------------------------------------------|---------------|
| service.type       | Network service type for the LLaMA-Factory service. | LoadBalancer  |
| service.portWebUi  | Exposed port number for the Web UI service.         | 7860          |
| service.portApi    | Exposed port number for the API service.            | 8000          |

### 资源配置
| Key                        | Description                                          | Default  |
|----------------------------|------------------------------------------------------|----------|
| resources.limits.cpu       | CPU resource limit.                                  | 4        |
| resources.limits.memory    | Memory resource limit.                               | 20Gi     |
| resources.limits.nvidia.com/gpu | GPU resource limit.                            | "1"      |
| resources.requests.cpu     | CPU resource request.                                | 2        |
| resources.requests.memory  | Memory resource request.                             | 10Gi     |
| resources.requests.nvidia.com/gpu | GPU resource request.                        | "1"      |

### 环境变量配置
| Key                | Description                                          | Default                  |
|--------------------|------------------------------------------------------|--------------------------|
| env[0].name        | Python package index URL environment variable name. | PIP_INDEX                |
| env[0].value       | Python package index URL.                           | https://pypi.org/simple  |
| env[1].name        | Extra features to install environment variable name.| EXTRAS                   |
| env[1].value       | Extra features to install (e.g., metrics).          | metrics                  |

### 启动命令配置
| Key     | Description                                    | Default                |
|---------|------------------------------------------------|------------------------|
| command | Container startup command.                     | ["bash", "-c"]         |
| args    | Container startup arguments.                   | ["llamafactory-cli webui"] |

### Ingress 配置
| Key              | Description                                          | Default |
|------------------|------------------------------------------------------|---------|
| ingress.enabled  | Controls whether to enable Ingress.                 | false   |
| ingress.className| Ingress class name.                                  | ""      |
| ingress.hosts    | Ingress host configuration.                          | See `values.yaml` |

**TKE Ingress 使用注意事项**：
- 如果集群网络模式未采用负载均衡直连 Pod 模式，后端服务的访问类型不能为 ClusterIP
- 建议使用 NodePort 或 LoadBalancer 类型的 Service
- 负载均衡直连 Pod 模式详见：[TKE 文档](https://cloud.tencent.com/document/product/457/41897)

**Ingress 配置示例**：
```yaml
ingress:
  enabled: true
  className: ""
  hosts:
    - host: llama-factory.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
service:
  type: NodePort  # 确保与 Ingress 兼容
```

## 示例

### 部署

使用自定义配置部署 LLaMA-Factory：

```bash
helm install llama-factory . -f values.yaml
```