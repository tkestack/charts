# Kruise v1.7.2

## Configuration

The following table lists the configurable parameters of the kruise chart and their default values.

## setup parameters
| Parameter                                 | Description                                                  | Default                       |
| ----------------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| `featureGates`                            | Feature gates for Kruise, empty string means all enabled     | `""`                           |
| `installation.namespace`                  | Namespace for kruise installation                            | `kruise-system`               |
| `installation.createNamespace`            | Whether to create the installation.namespace                 | `true`                        |
| `installation.roleListGroups` | ApiGroups which kruise is permit to list, default set to be all | `*` |
| `crds.managed`                            | Kruise will not install CRDs with chart if this is false     | `true`                        |
| `imagePullSecrets`                        | The list of image pull secrets for kruise image              | `[]`                       |

#### manager parameters
| Parameter                                 | Description                                                  | Default                       |
| ----------------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| `manager.log.level`                       | Log level that kruise-manager printed                        | `4`                           |
| `manager.replicas`                        | Replicas of kruise-controller-manager deployment             | `2`                           |
| `manager.image.repository`                | Repository for kruise-manager image                          | `ccr.ccs.tencentyun.com/tke-market/kruise-manager`   |
| `manager.image.tag`                       | Tag for kruise-manager image                                 | `v1.7.2`                      |
| `manager.resources.limits.cpu`            | CPU resource limit of kruise-manager container               | `200m`                        |
| `manager.resources.limits.memory`         | Memory resource limit of kruise-manager container            | `512Mi`                       |
| `manager.resources.requests.cpu`          | CPU resource request of kruise-manager container             | `100m`                        |
| `manager.resources.requests.memory`       | Memory resource request of kruise-manager container          | `256Mi`                       |
| `manager.metrics.port`                    | Port of metrics served                                       | `8080`                        |
| `manager.webhook.port`                    | Port of webhook served                                       | `9443`                        |
| `manager.pprofAddr`                       | Address of pprof served                                      | `localhost:8090`              |
| `manager.nodeAffinity`                    | Node affinity policy for kruise-manager pod                  | `{}`                          |
| `manager.nodeSelector`                    | Node labels for kruise-manager pod                           | `{}`                          |
| `manager.tolerations`                     | Tolerations for kruise-manager pod                           | `[]`                          |
| `manager.resyncPeriod`                    | Resync period of informer kruise-manager, defaults no resync | `0`                           |
| `manager.hostNetwork`                     | Whether kruise-manager pod should run with hostnetwork       | `false`                       |
| `manager.loggingFormat`                   | Logging format, valid formats includes ` `(plain text), `json` | ` `                       |

#### daemon parameters
| Parameter                                 | Description                                                  | Default                       |
| ----------------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| `daemon.extraEnvs`                        | Extra environment variables that will be pass onto pods      | `[]`                          |
| `daemon.log.level`                        | Log level that kruise-daemon printed                         | `4`                           |
| `daemon.port`                             | Port of metrics and healthz that kruise-daemon served        | `10221`                       |
| `daemon.pprofAddr`                        | Address of pprof served                                      | `localhost:10222`             |
| `daemon.resources.limits.cpu`             | CPU resource limit of kruise-daemon container                | `50m`                         |
| `daemon.resources.limits.memory`          | Memory resource limit of kruise-daemon container             | `128Mi`                       |
| `daemon.resources.requests.cpu`           | CPU resource request of kruise-daemon container              | `0`                           |
| `daemon.resources.requests.memory`        | Memory resource request of kruise-daemon container           | `0`                           |
| `daemon.affinity`                         | Affinity policy for kruise-daemon pod                        | `{}`                          |
| `daemon.socketLocation`                   | Location of the container manager control socket             | `/var/run`                    |
| `daemon.socketFile`                       | Specify the socket file name in `socketLocation` (if you are not using containerd/docker/pouch/cri-o) | ` ` |
| `daemon.credentialProvider.enable`        | Whether to enable credential provider for image pull job     | `false`                       |
| `daemon.credentialProvider.hostPath`      | node dir of the credential provider plugin, kruise-daemon will mount the dir as a hostpath volume | `credential-provider-plugin` |
| `daemon.credentialProvider.configmap`     | configmap name of the credential provider in kruise-system ns  | `credential-provider-config`  |
| `daemon.credentialProvider.awsCredentialsDir`     | aws credentials dir if using AWS, for example: `/root/.aws`  | ` `  |

### other parameters
| Parameter                                 | Description                                                  | Default                       |
| ----------------------------------------- | ------------------------------------------------------------ | ----------------------------- |
| `enableKubeCacheMutationDetector`         | Whether to enable KUBE_CACHE_MUTATION_DETECTOR               | `false`                       |
| `webhookConfiguration.timeoutSeconds`     | The timeoutSeconds for all webhook configuration             | `30`                          |
| `serviceAccount.annotations`      | Annotations to patch for serviceAccounts | `{}` |
| `externalCerts.annotations`       | Annotations to patch for webhook configuration and crd when featuregate `EnableExternalCerts` is enabled. For example, `cert-manager.io/inject-ca-from: kruise-system/kruise-webhook-certs`. | `{}` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example, `helm install kruise https://... --set featureGates="AllAlpha=true"`.

### Optional: feature-gate

Feature-gate controls some influential features in Kruise:

| Name                                        | Description                                                                                                           | Default | Effect (if closed)                                                                                                |
|---------------------------------------------|-----------------------------------------------------------------------------------------------------------------------| ------- |-------------------------------------------------------------------------------------------------------------------|
| `PodWebhook`                                | Whether to open a webhook for Pod **create**                                                                          | `true`  | SidecarSet/KruisePodReadinessGate disabled                                                                        |
| `KruiseDaemon`                              | Whether to deploy `kruise-daemon` DaemonSet                                                                           | `true`  | ImagePulling/ContainerRecreateRequest disabled                                                                    |
| `DaemonWatchingPod`                         | Should each `kruise-daemon` watch pods on the same node                                                               | `true`  | For in-place update with same imageID or env from labels/annotations                                              |
| `CloneSetShortHash`                         | Enables CloneSet controller only set revision hash name to pod label                                                  | `false` | CloneSet name can not be longer than 54 characters                                                                |
| `KruisePodReadinessGate`                    | Enables Kruise webhook to inject 'KruisePodReady' readiness-gate to all Pods during creation                          | `false` | The readiness-gate will only be injected to Pods created by Kruise workloads                                      |
| `PreDownloadImageForInPlaceUpdate`          | Enables CloneSet controller to create ImagePullJobs to pre-download images for in-place update                        | `true` | No image pre-download for in-place update                                                                         |
| `CloneSetPartitionRollback`                 | Enables CloneSet controller to rollback Pods to currentRevision when number of updateRevision pods is bigger than (replicas - partition) | `false` | CloneSet will only update Pods to updateRevision                                                                  |
| `ResourcesDeletionProtection`               | Enables protection for resources deletion                                                                             | `true` | No protection for resources deletion                                                                              |
| `TemplateNoDefaults`                        | Whether to disable defaults injection for pod/pvc template in workloads                                               | `false` | Should not close this feature if it has open                                                                      |
| `PodUnavailableBudgetDeleteGate`            | Enables PodUnavailableBudget for pod deletion, eviction                                                               | `true` | No protection for pod deletion, eviction                                                                          |
| `PodUnavailableBudgetUpdateGate`            | Enables PodUnavailableBudget for pod.Spec update                                                                      | `false` | No protection for in-place update                                                                                 |
| `WorkloadSpread`                            | Enables WorkloadSpread to manage multi-domain and elastic deploy                                                      | `true` | WorkloadSpread disabled                                                                                           |
| `InPlaceUpdateEnvFromMetadata`              | Enables Kruise to in-place update a container in Pod when its env from labels/annotations changed and pod is in-place updating | `true` | Only container image can be in-place update                                                                       |
| `StatefulSetAutoDeletePVC`                  | Enables policies controlling deletion of PVCs created by a StatefulSet                                                | `true` | No deletion of PVCs by StatefulSet                                                                                |
| `PreDownloadImageForDaemonSetUpdate`        | Enables DaemonSet controller to create ImagePullJobs to pre-download images for in-place update                       | `false` | No image pre-download for in-place update                                                                         |
| `PodProbeMarkerGate`                        | Whether to turn on PodProbeMarker ability                                                                             | `true` | PodProbeMarker disabled                                                                                           |
| `SidecarSetPatchPodMetadataDefaultsAllowed` | Allow SidecarSet patch any annotations to Pod Object                                                                  | `false` | Annotations are not allowed to patch randomly and need to be configured via SidecarSet_PatchPodMetadata_WhiteList |
| `SidecarTerminator`                         | SidecarTerminator enables SidecarTerminator to stop sidecar containers when all main containers exited                | `false` | SidecarTerminator disabled                                                                                        |
| `CloneSetEventHandlerOptimization`          | CloneSetEventHandlerOptimization enable optimization for cloneset-controller to reduce the queuing frequency cased by pod update | `false` | optimization for cloneset-controller to reduce the queuing frequency cased by pod update disabled                 |
| `PreparingUpdateAsUpdate`                   | PreparingUpdateAsUpdate enable CloneSet/Advanced StatefulSet controller to regard preparing-update Pod as updated when calculating update/current revision during scaling. | `false` | Pods at preparing update state will be regarded as current revision instead of update revision                    |
| `ImagePullJobGate`                          | ImagePullJobGate enable imagepulljob-controller execute ImagePullJob | `false` | ImagePullJob and PreDownloadImageForInPlaceUpdate are disabled                                                    |
| `ResourceDistributionGate`                  | ResourceDistributionGate enable resourcedistribution-controller execute ResourceDistribution. | `false` | ResourceDistribution disabled                                                                                     |
| `DeletionProtectionForCRDCascadingGate`     | DeletionProtectionForCRDCascadingGate enable deletionProtection for crd Cascading | `false` | CustomResourceDefinition deletion protection disabled                                                             |
| `EnableExternalCerts`                       | Using certs generated externally, cert-manager e.g., for webhook server | `false` | kruise-manager will generate self-signed certs for webhook server |

If you want to configure the feature-gate, just set the parameter when install or upgrade. Such as:

```bash
$ helm install kruise https://... --set featureGates="ResourcesDeletionProtection=true\,PreDownloadImageForInPlaceUpdate=true"
...
```

If you want to enable all feature-gates, set the parameter as `featureGates=AllAlpha=true`.

### Optional: the local image for China

If you are in China and have problem to pull image from official DockerHub, you can use the registry hosted on Alibaba Cloud:

```bash
$ helm install kruise https://... --set  manager.image.repository=openkruise-registry.cn-hangzhou.cr.aliyuncs.com/openkruise/kruise-manager
...
```

### Optional: Support webhook CA injection using external certification management tool

Kruise needs certificates to enable mutating, validating and conversion webhooks. By default, kruise will generate self-signed certificates for webhook server.
If you want to use external certification management tool, e.g. cert-manager, you can follow these steps when install or upgrade:

1. Install external certification management tool, e.g. [cert-manager](https://cert-manager.io/docs/installation/helm/).
2. Create issuer and certificate resources if you have not done this before.
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: kruise-webhook-certs
  # consistent with installation.namespace
  namespace: kruise-system
spec:
  # where to store the certificates
  # cert-manager would generate a secret kruise-system/kruise-webhook-certs with the certificates
  # DO NOT CHANGE THE SECRET NAME SINCE KRUISE READ CERTS FROM THIS SECRET
  secretName: kruise-webhook-certs
  dnsNames:
  - kruise-webhook-service.kruise-system.svc
  - localhost
  issuerRef:
    name: selfsigned-kruise
    kind: Issuer
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-kruise
  namespace: kruise-system
spec:
  selfSigned: {}
```
3. During installation and upgrade, enable external certs support by setting featureGates=EnableExternalCerts=true and specify extra annotations that should be added to webhookconfiguration and CRD.
```
helm install kruise https://... --set featureGates="EnableExternalCerts=true" --set-json externalCerts.annotations='{"cert-manager.io/inject-ca-from":"kruise-system/kruise-webhook-certs"}'
```

Visit [CA Injector - cert manager](https://cert-manager.io/docs/concepts/ca-injector/) for more details.
