# tke-extend-network-controller

![Version: 2.0.5](https://img.shields.io/badge/Version-2.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.0.5](https://img.shields.io/badge/AppVersion-2.0.5-informational?style=flat-square)

针对 TKE 集群一些特殊场景的的网络控制器。

## 支持房间类场景

目前主要支持会议、游戏战斗服等房间类场景的网络，即要求每个 Pod 都需要独立的公网地址，TKE 集群默认只支持 EIP 方案，但 EIP 资源有限，有申请的数量限制和每日申请的次数限制（参考 [EIP 配额限制](https://cloud.tencent.com/document/product/1199/41648#eip-.E9.85.8D.E9.A2.9D.E9.99.90.E5.88.B6)），稍微上点规模，或频繁扩缩容更换EIP，可能很容易触达限制导致 EIP 分配失败；而如果保留 EIP，在 EIP 没被绑定前，又会收取额外的闲置费。

> TKE Pod 绑定 EIP 参考 [Pod 绑 EIP](https://imroc.cc/tke/networking/pod-eip)。
>
> 关于 EIP 与 CLB 映射两种方案的详细对比参考 [TKE 游戏方案：房间类游戏网络接入](https://imroc.cc/tke/game/room-networking)。

如果不用 EIP，也可通过安装此插件来实现为每个 Pod 的指定端口都分配一个独立的公网地址映射 (公网 `IP:Port` 到内网 Pod `IP:Port` 的映射)。

## 前提条件

安装 `tke-extend-network-controller` 前请确保满足以下前提条件：
1. 确保腾讯云账号是带宽上移账号，参考 [账户类型说明](https://cloud.tencent.com/document/product/1199/49090) 进行判断或升级账号类型（如果账号创建的时间很早，有可能是传统账号）。
2. 创建了 [TKE](https://cloud.tencent.com/product/tke) 集群，且集群版本大于等于 1.26。
3. 集群中安装了 [cert-manager](https://cert-manager.io/docs/installation/) (webhook 依赖证书)，可通过 [TKE 应用市场](https://console.cloud.tencent.com/tke2/helm/market) 安装。
4. 需要一个腾讯云子账号的访问密钥(SecretID、SecretKey)，参考[子账号访问密钥管理](https://cloud.tencent.com/document/product/598/37140)，要求账号至少具有以下权限：
    ```json
    {
        "version": "2.0",
        "statement": [
            {
                "effect": "allow",
                "action": [
                    "clb:CreateLoadBalancer",
                    "clb:DeleteLoadBalancer",
                    "clb:DescribeLoadBalancers",
                    "clb:CreateListener",
                    "clb:DeleteListener",
                    "clb:DeleteLoadBalancerListeners",
                    "clb:DescribeListeners",
                    "clb:RegisterTargets",
                    "clb:BatchRegisterTargets",
                    "clb:DeregisterTargets",
                    "clb:BatchDeregisterTargets",
                    "clb:DescribeTargets",
                    "clb:DescribeQuota",
                    "clb:DescribeTaskStatus",
                    "vpc:DescribeAddresses"
                ],
                "resource": [
                    "*"
                ]
            }
        ]
    }
    ```

## 配置 values

以下是必要配置：

```yaml
vpcID: "" # TKE 集群所在 VPC ID (vpc-xxx)
region: "" # TKE 集群所在地域，如 ap-guangzhou
clusterID: "" # TKE 集群 ID (cls-xxx)
secretID: "" # 腾讯云子账号的 SecretID
secretKey: "" # 腾讯云子账号的 SecretKey
```

完整配置参考 [Values](#values)。

## 使用 CLB 端口池为 Pod 映射公网地址

参考 [这个文档](https://github.com/tkestack/tke-extend-network-controller/blob/main/docs/clb-port-pool.md)。

## Requirements

Kubernetes: `>= 1.26.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| clusterID | string | `""` | Cluster ID of the current TKE Cluster. |
| concurrency | object | `{"clbNodeBindingController":30,"clbPodBindingController":30,"clbPortPoolController":1,"dedicatedClbListenerController":30,"dedicatedClbServiceController":1,"nodeController":30,"podController":30}` | Concurrency options of the controller, in large-scale rapid expansion scenarios, the concurrency of the first 3 controllers can be appropriately increased (mainly by batch creating clb listeners and binding rs to speed up the process). |
| fullnameOverride | string | `""` |  |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"imroc/tke-extend-network-controller","tag":""}` | Image of the controller |
| image.pullPolicy | string | `"IfNotPresent"` | ImagePullPolicy of the controller |
| image.repository | string | `"ccr.ccs.tencentyun.com/tke-market/tke-extend-network-controller"` | Image repository of the controller |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | ImagePullSecrets of the controller |
| livenessProbe.httpGet.path | string | `"/healthz"` |  |
| livenessProbe.httpGet.port | int | `8081` |  |
| livenessProbe.initialDelaySeconds | int | `15` |  |
| livenessProbe.periodSeconds | int | `20` |  |
| log | object | `{"encoder":"json","level":"info"}` | Logging otpions of the controller |
| log.encoder | string | `"json"` | Log format of the controller, be one of 'json' or 'console' |
| log.level | string | `"info"` | Log level of the controller, be one of 'debug', 'info', 'error', or any integer value > 0 which corresponds to custom debug levels of increasing verbosity |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| readinessProbe.httpGet.path | string | `"/readyz"` |  |
| readinessProbe.httpGet.port | int | `8081` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| region | string | `""` | Region of the current TKE Cluster, optional. |
| replicaCount | int | `2` | Replica count of the controller pod |
| resources | object | `{}` |  |
| secretID | string | `""` | Secret ID of the Tencent Cloud Account. |
| secretKey | string | `""` | Secret Key of the Tencent Cloud Account. |
| tolerations | list | `[]` |  |
| vpcID | string | `""` | VPC ID of the current TKE Cluster. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
