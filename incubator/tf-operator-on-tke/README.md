## 简介

[TF-Operator](https://github.com/kubeflow/tf-operator) 是 [Kubeflow](https://www.kubeflow.org) 社区开发，用以支持在 Kubernetes 上部署执行 [TensorFlow](https://www.tensorflow.org) 分布式训练任务的组件。

在部署完成之后，用户可以创建、查看、删除 [TFJob](https://www.kubeflow.org/docs/components/training/tftraining/)。

*当前版本的 TF-Operator 依赖 Kubernetes 1.16+*

## 部署

在通过 Helm 部署的过程中，所有的配置项都集中于 `values.yaml`。

下面是部分较为可能需要自定义的字段：

| 参数     | 描述     | 默认值     |
| ------- | -------- | --------- |
| `image.repository` | TF-Operator 镜像所在仓库  | `ccr.ccs.tencentyun.com/kubeflow-oteam/tf-operator` |
| `image.tag`        | TF-Operator 镜像的版本    | `"latest"` |
| `namespace.create` | 是否为 TF-Operator 创建独立的命名空间 | `true` |
| `namespace.name`   | 部署 TF-Operator 的命名空间 | `"tf-operator"` |

## 最佳实践

`TF-Operator` 提供一个 PS/Worker 模式的分布式训练[案例](https://github.com/kubeflow/tf-operator/tree/master/examples/v1/dist-mnist)。

### 训练代码

[`dist_mnist.py`](https://github.com/kubeflow/tf-operator/blob/master/examples/v1/dist-mnist/dist_mnist.py)

### 训练镜像

镜像的制作过程非常简单。用户只需基于一个 TensorFlow （1.5.0） 的官方镜像，并将代码复制到镜像内，并配置好 `entrypoint` 即可。（如果不配置 entrypoint，用户也可以在提交 TFJob 的时配置启动命令。）

### 任务提交

准备一个 TFJob 的 [yaml 文件](https://raw.githubusercontent.com/kubeflow/tf-operator/master/examples/v1/dist-mnist/tf_job_mnist.yaml)：定义 2 个 PS 和 4 个 Worker。请注意，用户需要用上传后的训练镜像地址替换 `<训练镜像>` 所在占位。

```yaml
apiVersion: "kubeflow.org/v1"
kind: "TFJob"
metadata:
  name: "dist-mnist-for-e2e-test"
spec:
  tfReplicaSpecs:
    PS:
      replicas: 2
      restartPolicy: Never
      template:
        spec:
          containers:
            - name: tensorflow
              image: <训练镜像>
    Worker:
      replicas: 4
      restartPolicy: Never
      template:
        spec:
          containers:
            - name: tensorflow
              image: <训练镜像>
```

通过 `kubectl` 提交该 TFJob：

```shell
kubectl create -f ./tf_job_mnist.yaml
```