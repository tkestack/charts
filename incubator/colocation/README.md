```
                     
```

# Helm chart for colocation-on-tke
## Overview
colocation-on-tke is a product to optimize kubernetes costs, which can improve kubernetes cluster resource utilization by co-locating  latency-critical applications such as long running online web services and best-effort applications such as spark offline jobs without interference online services;

### basic features

1. task classification, online , offline; different classes has different quality os service policy;
2. resource reuse, local resource predict;  offline reuse online resource by resource predict;
3. resource conflict coordination;  when online resource utilization spike, it will downsize offline resource to guarantee quality  of service(QoS)  of online services;

### advanced features
1. cgroup isolation
2. slo management
3. local monitor and alerting
4. cpi management
5. offline scheduler, coordinator
6. tencent bt kernel scheduler
7. application profile and remote vpa prophet predict
8. diskquota management
9. different qos cpu scheduler


## Prerequisites
1. lighthouse plugins
2. Kubernetes >= v1.11

## Components Description
colocation includes some services.
- caelus-agent
- offline-agent
- tke-scheduler
- tke-controller
- tke-coordinator
- prometheus
- grafana

## Parameter Description Default
