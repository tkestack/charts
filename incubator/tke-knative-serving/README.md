# Helm chart for knative serving

[![Latest Version](https://img.shields.io/github/release/softonic/knative-serving-chart.svg)](https://github.com/softonic/knative-serving-chart/releases)
[![Software License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/softonic/knative-serving-chart.svg)](http://isitmaintained.com/project/softonic/knative-serving-chart "Average time to resolve an issue")
![GitHub issues](https://img.shields.io/github/issues-raw/softonic/knative-serving-chart)

# Overview

With this chart you are going to install a serving component of Knative on a Kubernetes cluster. Following the knative-serving documentation.
[Knative install docs](https://knative.dev/docs/install/any-kubernetes-cluster/)

Knative v0.14.0 requires a Kubernetes cluster v1.15 or newer, as well as a compatible kubectl. 

# Prerequisites

* Istio
* Cert Manager >= 0.12
* Kubernetes >= v1.15

# How to install istio for tke cluster

TKE Service Mesh provides hosting istio services. Before deploying knative-serving, it is recommended to refer to the following methods to install istio and ingress (public network)/local (internal) gateway components for your TKE cluster.

* [install istio](https://console.cloud.tencent.com/tke2/mesh)

![install service mesh](https://github.com/tkestack/charts/raw/main/incubator/tke-knative-serving/img/install-istio.png)

* install ingress/local gateway components

![install service mesh](https://github.com/tkestack/charts/raw/main/incubator/tke-knative-serving/img/istio-components.png)


# Install

```bash
$ helm repo add softonic https://charts.softonic.io
$ helm install knative-serving softonic/knative-serving
```


## Configuration

All configuration settings are contained and described in
[values.yaml](values.yaml).

| Parameter | Description | Default |
| --- | --- | --- |
| `certmanager.enabled` | Setup the Webhook using cert-manager | `false` |
| `podDisruptionBudget.enabled` | Enables creation of a PodDisruptionBudget for corresponding deployment. | `false` |
| `podDisruptionBudget.minAvailable` | Sets the minimum number of pods to be available. Cannot be set at the same time as maxUnavailable. | `1` |
| `replicaCount` | Number of replicas to deploy. | `1` |
| `affinity` | Pod/Node affinity and anti-affinity | `{}` |
| `tolerations` | List of node taint tolerations. | `[]` |
| `nodeSelector` | Node labels for pod assignment. | `{}` |
| `resources` | CPU and memory limits for corresponding container. | `{}` |
| `priorityClassName` | The name of the priorityClass for the pods. | Unset |
| `lifecycle` | controller pod lifecycle hooks | `{}`
