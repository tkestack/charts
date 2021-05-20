## 简介

[PyTorch-Operator](https://github.com/kubeflow/pytorch-operator) 是 [Kubeflow](https://www.kubeflow.org) 社区开发，用以支持在 Kubernetes 上执行 [PyTorch](https://pytorch.org) DDP ([distributed data parallel](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html))模式分布式训练任务的组件。

在部署完成之后，用户可以创建、查看、删除 [PyTorchJob](https://www.kubeflow.org/docs/reference/pytorchjob/v1/pytorch/)。

*当前版本的 PyTorch-Operator 依赖 Kubernetes 1.16+*

## 部署

在通过 Helm 部署的过程中，所有的配置项都集中于 `values.yaml`。

下面是部分较为可能需要自定义的字段：

| 参数     | 描述     | 默认值     |
| ------- | -------- | --------- |
| `image.repository` | PyTorch-Operator 镜像所在仓库  | `ccr.ccs.tencentyun.com/kubeflow-oteam/pytorch-operator` |
| `image.tag`        | PyTorch-Operator 镜像的版本    | `"latest"` |
| `namespace.create` | 是否为 PyTorch-Operator 创建独立的命名空间 | `true` |
| `namespace.name`   | 部署 PyTorch-Operator 的命名空间 | `"pytorch-operator"` |

## 最佳实践

`PyTorch-Operator` 提供一个分布式训练[案例](https://github.com/kubeflow/pytorch-operator/tree/master/examples/mnist)。

### 训练代码

[`mnist.py`](https://raw.githubusercontent.com/kubeflow/pytorch-operator/master/examples/mnist/mnist.py)

### 训练镜像

训练镜像的制作过程非常简单。用户只需基于一个 PyTorch （1.0） 的官方镜像，将代码复制到镜像内，并配置好 `entrypoint` 即可。（如果不配置 entrypoint，用户也可以在提交 PyTorchJob 的时配置启动命令。）

***请注意：训练代码是基于 PyTorch 1.0 构建的，由于 PyTorch 在版本间可能存在 API 不兼容的问题，上述训练代码在其他版本的 PyTorch 环境下可能需要用户自行调整代码。***

### 任务提交

准备一个 PyTorchJob 的 [yaml 文件](https://raw.githubusercontent.com/kubeflow/pytorch-operator/master/examples/mnist/v1/pytorch_job_mnist_nccl.yaml)：定义 1 个 Master Worker 和 1 个 Worker。请注意，用户需要用上传后的训练镜像地址替换 `<训练镜像>` 所在占位。

```yaml
apiVersion: "kubeflow.org/v1"
kind: "PyTorchJob"
metadata:
  name: "pytorch-dist-mnist-nccl"
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      restartPolicy: OnFailure
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          containers:
            - name: pytorch
              image: <训练镜像>
              args: ["--backend", "nccl"]
              resources: 
                limits:
                  nvidia.com/gpu: 1
    Worker:
      replicas: 1
      restartPolicy: OnFailure
      template:
        metadata:
          annotations:
            sidecar.istio.io/inject: "false"
        spec:
          containers: 
            - name: pytorch
              image: <训练镜像>
              args: ["--backend", "nccl"]
              resources: 
                limits:
                  nvidia.com/gpu: 1
```

**请注意，由于在资源配置中设置了 GPU 资源，我们在 `args` 为训练配置的 `backend` 为 `"nccl"`；在没有使用 （Nvidia）GPU 的任务中，请使用其他（如 gloo）backend。**

通过 `kubectl` 提交该 PyTorchJob：

```shell
kubectl create -f ./pytorch_job_mnist_nccl.yaml
```