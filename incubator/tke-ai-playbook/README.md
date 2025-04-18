# TKE AI 脚本箱

## 项目概述
本项目提供基于 Kubernetes 的 AI 大模型相关脚本，包含模型下载、部署推理服务、性能测试等模块，提供在 TKE 一站式体验 AI 相关功能的能力。

### 前置依赖
1. Kubernetes 集群（建议版本 1.28+）
2. Helm 3.8.0+
3. 腾讯云 CFS 存储（或其他兼容的存储方案）
4. 可用的 GPU 机器（本项目中使用 3 * H20 节点）

### 功能

#### 模型下载

参考使用 [模型下载工具](./model-fetch/README.md) 下载模型到 CFS 存储中, 以便在推理服务部署过程中复用模型。

#### 部署推理服务

目前支持以下两种推理框架的快速体验：
- [AIBrix 部署](./aibrix/README.md): AIBrix 是在 2025 年 2 月开源的云原生大模型推理控制平面项目，专为优化大规模语言模型（LLM）的生产化部署设计。
- [Dynamo 部署](./tke-dynamo/README.md): Dynamo 是 NVIDIA 在 2025 年 GTC 大会上开源的推理框架，被设计用于在多节点分布式环境中为生成式人工智能和推理模型提供服务，支持多种推理引擎：包括 TRT-LLM、vLLM、SGLang 等等。

#### 推理服务性能压测脚本

- [LLM Benchmark](./benchmark/README.md)

#### 应用开发平台

- [Dify](./tke-dify/README.md): Dify 是一个开源的大模型应用开发平台。
