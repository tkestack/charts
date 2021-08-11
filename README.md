# **TKEStack Charts** Helm Repository

## Overview

The `tkestack/charts` repository provides [Helm](https://github.com/kubernetes/helm) charts for use with TKE stack and [TKE Market](https://console.cloud.tencent.com/tke2/market).

This repository is organized as follows:

The `stable` and `incubator` directory contains Helm chart source provided by Tencent Cloud, while the `repo/stable` directory contains the packaged Helm chart binaries.  To add the stable repo to local repository list run the following command :
```
helm repo add stable https://raw.githubusercontent.com/tkestack/charts/master/repo/stable
```
