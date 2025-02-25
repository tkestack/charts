# Kruise Rollout v0.6.0

## Configuration

The following table lists the configurable parameters of the kruise chart and their default values.

| Parameter                        | Description                                                       | Default                             |
|----------------------------------|-------------------------------------------------------------------|-------------------------------------|
| `installation.namespace`         | Namespace for kruise-rollout operation installation               | `kruise-rollout`                    |
| `installation.createNamespace`   | Whether to create the installation.namespace                      | `true`                              |
| `rollout.fullname`               | Nick name for kruise-rollout deployment and other configurations  | `kruise-rollout-controller-manager` |
| `rollout.featureGates`           | Feature gates for kruise-rollout, empty string means all disabled | `AdvancedDeployment=true`           |
| `rollout.healthBindPort`         | Port for checking health of kruise-rollout container              | `8081`                              |
| `rollout.metricsBindAddr`        | Port of metrics served by kruise-rollout container                | `127.0.0.1:8080`                    |
| `rollout.log.level`              | Log level that kruise-rollout printed                             | `4`                                 |
| `rollout.webhook.port`           | Port of webhook served by kruise-rollout container                | `9876`                              |
| `rollout.webhook.objectSelector` | ObjectSelector for workloads in MutatingWebhookConfigurations     | ` `                                 |
| `image.repository`               | Repository for kruise-rollout image                               | `ccr.ccs.tencentyun.com/tke-market/kruise-rollout`         |
| `image.tag`                      | Tag for kruise-rollout image                                      | `v0.6.0`                            |
| `image.pullPolicy`               | ImagePullPolicy for kruise-rollout container                      | `Always`                            |
| `imagePullSecrets`               | The list of image pull secrets for kruise-rollout image           | ` `                                 |
| `resources.limits.cpu`           | CPU resource limit of kruise-rollout container                    | `500m`                              |
| `resources.limits.memory`        | Memory resource limit of kruise-rollout container                 | `1Gi`                               |
| `resources.requests.cpu`         | CPU resource request of kruise-rollout container                  | `100m`                              |
| `resources.requests.memory`      | Memory resource request of kruise-rollout container               | `256Mi`                             |
| `replicaCount`                   | Replicas of kruise-rollout deployment                             | `2`                                 |
| `service.port`                   | Port of webhook served by kruise-rollout webhook service          | `443`                               |
| `serviceAccount.annotations`     | The annotations for serviceAccount of kruise-rollout              | ` `                                 |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

### Optional: feature-gate

Feature-gate controls some influential features in Kruise:

| Name                  | Description                                                                                            | Default  | Effect (if closed)                      |
|-----------------------|--------------------------------------------------------------------------------------------------------|----------|-----------------------------------------|
| `AdvancedDeployment`  | Whether to enable the ability to rolling update deployment in batches without extra canary deployment  | `true`   | advanced deployment controller disabled |

### Optional: the local image for China

If you are in China and have problem to pull image from official DockerHub, you can use the registry hosted on Alibaba Cloud:

```bash
$ helm install kruise https://... --set image.repository=ccr.ccs.tencentyun.com/tke-market/kruise-rollout
...
```
