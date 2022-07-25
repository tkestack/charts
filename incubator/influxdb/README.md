# InfluxDB

[InfluxDB](https://www.influxdata.com/products/influxdb-overview/) is an open source time-series database designed to handle large write and read loads in real-time.

## TL;DR;

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/influxdb
```

## Introduction

This chart bootstraps a [influxdb](https://github.com/bitnami/bitnami-docker-influxdb) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

Bitnami charts can be used with [Kubeapps](https://kubeapps.com/) for deployment and management of Helm Charts in clusters.

## Prerequisites

- Kubernetes 1.12+
- Helm 2.12+ or Helm 3.0-beta3+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/influxdb
```

These commands deploy influxdb on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` statefulset:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release. Use the option `--purge` to delete all history too.

## Parameters

The following tables lists the configurable parameters of the InfluxDB chart and their default values.

| Parameter                                         | Description                                                                                                                                                                               | Default                                                 |
|---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| `global.imageRegistry`                            | Global Docker image registry                                                                                                                                                              | `nil`                                                   |
| `global.imagePullSecrets`                         | Global Docker registry secret names as an array                                                                                                                                           | `[]` (does not add image pull secrets to deployed pods) |
| `global.storageClass`                             | Global storage class for dynamic provisioning                                                                                                                                             | `nil`                                                   |
| `image.registry`                                  | InfluxDB image registry                                                                                                                                                                   | `docker.io`                                             |
| `image.repository`                                | InfluxDB image name                                                                                                                                                                       | `bitnami/influxdb`                                      |
| `image.tag`                                       | InfluxDB image tag                                                                                                                                                                        | `{TAG_NAME}`                                            |
| `image.pullPolicy`                                | InfluxDB image pull policy                                                                                                                                                                | `IfNotPresent`                                          |
| `image.pullSecrets`                               | Specify docker-registry secret names as an array                                                                                                                                          | `[]` (does not add image pull secrets to deployed pods) |
| `image.debug`                                     | Specify if debug logs should be enabled                                                                                                                                                   | `false`                                                 |
| `nameOverride`                                    | String to partially override influxdb.fullname template with a string (will prepend the release name)                                                                                     | `nil`                                                   |
| `fullnameOverride`                                | String to fully override influxdb.fullname template with a string                                                                                                                         | `nil`                                                   |
| `clusterDomain`                                   | Default Kubernetes cluster domain                                                                                                                                                         | `cluster.local`                                         |
| `architecture`                                    | InfluxDB architecture (`standalone` or `high-availability`)                                                                                                                               | `standalone`                                            |
| `database`                                        | Database to be created on first run                                                                                                                                                       | `my_database`                                           |
| `authEnabled`                                     | Enable/disable authentication                                                                                                                                                             | `true`                                                  |
| `adminUser.name`                                  | InfluxDB admin user name                                                                                                                                                                  | `admin`                                                 |
| `adminUser.pwd`                                   | InfluxDB admin user's password                                                                                                                                                            | `nil`                                                   |
| `adminUser.usePasswordFile`                       | Mount admin user's password as file instead of environment variable                                                                                                                       | `false`                                                 |
| `user.name`                                       | Name for InfluxDB user with 'admin' privileges on the db specified at `database`                                                                                                          | `nil`                                                   |
| `user.pwd`                                        | InfluxDB password for `user.name` user                                                                                                                                                    | `nil`                                                   |
| `user.usePasswordFile`                            | Mount `user.name` user's password as file instead of environment variable                                                                                                                 | `nil`                                                   |
| `readUser.name`                                   | Name for InfluxDB user with 'read' privileges on the db specified at `database`                                                                                                           | `nil`                                                   |
| `readUser.pwd`                                    | InfluxDB password for `readUser.name` user                                                                                                                                                | `nil`                                                   |
| `readUser.usePasswordFile`                        | Mount `readUser.name` user's password as file instead of environment variable                                                                                                             | `nil`                                                   |
| `writeUser.name`                                  | Name for InfluxDB user with 'write' privileges on the db specified at `database`                                                                                                          | `nil`                                                   |
| `writeUser.pwd`                                   | InfluxDB password for `writeUser.name` user                                                                                                                                               | `nil`                                                   |
| `writeUser.usePasswordFile`                       | Mount `writeUser.name` user's password as file instead of environment variable                                                                                                            | `nil`                                                   |
| `existingSecret`                                  | Name of existing Secret object with InfluxDB credentials (`adminUser.password`, `user.password`, `readUser.password`, and `writeUser.pwd` will be ignored and picked up from this secret) | `nil`                                                   |
| `influxdb.configuration`                          | Specify content for influxdb.conf                                                                                                                                                         | `nil (do not create influxdb.conf)`                     |
| `influxdb.existingConfiguration`                  | Name of existing ConfigMap object with the InfluxDB configuration (`influxdb.configuration` will be ignored).                                                                             | `nil`                                                   |
| `influxdb.initdbScripts`                          | Dictionary of initdb scripts                                                                                                                                                              | `nil`                                                   |
| `influxdb.initdbScriptsCM`                        | Name of existing ConfigMap object with the initdb scripts (`influxdb.initdbScripts` will be ignored).                                                                                     | `nil`                                                   |
| `influxdb.initdbScriptsSecret`                    | Secret with initdb scripts that contain sensitive information (Note: can be used with `initdbScriptsConfigMap` or `initdbScripts`).                                                       | `nil`                                                   |
| `influxdb.extraEnvVars`                           | Array containing extra env vars to configure InfluxDB                                                                                                                                     | `nil`                                                   |
| `influxdb.replicaCount`                           | The number of InfluxDB replicas to deploy                                                                                                                                                 | `1`                                                     |
| `influxdb.antiAffinity`                           | Pod anti-affinity policy                                                                                                                                                                  | `soft`                                                  |
| `influxdb.nodeAffinity`                           | Node affinity policy                                                                                                                                                                      | `{}` (The value is evaluated as a template)             |
| `influxdb.nodeSelector`                           | Node labels for pod assignment                                                                                                                                                            | `{}` (The value is evaluated as a template)             |
| `influxdb.tolerations`                            | Tolerations for pod assignment                                                                                                                                                            | `[]` (The value is evaluated as a template)             |
| `influxdb.securityContext.enabled`                | Enable security context for InfluxDB                                                                                                                                                      | `true`                                                  |
| `influxdb.securityContext.fsGroup`                | Group ID for the InfluxDB filesystem                                                                                                                                                      | `1001`                                                  |
| `influxdb.securityContext.runAsUser`              | User ID for the InfluxDB container                                                                                                                                                        | `1001`                                                  |
| `influxdb.resources`                              | The [resources] to allocate for container                                                                                                                                                 | `{}`                                                    |
| `influxdb.livenessProbe`                          | Liveness probe configuration for InfluxDB                                                                                                                                                 | `Check values.yaml file`                                |
| `influxdb.readinessProbe`                         | Readiness probe configuration for InfluxDB                                                                                                                                                | `Check values.yaml file`                                |
| `influxdb.containerPorts.http`                    | InfluxDB container HTTP port                                                                                                                                                              | `8086`                                                  |
| `influxdb.containerPorts.rpc`                     | InfluxDB container RPC port                                                                                                                                                               | `8088`                                                  |
| `influxdb.service.type`                           | Kubernetes service type (`ClusterIP`, `NodePort` or `LoadBalancer`)                                                                                                                       | `ClusterIP`                                             |
| `influxdb.service.port`                           | InfluxDB HTTP port                                                                                                                                                                        | `8086`                                                  |
| `influxdb.service.rpcPort`                        | InfluxDB RPC port                                                                                                                                                                         | `8088`                                                  |
| `influxdb.service.nodePorts.http`                 | Kubernetes HTTP node port                                                                                                                                                                 | `""`                                                    |
| `influxdb.service.nodePorts.rpc`                  | Kubernetes RPC node port                                                                                                                                                                  | `""`                                                    |
| `influxdb.service.annotations`                    | Annotations for InfluxDB service                                                                                                                                                          | `{}`                                                    |
| `influxdb.service.loadBalancerIP`                 | loadBalancerIP if service type is `LoadBalancer`                                                                                                                                          | `nil`                                                   |
| `influxdb.service.loadBalancerSourceRanges`       | Address that are allowed when service is LoadBalancer                                                                                                                                     | `[]`                                                    |
| `influxdb.service.clusterIP`                      | Static clusterIP or None for headless services                                                                                                                                            | `nil`                                                   |
| `relay.image.registry`                            | InfluxDB Relay image registry                                                                                                                                                             | `docker.io`                                             |
| `relay.image.repository`                          | InfluxDB Relay image name                                                                                                                                                                 | `bitnami/influxdb-relay`                                |
| `relay.image.tag`                                 | InfluxDB Relay image tag                                                                                                                                                                  | `{TAG_NAME}`                                            |
| `relay.image.pullPolicy`                          | InfluxDB Relay image pull policy                                                                                                                                                          | `IfNotPresent`                                          |
| `relay.image.pullSecrets`                         | Specify docker-registry secret names as an array                                                                                                                                          | `[]` (does not add image pull secrets to deployed pods) |
| `relay.configuration`                             | Specify content for relay.toml                                                                                                                                                            | `Check values.yaml file`                                |
| `relay.existingConfiguration`                     | Name of existing ConfigMap object with the InfluxDB Relay configuration (`relay.configuration` will be ignored).                                                                          | `nil`                                                   |
| `relay.replicaCount`                              | The number of InfluxDB Relay replicas to deploy                                                                                                                                           | `1`                                                     |
| `relay.antiAffinity`                              | Pod anti-affinity policy                                                                                                                                                                  | `soft`                                                  |
| `relay.nodeAffinity`                              | Node affinity policy                                                                                                                                                                      | `{}` (The value is evaluated as a template)             |
| `relay.nodeSelector`                              | Node labels for pod assignment                                                                                                                                                            | `{}` (The value is evaluated as a template)             |
| `relay.tolerations`                               | Tolerations for pod assignment                                                                                                                                                            | `[]` (The value is evaluated as a template)             |
| `relay.securityContext.enabled`                   | Enable security context for InfluxDB Relay                                                                                                                                                | `true`                                                  |
| `relay.securityContext.fsGroup`                   | Group ID for the InfluxDB Relay filesystem                                                                                                                                                | `1001`                                                  |
| `relay.securityContext.runAsUser`                 | User ID for the InfluxDB Relay container                                                                                                                                                  | `1001`                                                  |
| `relay.resources`                                 | The [resources] to allocate for container                                                                                                                                                 | `{}`                                                    |
| `relay.livenessProbe`                             | Liveness probe configuration for InfluxDB Relay                                                                                                                                           | `Check values.yaml file`                                |
| `relay.readinessProbe`                            | Readiness probe configuration for InfluxDB Relay                                                                                                                                          | `Check values.yaml file`                                |
| `relay.containerPorts.http`                       | InfluxDB Relay container HTTP port                                                                                                                                                        | `9096`                                                  |
| `relay.service.type`                              | Kubernetes service type (`ClusterIP`, `NodePort` or `LoadBalancer`)                                                                                                                       | `ClusterIP`                                             |
| `relay.service.port`                              | InfluxDB Relay HTTP port                                                                                                                                                                  | `9096`                                                  |
| `relay.service.nodePort`                          | Kubernetes HTTP node port                                                                                                                                                                 | `""`                                                    |
| `relay.service.annotations`                       | Annotations for InfluxDB Relay service                                                                                                                                                    | `{}`                                                    |
| `relay.service.loadBalancerIP`                    | loadBalancerIP if service type is `LoadBalancer`                                                                                                                                          | `nil`                                                   |
| `relay.service.loadBalancerSourceRanges`          | Address that are allowed when service is LoadBalancer                                                                                                                                     | `[]`                                                    |
| `relay.service.clusterIP`                         | Static clusterIP or None for headless services                                                                                                                                            | `nil`                                                   |
| `ingress.enabled`                                 | Enable ingress controller resource                                                                                                                                                        | `false`                                                 |
| `ingress.certManager`                             | Add annotations for cert-manager                                                                                                                                                          | `false`                                                 |
| `ingress.annotations`                             | Ingress annotations                                                                                                                                                                       | `[]`                                                    |
| `ingress.hosts[0].name`                           | Hostname for InfluxDB service                                                                                                                                                             | `influxdb.local`                                        |
| `ingress.hosts[0].path`                           | Path within the url structure                                                                                                                                                             | `/`                                                     |
| `ingress.tls[0].hosts[0]`                         | TLS hosts                                                                                                                                                                                 | `influxdb.local`                                        |
| `ingress.tls[0].secretName`                       | TLS Secret (certificates)                                                                                                                                                                 | `influxdb.local-tls`                                    |
| `ingress.secrets[0].name`                         | TLS Secret Name                                                                                                                                                                           | `nil`                                                   |
| `ingress.secrets[0].certificate`                  | TLS Secret Certificate                                                                                                                                                                    | `nil`                                                   |
| `ingress.secrets[0].key`                          | TLS Secret Key                                                                                                                                                                            | `nil`                                                   |
| `metrics.enabled`                                 | Enable the export of Prometheus metrics                                                                                                                                                   | `false`                                                 |
| `metrics.service.type`                            | Kubernetes service type (`ClusterIP`, `NodePort` or `LoadBalancer`)                                                                                                                       | `ClusterIP`                                             |
| `metrics.service.port`                            | InfluxDB Prometheus port                                                                                                                                                                  | `9122`                                                  |
| `metrics.service.nodePort`                        | Kubernetes HTTP node port                                                                                                                                                                 | `""`                                                    |
| `metrics.service.annotations`                     | Annotations for Prometheus metrics service                                                                                                                                                | `Check values.yaml file`                                |
| `metrics.service.loadBalancerIP`                  | loadBalancerIP if service type is `LoadBalancer`                                                                                                                                          | `nil`                                                   |
| `metrics.service.loadBalancerSourceRanges`        | Address that are allowed when service is LoadBalancer                                                                                                                                     | `[]`                                                    |
| `metrics.service.clusterIP`                       | Static clusterIP or None for headless services                                                                                                                                            | `nil`                                                   |
| `metrics.serviceMonitor.enabled`                  | if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)                                                                                    | `false`                                                 |
| `metrics.serviceMonitor.namespace`                | Namespace in which Prometheus is running                                                                                                                                                  | `nil`                                                   |
| `metrics.serviceMonitor.interval`                 | Interval at which metrics should be scraped.                                                                                                                                              | `nil` (Prometheus Operator default value)               |
| `metrics.serviceMonitor.scrapeTimeout`            | Timeout after which the scrape is ended                                                                                                                                                   | `nil` (Prometheus Operator default value)               |
| `metrics.serviceMonitor.selector`                 | Prometheus instance selector labels                                                                                                                                                       | `nil`                                                   |
| `networkPolicy.enabled`                           | Enable NetworkPolicy                                                                                                                                                                      | `false`                                                 |
| `networkPolicy.allowExternal`                     | Don't require client label for connections                                                                                                                                                | `true`                                                  |
| `persistence.enabled`                             | Enable data persistence                                                                                                                                                                   | `true`                                                  |
| `persistence.existingClaim`                       | Use a existing PVC which must be created manually before bound                                                                                                                            | `nil`                                                   |
| `persistence.storageClass`                        | Specify the `storageClass` used to provision the volume                                                                                                                                   | `nil`                                                   |
| `persistence.accessMode`                          | Access mode of data volume                                                                                                                                                                | `ReadWriteOnce`                                         |
| `persistence.size`                                | Size of data volume                                                                                                                                                                       | `8Gi`                                                   |
| `volumePermissions.enabled`                       | Enable init container that changes the owner and group of the persistent volume mountpoint to `runAsUser:fsGroup`                                                                         | `false`                                                 |
| `volumePermissions.image.registry`                | Init container volume-permissions image registry                                                                                                                                          | `docker.io`                                             |
| `volumePermissions.image.repository`              | Init container volume-permissions image name                                                                                                                                              | `bitnami/minideb`                                       |
| `volumePermissions.image.tag`                     | Init container volume-permissions image tag                                                                                                                                               | `buster`                                                |
| `volumePermissions.image.pullPolicy`              | Init container volume-permissions image pull policy                                                                                                                                       | `Always`                                                |
| `volumePermissions.image.pullSecrets`             | Specify docker-registry secret names as an array                                                                                                                                          | `[]` (does not add image pull secrets to deployed pods) |
| `volumePermissions.securityContext.runAsUser`     | User ID for the init container (when facing issues in OpenShift or uid unknown, try value "auto")                                                                                         | `0`                                                     |
| `backup.enabled`                                  | enable InfluxDB backup                                                                                                                                                                    | `false`                                                 |
| `backup.directory`                                | directory where backups are stored in                                                                                                                                                     | `"/backups"`                                            |
| `backup.retentionDays`                            | retention time in days for backups (older backups are deleted)                                                                                                                            | `10`                                                    |
| `backup.cronjob.schedule`                         | crontab style time schedule for backup execution                                                                                                                                          | `"0 2 * * *"`                                           |
| `backup.cronjob.historyLimit`                     | cronjob historylimit                                                                                                                                                                      | `1`                                                     |
| `backup.cronjob.annotations`                      | backup pod annotations                                                                                                                                                                    | `{}`                                                    |
| `backup.uploadProviders.google.enabled`           | enable upload to google storage bucket                                                                                                                                                    | `false`                                                 |
| `backup.uploadProviders.google.secret`            | json secret whith serviceaccount data to access Google storage bucket                                                                                                                     | `""`                                                    |
| `backup.uploadProviders.google.secretKey`         | service account secret key name                                                                                                                                                           | `"key.json"`                                            |
| `backup.uploadProviders.google.existingSecret`    | Name of existing secret object with Google serviceaccount json credentials                                                                                                                | `""`                                                    |
| `backup.uploadProviders.google.bucketName`        | google storage bucket name name                                                                                                                                                           | `"gs://bucket/influxdb"`                                |
| `backup.uploadProviders.google.image.registry`    | Google Cloud SDK image registry                                                                                                                                                           | `docker.io`                                             |
| `backup.uploadProviders.google.image.repository`  | Google Cloud SDK image name                                                                                                                                                               | `bitnami/google-cloud-sdk`                              |
| `backup.uploadProviders.google.image.tag`         | Google Cloud SDK image tag                                                                                                                                                                | `{TAG_NAME}`                                            |
| `backup.uploadProviders.google.image.pullPolicy`  | Google Cloud SDK image pull policy                                                                                                                                                        | `IfNotPresent`                                          |
| `backup.uploadProviders.google.image.pullSecrets` | Specify docker-registry secret names as an array                                                                                                                                          | `[]` (does not add image pull secrets to deployed pods) |
| `backup.uploadProviders.azure.enabled`            | enable upload to azure storage container                                                                                                                                                  | `false`                                                 |
| `backup.uploadProviders.azure.secret`             | secret whith credentials to access Azure storage                                                                                                                                          | `""`                                                    |
| `backup.uploadProviders.azure.secretKey`          | service account secret key name                                                                                                                                                           | `"connection-string"`                                   |
| `backup.uploadProviders.azure.existingSecret`     | Name of existing secret object                                                                                                                                                            | `""`                                                    |
| `backup.uploadProviders.azure.containerName`      | destination container                                                                                                                                                                     | `"influxdb-container"`                                  |
| `backup.uploadProviders.azure.image.registry`     | Azure CLI image registry                                                                                                                                                                  | `docker.io`                                             |
| `backup.uploadProviders.azure.image.repository`   | Azure CLI image name                                                                                                                                                                      | `bitnami/azure-cli`                                     |
| `backup.uploadProviders.azure.image.tag`          | Azure CLI image tag                                                                                                                                                                       | `{TAG_NAME}`                                            |
| `backup.uploadProviders.azure.image.pullPolicy`   | Azure CLI image pull policy                                                                                                                                                               | `IfNotPresent`                                          |
| `backup.uploadProviders.azure.image.pullSecrets`  | Specify docker-registry secret names as an array                                                                                                                                          | `[]` (does not add image pull secrets to deployed pods) |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install my-release \
  --set adminUser.name=admin-user bitnami/influxdb
```

The above command sets the InfluxDB admin user to `admin-user`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm install my-release -f values.yaml bitnami/influxdb
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### Production configuration and horizontal scaling

This chart includes a `values-production.yaml` file where you can find some parameters oriented to production configuration in comparison to the regular `values.yaml`. You can use this file instead of the default one.

- Use the `high-availability` architecture:

```diff
- architecture: standalone
+ architecture: high-availability
```

- Increase the number of InfluxDB and InfluxDB Relay replicas:

```diff
- influxdb.replicaCount: 1
+ influxdb.replicaCount: 3
- relay.replicaCount: 1 # were actually ignored in standalone architecture
+ relay.replicaCount: 2
```

- Enable Prometheus metrics:

```diff
- metrics.enabled: false
+ metrics.enabled: true
```

- Enable Newtworkpolicy blocking external access:

```diff
- networkPolicy.enabled: false
+ networkPolicy.enabled: true
- networkPolicy.allowExternal: true
+ networkPolicy.allowExternal: false
```

To horizontally scale this chart once it has been deployed (only available in the `high-availability` architecture), you can use the following parameters:

```console
influxdb.replicaCount=3
relay.replicaCount=2
```

## Standalone vs High Availability architecture

You can install the InfluxDB chart with two different architecture setups: "standalone" or "high-availability", you can use the `architecture` parameter:

```console
architecture="standalone"
architecture="high-availability"
```

The standalone architecture installs a deployment with one InfluxDB server (it cannot be scaled):

```
               ┌──────────────────┐
               │     Ingress      │
               │    Controller    │
               └────────┬─────────┘
                        |
                        │ /query
                        │ /write
                        ▼
                ┌────────────────┐
                │    InfluxDB    │
                |      svc       │
                └───────┬────────┘
                        │
                        ▼
                  ┌──────────┐
                  │ InfluxDB │
                  │  Server  │
                  │   Pod    │
                  └──────────┘
```

The high availability install a statefulset with N InfluxDB servers and M InfluxDB Relay instances:

```
               ┌──────────────────┐
               │     Ingress      │
               │    Controller    │
               └───────┬─┬────────┘
                       │ │
                       │ │
          ┌────────────┘ └─────────────┐
          │                            │
          │ /write              /query │
          ▼                            ▼
      ┌────────────────┐  ┌────────────────┐
      │ InfluxDB Relay │  │    InfluxDB    │
      │      svc       │  │      svc       │
      └───────┬─┬──────┘  └─────┬─┬────────┘
      ┌────── │─|───────────────|─│───────┐
      |       │ |               | │       ▼
┌─────┴────┐  │ |               | │  ┌──────────┐
│ InfluxDB │  │ |               | │  │ InfluxDB │
│  Relay   │◀─┘ |               | └─▶│  Server  │
│   Pod    │    │               │    │   Pod    │
└─────┬────┘    │               │    └──────────┘
      |         │               │           ▲
      └─────────│───────────────│─────┐     |
                │               │     |     |
  ┌──────────── │───────────────│───────────┘
  |             │               │     |
  |             │               │     ▼
┌─┴────────┐    │               │   ┌──────────┐
│ InfluxDB │    │               │   │ InfluxDB │
│  Relay   │◀───┘               └──▶│  Server  │
│   Pod    │                        │   Pod    │
└─────┬────┘                        └──────────┘
      |                                   ▲
      └───────────────────────────────────┘
```

### Configure the way how to expose InfluxDB

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster. Set `ingress.enabled=true` to expose InfluxDB through Ingress.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. Set `influxdb.service.type=ClusterIP` to choose this service type.
- **NodePort**: Exposes the service on each Node's IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`. Set `influxdb.service.type=NodePort` to choose this service type.
- **LoadBalancer**: Exposes the service externally using a cloud provider's load balancer. Set `influxdb.service.type=LoadBalancer` to choose this service type.

### Using custom configuration

This helm chart supports to customize the whole configuration file.

Add your custom configuration file to "files/conf" in your working directory. This file will be mounted as a configMap to the containers and it will be used for configuring InfluxDB.

Alternatively, you can specify the InfluxDB configuration using the `influxdb.configuration` parameter.

In addition to these options, you can also set an external ConfigMap with all the configuration files. This is done by setting the `influxdb.existingConfiguration` parameter. Note that this will override the two previous options.

### Adding extra environment variables

In case you want to add extra environment variables, you can use the `influxdb.extraEnvVars` property.

```yaml
extraEnvVars:
  - name: INFLUXDB_DATA_QUERY_LOG_ENABLED
    value: "true"
```

### Initialize a fresh instance

The [Bitnami InfluxDB](https://github.com/bitnami/bitnami-docker-influxdb) image allows you to use your custom scripts to initialize a fresh instance. In order to execute the scripts, they must be located inside the chart folder `files/docker-entrypoint-initdb.d` so they can be consumed as a ConfigMap.

Alternatively, you can specify custom scripts using the `influxdb.initdbScripts` parameter.

In addition to these options, you can also set an external ConfigMap with all the initialization scripts. This is done by setting the `influxdb.initdbScriptsCM` parameter. Note that this will override the two previous options. parameter.

The allowed extensions are `.sh`, and `.txt`.

## Persistence

The data is persisted by default using PVC(s). You can disable the persistence setting the `persistence.enabled` parameter to `false`.
A default `StorageClass` is needed in the Kubernetes cluster to dynamically provision the volumes. Specify another StorageClass in the `persistence.storageClass` or set `persistence.existingClaim` if you have already existing persistent volumes to use.

### Adjust permissions of persistent volume mountpoint

As the images run as non-root by default, it is necessary to adjust the ownership of the persistent volumes so that the containers can write data into it.

By default, the chart is configured to use Kubernetes Security Context to automatically change the ownership of the volume. However, this feature does not work in all Kubernetes distributions.
As an alternative, this chart supports using an initContainer to change the ownership of the volume before mounting it in the final destination.

You can enable this **initContainer** by setting `volumePermissions.enabled` to `true`.
There are K8s distribution, such as OpenShift, where you can dynamically define the UID to run this **initContainer**. To do so, set the `volumePermissions.securityContext.runAsUser` to `auto`.

## Upgrade

It's necessary to specify the existing passwords while performing an upgrade to ensure the secrets are not updated with invalid randomly generated passwords. Remember to specify the existing values of the `adminUser.pwd`, `user.pwd`, `readUser.pwd` and `writeUser.pwd` parameters when upgrading the chart:

```bash
$ helm upgrade my-release bitnami/influxdb \
    --set adminUser.pwd=[ADMIN_USER_PASSWORD] \
    --set user.pwd=[USER_PASSWORD] \
    --set readUser.pwd=[READ_USER_PASSWORD] \
    --set writeUser.pwd=[WRITE_USER_PASSWORD]
```

> Note: you need to substitute the placeholders _[ADMIN_USER_PASSWORD]_, _[USER_PASSWORD]_, _[READ_USER_PASSWORD]_, and _[WRITE_USER_PASSWORD]_ with the values obtained from instructions in the installation notes.
