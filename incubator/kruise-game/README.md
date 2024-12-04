# Kruise Game v0.9.1

## Configuration

The following table lists the configurable parameters of the kruise-game chart and their default values.

| Parameter                        | Description                                                                 | Default                          |
|----------------------------------|-----------------------------------------------------------------------------|----------------------------------|
| `installation.namespace`         | Namespace for kruise-game operation installation                            | `kruise-game-system`             |
| `installation.createNamespace`   | Whether to create the installation.namespace                                | `true`                           |
| `kruiseGame.fullname`            | Nick name for kruise-game deployment and other configurations               | `kruise-game-controller-manager` |
| `kruiseGame.healthBindPort`      | Port for checking health of kruise-game container                           | `8082`                           |
| `kruiseGame.webhook.port`        | Port of webhook served by kruise-game container                             | `443`                            |
| `kruiseGame.webhook.targetPort`  | ObjectSelector for workloads in MutatingWebhookConfigurations               | `9876`                           |
| `kruiseGame.apiServerQps`        | Indicates the maximum QPS to the master from kruise-game-controller-manager | `5`                              |
| `kruiseGame.apiServerQpsBurst`   | Maximum burst for throttle of kruise-game-controller-manager                | `10`                             |
| `replicaCount`                   | Replicas of kruise-game deployment                                          | `1`                              |
| `image.repository`               | Repository for kruise-game image                                            | `ccr.ccs.tencentyun.com/tke-market/kruise-game-manager` |
| `image.tag`                      | Tag for kruise-game image                                                   | `v0.9.1`                         |
| `image.pullPolicy`               | ImagePullPolicy for kruise-game container                                   | `Always`                         |
| `serviceAccount.annotations`     | The annotations for serviceAccount of kruise-game                           | ` `                              |
| `service.port`                   | Port of kruise-game service                                                 | `8443`                           |
| `resources.limits.cpu`           | CPU resource limit of kruise-game container                                 | `500m`                           |
| `resources.limits.memory`        | Memory resource limit of kruise-game container                              | `1Gi`                            |
| `resources.requests.cpu`         | CPU resource request of kruise-game container                               | `10m`                            |
| `resources.requests.memory`      | Memory resource request of kruise-game container                            | `64Mi`                           |
| `prometheus.enabled`             | Whether to bind metric endpoint                                             | `true`                           |
| `prometheus.monitorService.port` | Port of the monitorservice bind to                                          | `8080`                           |
| `scale.service.port`             | Port of the external scaler server binds to                                 | `6000`                           |
| `scale.service.targetPort`       | TargetPort of the external scaler server binds to                           | `6000`                           |
| `network.totalWaitTime`          | Maximum time to wait for network ready, the unit is seconds                 | `60`                             |
| `network.probeIntervalTime`      | Time interval for detecting network status, the unit is seconds             | `5`                              |
| `cloudProvider.installCRD`       | Whether to install CloudProvider CRD                                        | `true`                           |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

### Optional: the local image for China

If you are in China and have problem to pull image from official DockerHub, you can use the registry hosted on Alibaba Cloud:

```bash
$ helm install kruise-game https://... --set image.repository=registry.cn-hangzhou.aliyuncs.com/acs/kruise-game-manager
...
```
