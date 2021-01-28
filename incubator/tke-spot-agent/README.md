# Helm chart for tke-spot-agent

# Overview

With this chart you are going to install the tke-spot-agent. This agent can watch the spot instance metadata on ecah node. 
When the spot node will be deleted by cloud provider, the tke-spot-agent can catch the spot instance interuption metadata in advance(2 minutes), and
disable this node to prevent new pod to be scheduled to this node, and then drain the pod on this node.

# Prerequisites

* Kubernetes >= v1.11

## Configuration

All configuration settings are contained and described in
[values.yaml](tke-spot-agent/values.yaml).

| Parameter | Description | Default |
| --- | --- | --- |
| `env.DISABLE_ONLY` | If true, will disable the node only, will not drain the pod. | `false` |
| `env.DELETE_EMPTY_LOCAL_DIR` | If ture, will force to delete the pod with empty local dir. | `true` |
| `env.TAINT` | If true, will only taint the node and make the node as unschedulable, but don't drain the pod. | `false` |
