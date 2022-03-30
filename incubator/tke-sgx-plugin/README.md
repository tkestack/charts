# Helm chart for tke-sgx-plugin

# Overview

With this chart you are going to install the tke-sgx-plugin on tke. This operator is a control plane for running SGX device plugin on TKE. The SGX device plugin allows workloads to use Intel SGX on platforms with SGX Flexible Launch Control enabled. 
It is responsible for discovering and reporting SGX device nodes to kubelet. Containers requesting SGX resources in the cluster should not use the device plugins resources directly.
# Prerequisites

* Kubernetes >= v1.14

## Configuration

All configuration settings are contained and described in
[values.yaml](tke-sgx-plugin/values.yaml).
