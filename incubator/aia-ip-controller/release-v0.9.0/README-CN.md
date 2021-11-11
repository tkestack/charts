# AIA IP controller Chart

提供为TKE集群添加节点时自动绑定[anycast ip](https://config.tencent.com/product/aia)资源的能力。
 
## 使用前提

1. 账号已申请开通使用Anycast IP权限
2. 需要绑定的节点，未绑定公网IP

## 配置及默认值

| 参数                              | 描述                                             | 默认值                            |
| --------------------------------- | ------------------------------------------------ | --------------------------------- |
| `credential.clusterID`             | 腾讯云TKE集群ID                                  | ""                                |
| `credential.appID`                 | 腾讯云用户appID                                  | ""                                |
| `credential.secretID`              | 腾讯云API密钥SecretId                            | ""                                |
| `credential.secretKey`             | 腾讯云API密钥SecretKey                           | ""                                |
| `config.region.shortName`          | 腾讯云Region短名                                 | `hk`                              |
| `config.region.longName`           | 腾讯云Region长名                                 | `ap-hongkong`                    |
| `config.aia.tags`                  | 创建腾讯云aia资源时额外配置的label                  | ""			                  |
| `config.aia.bandwidth`             | 创建腾讯云aia资源时设置的带宽（Mbps）                | `100`                          |
| `config.aia.anycastZone`           | anycast资源所在区域	                       | `ANYCAST_ZONE_OVERSEAS`                          |
| `config.node.labels`               | 需要绑定aia ip节点识别label             		 | `tke.cloud.tencent.com/need-aia-ip: 'true'`|
| `controller.replicaCount`          | controller副本数量                               | `2`                               |
| `controller.image.ref`             | controller运行时镜像                              | ""					|
| `controller.image.pullPolicy`      | controller镜像拉取策略                             | `Always`                    |
| `controller.resources.limits`      | controller资源上限配额                         	  | `cpu: "1", memory: 1Gi`        |
| `controller.resources.requests`    | controller资源请求配额                         	  | `cpu: "100m", memory: 50Mi`      |

## 安装及验证

准备好values.yaml，重点关注region和credential内容：

```yaml
# valuse.yaml
credential: # 具备访问aia API的访问凭据
  clusterID: {your_cluster_ID} # tke集群id
  appID: {your_app_ID}
  secretID: {your_secret_ID}
  secretKey: {your_secret_key}

config:
  region: # 使用地域
    shortName: hk
    longName: ap-hongkong
```

这里以在`kube-system`命名空间以`aia-ip-controller`作为release name进行部署，用户也可根据自己需求更改为其他命名空间和名称：

```sh
wget https://tke-release-1251707795.cos.ap-guangzhou.myqcloud.com/charts/aia-ip-controller-0.9.0.tgz
helm install aia-ip-controller -n kube-system -f values.yaml aia-ip-controller-0.9.0.tgz
```

在观察到`aia-ip-controller` pod正常运行后在集群中添加节点时（注意不要绑定公网IP）添加label `tke.cloud.tencent.com/need-aia-ip: true`将自动创建`aia`资源绑定到改节点。

如果想设置更多的chart values，这里有一个例子：

```yaml
# valuse.yaml
credential: # 具备访问aia API的访问凭据
  clusterID: {your_cluster_ID} # tke集群id
  appID: {your_app_ID}
  secretID: {your_secret_ID}
  secretKey: {your_secret_key}

config:
  region: # 使用地域
    shortName: hk
    longName: ap-hongkong
  aia:
    tags: # 需要额外设置的aia资源标签
      k1: v1
      k2: v2
    bandwidth: 100 # 设置购买的aia ip带宽，单位Mbps
  node: # 只有打了如下label的节点才会触发aia ip controller处理绑定anycast ip
    labels:
      tke.cloud.tencent.com/need-aia-ip: 'true'

controller:
  replicaCount: 2
  image:
    ref: "" # 若在中国大陆地区使用请填写ccr.ccs.tencentyun.com/tkeimages/aia-ip-controller:v0.9.0，其他地区不用填写
    pullPolicy: Always
  resources:
    limits:
      cpu: 1
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 50Mi
```

## 卸载

这里以在`kube-system`命名空间以`aia-ip-controller`作为release name为例：

```sh
helm uninstall -n kube-system aia-ip-controller
```