# Helm chart for flink-on-tke

# Overview

With this chart you are going to install the flink-operator on tke. This operator is a control plane for running Apache Flink on TKE.
# Prerequisites

* Kubernetes >= v1.15

## Configuration

All configuration settings are contained and described in
[values.yaml](flink-on-tke/values.yaml).

| Parameter | Description | Default |
| --- | --- | --- |
| `env.DISABLE_ONLY` | If true, will disable the node only, will not drain the pod. | `false` |
| `env.DELETE_EMPTY_LOCAL_DIR` | If ture, will force to delete the pod with empty local dir. | `true` |
| `env.TAINT` | If true, will only taint the node and make the node as unschedulable, but don't drain the pod. | `false` |
