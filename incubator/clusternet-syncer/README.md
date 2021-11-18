# Clusternet Syncer

## TL;DR

```console
helm install my-clusternet-syncer -n clusternet-system --create-namespace \
  clusternet-syncer
```

## Introduction

`clusternet-syncer` is responsible for

- Sync clusternet managed cluster status to tkestack managed cluster.
- Remove bootstrap token when child cluster registered.
- Clean up clusternet agent resources from child cluster when the child cluster deleted.

## Prerequisites

- Kubernetes 1.18+
- Helm 3.1.0

## Installing the Chart

To install the chart with the release name `my-syncer` and release namespace `clusternet-system`:

```console
helm install my-clusternet-syncer -n clusternet-system --create-namespace \
  clusternet-syncer
```

These commands deploy `clusternet-syncer` on the Kubernetes cluster in the default configuration.
The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list -A`

## Uninstalling the Chart

To uninstall/delete the `my-clusternet-syncer` deployment:

```console
helm delete my-clusternet-syncer -n clusternet-system
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Common parameters

| Name                | Description                                        | Value |
| ------------------- | -------------------------------------------------- | ----- |
| `kubeVersion`       | Override Kubernetes version                        | `""`  |
| `nameOverride`      | String to partially override common.names.fullname | `""`  |
| `fullnameOverride`  | String to fully override common.names.fullname     | `""`  |
| `commonLabels`      | Labels to add to all deployed objects              | `{}`  |
| `commonAnnotations` | Annotations to add to all deployed objects         | `{}`  |

### Exposure parameters

| Name                        | Description                                                                               | Value                          |
| --------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------ |
| `replicaCount`              | Specify number of clusternet-syncer replicas                                              | `1`                            |
| `serviceAccount.name`       | The name of the ServiceAccount to create                                                  | `"clusternet-syncer"`          |
| `livenessProbe`             | Specify a liveness probe                                                                  |                                |
| `readinessProbe`            | Specify a readiness probe                                                                 |                                |
| `image.registry`            | clusternet-syncer image registry                                                          | `quay.io`                      |
| `image.repository`          | clusternet-syncer image repository                                                        | `danielxlee/clusternet-syncer` |
| `image.tag`                 | clusternet-syncer image tag (immutable tags are recommended)                              | `v0.6.0`                       |
| `image.pullPolicy`          | clusternet-syncer image pull policy                                                       | `IfNotPresent`                 |
| `image.pullSecrets`         | Specify docker-registry secret names as an array                                          | `[]`                           |
| `extraArgs`                 | Additional command line arguments to pass to clusternet-syncer                            | `{"v":4}`                      |
| `resources.limits`          | The resources limits for the container                                                    | `{}`                           |
| `resources.requests`        | The requested resources for the container                                                 | `{}`                           |
| `nodeSelector`              | Node labels for pod assignment                                                            | `{}`                           |
| `priorityClassName`         | Set Priority Class Name to allow priority control over other pods                         | `""`                           |
| `tolerations`               | Tolerations for pod assignment                                                            | `[]`                           |
| `podAffinityPreset`         | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`       | `""`                           |
| `podAntiAffinityPreset`     | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`  | `soft`                         |
| `nodeAffinityPreset.type`   | Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `""`                           |
| `nodeAffinityPreset.key`    | Node label key to match. Ignored if `affinity` is set.                                    | `""`                           |
| `nodeAffinityPreset.values` | Node label values to match. Ignored if `affinity` is set.                                 | `[]`                           |
| `affinity`                  | Affinity for pod assignment                                                               | `{}`                           |
