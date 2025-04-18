# model-fetch

`model-fetch` 的作用是在 TKE 下载 huggingface.co 或者 modelscope.cn 上的大模型。

## 配置说明

以下是主要可配置的参数及默认值：
| Key | Description | Default |
|-----|-------------|---------|
| pvcName | PVC name used to store the LLM model. | ai-model |
| storageClassName | Name of the storage class. | cfs-ai |
| storageSize | Storage capacity allocated to the PVC. | 100Gi |
| jobName | Name of the job for downloading the LLM model. | vllm-download-model |
| modelName | LLM model to be downloaded. | deepseek-ai/DeepSeek-R1-Distill-Qwen-7B |
| useModelscope | Source selection for model download (1=Modelscope, 0=HuggingFace). | 1 |

## 使用说明

首先需要在腾讯云控制台上创建 storage class，假设创建的 storage class 名为 `cfs-ai`。

执行如下命令可以创建绑定到 `cfs-ai` 的名为 `ai-model` 的PVC，并创建一个 job 用来拉取模型 `deepseek-ai/DeepSeek-R1-Distill-Qwen-7B`：

```bash
helm install model-fetch . -f values.yaml \
  --set modelName=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B \
  --set pvcName=ai-model \
  --set storageClassName=cfs-ai
```

可以通过查看 job 对应的 pod 的日志来看拉取进度：

```shell
$ kubectl logs -f vllm-download-model-pb2r8
Downloading [model-00004-of-000163.safetensors]:  16%|█▌        | 648M/4.01G [13:47<1:23:01, 727kB/s]
Downloading [model-00005-of-000163.safetensors]:  30%|██▉       | 1.19G/4.01G [13:48<1:01:25, 820kB/s]
Downloading [model-00001-of-000163.safetensors]:  20%|██        | 0.99G/4.87G [13:48<41:47, 1.66MB/s]
Downloading [model-00006-of-000163.safetensors]:  27%|██▋       | 1.11G/4.07G [13:47<30:32, 1.73MB/s]
Downloading [model-00007-of-000163.safetensors]:   7%|▋         | 274M/4.01G [00:58<10:11, 6.57MB/s]
Downloading [model-00003-of-000163.safetensors]:  45%|████▌     | 1.81G/4.01G [13:47<44:38, 879kB/s]
```
