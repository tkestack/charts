# 分布式推理压测

假设已经通过 service 的 load balancer 将推理服务暴露到了 `ip:port`，可以直接进入容器 llmbench 进行压测：

```console
root@6038401f73b7:/# cd app
root@6038401f73b7:/app# . ./vllm-venv/bin/activate
(vllm-venv) root@6038401f73b7:/app# HOST=<IP> PORT=<PORT> MODEL_NAME=deepseek-ai/DeepSeek-R1 sh ./vllm-bench.sh
......
============ Serving Benchmark Result ============
Successful requests:                     1000
Benchmark duration (s):                  183.87
Total input tokens:                      219171
Total generated tokens:                  175454
Request throughput (req/s):              5.44
Output token throughput (tok/s):         954.21
Total Token throughput (tok/s):          2146.18
---------------Time to First Token----------------
Mean TTFT (ms):                          18277.09
Median TTFT (ms):                        10917.11
P99 TTFT (ms):                           72117.97
-----Time per Output Token (excl. 1st token)------
Mean TPOT (ms):                          460.89
Median TPOT (ms):                        367.81
P99 TPOT (ms):                           2000.16
---------------Inter-token Latency----------------
Mean ITL (ms):                           314.17
Median ITL (ms):                         231.97
P99 ITL (ms):                            1007.60
==================================================
```

在 playbook 项目根目录下，创建 benchmark 的 job，注意 `serviceName` 和 `servicePort` 要对应上：

```console
$ helm install bench ./benchmark --set modelName=deepseek-ai/DeepSeek-R1-Distill-Qwen-32B --set serviceName=deepseek-r1-qwen-32b-dynamo --set servicePort=80
```
