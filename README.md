# **TKEStack Charts** Helm Repository

## Overview

The `tkestack/charts` repository provides [Helm](https://github.com/kubernetes/helm) charts for use with TKE stack.

This repository is organized as follows:

The `stable` directory contains Helm chart source provided by IBM, while the `repo/stable` directory contains the packaged Helm chart binaries.  To add the stable repo to local repository list run the following command : 
```
helm repo add stable https://raw.githubusercontent.com/tkestack/charts/master/repo/stable
```
