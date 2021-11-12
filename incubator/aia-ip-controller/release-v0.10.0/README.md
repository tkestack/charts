# AIA IP controller Chart

Bind [anycast ip](https://config.tencent.com/product/aia) automatically when adding node in TKE cluster.
 
## Limitations

1. Your account has the permission to use Anycast IP.
2. The node is not bound with public IP.

## Parameters and Default Values

| Parameters                        | Description                                       | Default Values                            |
| --------------------------------- | ------------------------------------------------ | --------------------------------- |
| `credential.clusterID`             | Tencent cloud TKE cluster ID                    | ""                                |
| `credential.appID`                 | Tencent cloud user app ID                      | ""                                |
| `credential.secretID`              | Tencent cloud API secret ID                    | ""                                |
| `credential.secretKey`             | Tencent cloud API secret key                   | ""                                |
| `config.region.shortName`          | Tencent cloud region short name                 | `hk`                              |
| `config.region.longName`           | Tencent cloud region long name                  | `ap-hongkong`                    |
| `config.aia.tags`                  | Extension label of aia                        | ""		                  |
| `config.aia.bandwidth`             | Bandwidth(Mbps) of aia                        | `100`                          |
| `config.aia.anycastZone`           | Zone of anycast resource                       | `ANYCAST_ZONE_OVERSEAS` (`ANYCAST_ZONE_GLOBAL`: publish in global，need add white list to enable global acceleration，`ANYCAST_ZONE_OVERSEAS`: publish in overseas)|
| `config.node.labels`               | Label of node which needs to be bound aia     | `tke.cloud.tencent.com/need-aia-ip: 'true'`|
| `controller.replicaCount`          | Controller replica count                       | `2`                               |
| `controller.maxConcurrentReconcile` |the maximum number of concurrent Reconciles     | `1`                               |
| `controller.kubeApiQps`            |the maximum QPS                                | `20`                               |
| `controller.kubeApiBurst`          |maximum burst for throttle                      | `30`                               |
| `controller.image.ref`             | Controller image                              | ""					|
| `controller.image.pullPolicy`      | Controller image pull policy                    | `Always`                    |
| `controller.resources.limits`      | Controller resources limits                      | `cpu: "1", memory: 1Gi`        |
| `controller.resources.requests`    | Controller resources requests 			| `cpu: "100m", memory: 50Mi`      |

## Installation and Verification

Prepare values.yaml，set region and credential content：

```yaml
# valuse.yaml
credential: # credential which has permission to access aia API
  clusterID: {your_cluster_ID} # tke cluster id
  appID: {your_app_ID}
  secretID: {your_secret_ID}
  secretKey: {your_secret_key}

config:
  region:
    shortName: hk
    longName: ap-hongkong
```

Here we will deploy the controller in `kube-system` namespace, and the helm release name is `aia-ip-controller`, you can also use other namespace and name：

```sh
wget https://tke-release-1251707795.cos.ap-guangzhou.myqcloud.com/charts/aia-ip-controller-0.10.0.tgz
helm install aia-ip-controller -n kube-system -f values.yaml aia-ip-controller-0.10.0.tgz
```

After `aia-ip-controller` status is running, add node, do not bind public ip for this node, with label `tke.cloud.tencent.com/need-aia-ip: true`, this node will be bound with `aia` automatically。

If you want set more chart values, here is an example: 

```yaml
# valuse.yaml
credential: # credential which has permission to access aia API
  clusterID: '{your_cluster_ID}' # tke cluster id
  appID: '{your_app_ID}'
  secretID: '{your_secret_ID}'
  secretKey: '{your_secret_key}'

config:
  region:
    shortName: hk
    longName: ap-hongkong
  aia:
    tags: # Extension label of aia
      k1: v1
      k2: v2
    bandwidth: 100 # Bandwidth(Mbps) of aia
    anycastZone: ANYCAST_ZONE_OVERSEAS # ANYCAST_ZONE_OVERSEAS or ANYCAST_ZONE_GLOBAL 
  node:
    labels: # the node with these labels will be bound aia ip
      tke.cloud.tencent.com/need-aia-ip: 'true'

controller:
  maxConcurrentReconcile: 3
  kubeApiQps: 50
  kubeApiBurst: 100
  replicaCount: 2
  image:
    ref: "" # if your region is China mainland, set the value whith ccr.ccs.tencentyun.com/tkeimages/aia-ip-controller:v0.10.0, otherwise no need to modify it.
    pullPolicy: Always
  resources:
    limits:
      cpu: 1
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 50Mi
```

## Uninstall

Here we will uninstall `aia-ip-controller` from `kube-system` namespace：

```sh
helm uninstall -n kube-system aia-ip-controller
```