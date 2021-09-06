# AIA IP controller Chart

Bind [anycast ip](https://config.tencent.com/product/aia) automatically when adding node in TKE cluster.
 
## Limitations

1. Your account has the permission to use Anycast IP.
2. The node is not bound with public IP.

## Parameters and Default Values

| Parameters                        | Description                                       | Default Values                            |
| --------------------------------- | ------------------------------------------------ | --------------------------------- |
| `config.region.shortName`          | Tencent cloud region short name                 | `hk`                              |
| `config.region.longName`           | Tencent cloud region long name                  | `ap-hongkong`                    |
| `config.credential.clusterID`      | Tencent cloud TKE cluster ID                    | ""                                |
| `config.credential.appID`          | Tencent cloud user app ID                      | ""                                |
| `config.credential.secretID`       | Tencent cloud API secret ID                    | ""                                |
| `config.credential.secretKey`      | Tencent cloud API secret key                   | ""                                |
| `config.aia.tags`                  | Extension label of aia                        | `k1: v1, ke: v2`                  |
| `config.aia.bandwidth`             | Bandwidth(Mbps) of aia                        | `100`                          |
| `config.node.labels`               | Label of node which needs to be bound aia     | `tke.cloud.tencent.com/need-aia-ip: 'true'`|
| `controller.replicaCount`          | Controller replica count                       | `2`                               |
| `controller.image.ref`             | Controller image                              | ""					|
| `controller.image.pullPolicy`      | Controller image pull policy                    | `Always`                    |
| `controller.resources.limits`      | Controller resources limits                      | `cpu: "1", memory: 1Gi`        |
| `controller.resources.requests`    | Controller resources requests 			| `cpu: "100m", memory: 50Mi`      |

## Installation and Verification

Prepare values.yaml，set region and credential content：

```yaml
# valuse.yaml
config:
  region:
    shortName: hk
    longName: ap-hongkong
  credential: # credential which has permission to access aia API
    clusterID: {your_cluster_ID} # tke cluster id
    appID: {your_app_ID}
    secretID: {your_secret_ID}
    secretKey: {your_secret_key}
#   aia:
#     tags: # Extension label of aia
#       k1: v1
#       k2: v2
#     bandwidth: 100 # Bandwidth(Mbps) of aia
#   node:
#     labels: # the node with these labels will be bound aia ip
#       tke.cloud.tencent.com/need-aia-ip: 'true'

# controller:
#   replicaCount: 2
#   image:
#     ref: "" # if your region is China mainland, set the value whith ccr.ccs.tencentyun.com/tkeimages/aia-ip-controller:v0.5.0, otherwise no need to modify it.
#     pullPolicy: Always
#   resources:
#     limits:
#       cpu: 1
#       memory: 1Gi
#     requests:
#       cpu: 100m
#       memory: 50Mi
```

Here we will deploy the controller in `kube-system` namespace, and the helm release name is `aia-ip-controller`, you can also use other namespace and name：

```sh
wget https://tke-release-1251707795.cos.ap-guangzhou.myqcloud.com/charts/aia-ip-controller-0.5.0.tgz
helm install aia-ip-controller -n kube-system -f values.yaml aia-ip-controller-0.5.0.tgz
```

After `aia-ip-controller` status is running, add node, do not bind public ip for this node, with label `tke.cloud.tencent.com/need-aia-ip: true`, this node will be bound with `aia` automatically。

## Uninstall

Here we will uninstall `aia-ip-controller` from `kube-system` namespace：

```sh
helm uninstall -n kube-system aia-ip-controller
```