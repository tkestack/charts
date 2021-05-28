## 简介

[MPI-Operator](https://github.com/kubeflow/mpi-operator) 是 [Kubeflow](https://www.kubeflow.org) 社区开发，用以支持以 [Horovod](https://horovod.ai) 为代表的数据并行分布式训练在 Kubernetes 集群上部署运行的组件。

在部署完成之后，用户可以创建、查看、删除 [MPIJob](https://github.com/kubeflow/mpi-operator/blob/master/pkg/apis/kubeflow/v1/types.go)。

*当前版本的 MPI-Operator 依赖 Kubernetes 1.16+*

## 部署

在通过 Helm 部署的过程中，所有的配置项都集中于 `values.yaml`。

下面是部分较为可能需要自定义的字段：

| 参数     | 描述     | 默认值     |
| ------- | -------- | --------- |
| `image.repository` | MPI-Operator 镜像所在仓库  | `ccr.ccs.tencentyun.com/kubeflow-oteam/mpi-operator` |
| `image.tag`        | MPI-Operator 镜像的版本    | `"latest"` |
| `namespace.create` | 是否为 MPI-Operator 创建独立的命名空间 | `true` |
| `namespace.name`   | 部署 MPI-Operator 的命名空间 | `"mpi-operator"` |

## 最佳实践

`MPI-Operator` 提供多个训练案例，我们以 Horovod Elastic 训练为例。

### 训练代码

[`tensorflow2_mnist_elastic.py`](https://github.com/horovod/horovod/blob/v0.20.0/examples/elastic/tensorflow2_mnist_elastic.py)

### 训练镜像

Horovod 官方提供的 `horovod/horovod:0.20.0-tf2.3.0-torch1.6.0-mxnet1.5.0-py3.7-cpu` 镜像中已经包含了该训练代码。

镜像仓库 `ccr.ccs.tencentyun.com/ti_containers/ti-tensorflow` 中内置了由腾讯优图实验室和机智团队合作开发的Ti-horovod，针对腾讯云网络环境特点进行了定制优化。

**标签（tag）**

* `1.15.2-gpu-cu100-py3`
* `2.0.0-gpu-cu100-py3`
* `2.1.0-gpu-cu101-py3`
* `2.4.0-gpu-cu112-py3`
* `2.4.0-gpu-cu113-py3`

***请注意：如果采用其他 Horovod 镜像作为基础镜像来制作训练镜像，请将训练代码复制至到镜像内；同时由于训练代码基于 TensorFlow 2.3.0 构建的，如果采用不同的 TensorFlow 版本，请注意 API 兼容性。***

### 任务提交

准备一个 MPIJob 的 [yaml 文件](https://raw.githubusercontent.com/kubeflow/mpi-operator/master/examples/horovod/tensorflow-mnist-elastic.yaml)：定义一个 Horovod Elastic 任务，至少需要 1 个 Worker，至多接受 3 个 Worker，一开始的时候创建 2 个 Worker。

```yaml
apiVersion: kubeflow.org/v1
kind: MPIJob
metadata:
  name: tensorflow-mnist-elastic
spec:
  slotsPerWorker: 1
  cleanPodPolicy: Running
  mpiReplicaSpecs:
    Launcher:
      replicas: 1
      template:
        spec:
          containers:
          - image: horovod/horovod:0.20.0-tf2.3.0-torch1.6.0-mxnet1.5.0-py3.7-cpu
            name: mpi-launcher
            command:
            - horovodrun
            args:
            - -np
            - "2"
            - --min-np
            - "1"
            - --max-np
            - "3"
            - --host-discovery-script
            - /etc/mpi/discover_hosts.sh
            - python
            - /examples/elastic/tensorflow2_mnist_elastic.py
            resources:
              limits:
                cpu: 1
                memory: 2Gi
    Worker:
      replicas: 2
      template:
        spec:
          containers:
          - image: horovod/horovod:0.20.0-tf2.3.0-torch1.6.0-mxnet1.5.0-py3.7-cpu
            name: mpi-worker
            resources:
              limits:
                cpu: 2
                memory: 4Gi
```

通过 `kubectl` 提交该 MPIJob：

```shell
kubectl create -f ./tensorflow-mnist-elastic.yaml
```

用户如果需要修改 Worker 的数量，可以通过 `kubectl edit` 或 `kubectl patch` 来修改该 MPIJob 的 `spec.mpiReplicaSpecs[Worker].replicas`。
