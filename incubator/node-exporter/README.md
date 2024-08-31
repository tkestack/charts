# Prometheus Node Exporter Helm chart

Prometheus exporter for hardware and OS metrics exposed by *NIX kernels, written in Go with pluggable metric collectors.

## Install Chart

```console
helm install [RELEASE_NAME] prometheus-community/prometheus-node-exporter
```

_See [configuration](#configuring) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] prometheus-community/prometheus-node-exporter --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._
## Configuring

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values prometheus-community/prometheus-node-exporter
```
