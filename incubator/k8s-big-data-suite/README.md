```
 _   __ _____       ______  _         ______         _          
| | / /|  _  |      | ___ \(_)        |  _  \       | |         
| |/ /  \ V /  ___  | |_/ / _   __ _  | | | |  __ _ | |_   __ _ 
|    \  / _ \ / __| | ___ \| | / _` | | | | | / _` || __| / _` |
| |\  \| |_| |\__ \ | |_/ /| || (_| | | |/ / | (_| || |_ | (_| |
\_| \_/\_____/|___/ \____/ |_| \__, | |___/   \__,_| \__| \__,_|
                                __/ |                           
                               |___/                            
```

## 简介

K8sBigData 提供云原生的大数据解决方案, 包括
- 离线计算 (HDFS, Hive Spark)
- 流计算 (SparkStreaming, Flink)
- 实时计算, Ad-hoc (Kudu, Impala, Mist, Spark Thrift Server)
- 毫秒级响应查询 (ElasticSearch, HBase)
- 数据集成 (Kafka / kafka Connect)
- 可视化 (Superset, Zeppelin, Grafana, Kibana)
- 机器学习 (Coming soon ...)

## 优势

相比于 Github 分散的各个组件, 这是一套简洁, 预配置, 面向生产环境的方案, 表现在:
- 所有组件收拢到一个 Helm Chart, 可以实现一整套组件一键部署
- 组件直接默认已经打通, 例如 Impala => Hive, Kudu => Hive
- 经过生产环境打磨, 相对于开源版本进行了可用性优化
- 预置的监控/告警方案, 大多数组件有 Prometheus + Grafana 监控 (而开源版本的监控需要自己撸)
- 默认适配腾讯云

## 使用

和普通的 Helm 包使用方法无异，所有的配置项集中于 `values.yaml`


通用的规则:
`xxx.enabled` 代表是否开启 xxx 组件, 并不是所有组件都是默认开启.


下面是 `values.yaml` 字段:

| 参数                 | 描述                                                  | 默认值                                |
| ------------------------- | ------------------------------------------------------------ | -------------------------------------- |
| `imagePullSecrets`        | Docker 仓库拉取镜像密钥 | `qcloudregistrykey` |
| `defaultStorageClass`     | 默认的 StorageClass  | `cbs` |
| `ssdStorageClassEnabled`  | (腾讯云专属) 是否创建 ssd storage class | `false` |
| `cloudPremiumStorageClassEnabled`  | (腾讯云专属) 是否创建 高性能云盘 storage class | `false` |
| `ingressEnabled`          | 是否开启 Ingress (有一个 Ingress 收拢了多个组件的管理页面)         | `true` |
| `ingressType`             | Ingress 类型, 可为 NGINX/QCLOUD, 目前只能为 NGINX        | `NGINX` |
| `domain`                  | Ingress 域名       | `xxx.com` |
| `client.XXX`              | Client 是运维工具容器, 这里面有 hadoop,hive,spark-shell 等命令行, 并开放了 SSH 供远程调用 | `-` |
| `client.enabled`          | Client 是运维工具容器, 这里面有 hadoop,hive,spark-shell 等命令行, 并开放了 SSH 供远程调用 | `-` |
| `client.ssh.password`     | Client 容器 SSH 密码(默认用户名为 root) | `注意修改默认值` |
| `client.ssh.nodePort`     | Client 容器 SSH 端口, 请注意对 SSH 端口做安全组限制 | `31122` |
| `spark.zeppelin`     | Zeppelin 组件 | `开启` |
| `spark.zeppelin.persistence`     | Zeppelin PVC 配置 | `-` |
| `spark.history`     | Spark History | `开启` |
| `spark.thirftserver`     | Spark Thirft Server | `开启` |
| `zookeeper.XXX`     | Zookeeper 组件,  此为开源版本, 文档参考 [zookeeper](https://github.com/helm/charts/tree/master/incubator/zookeeper) | `开启` |
| `hive.XXX`     | Hive Meta store | `开启` |
| `kudu.XXX`     | Kudu 组件 | `开启` |
| `kudu.hiveMetastoreUris`     | Hive MetastoreUri, 不填默认连接内部 Hive Meta store,  如果连接外部需要手动指定 | `` |
| `kudu.tserver.replicas`     | Kudu tserver 副本数 | `3` |
| `kudu.tserver.memoryHardLimit`     | Kudu内存限制, 此为一项重要的配置, 默认值对于生产环境偏小, 注意调整, [参考](https://kudu.apache.org/docs/scaling_guide.html#_verifying_if_a_memory_limit_is_sufficient)  | `1610612736` |
| `kudu.tserver.storage`     | Kudu tserver 磁盘相关配置  | `` |
| `kudu.tserver.storage.count`     | Kudu 每个 tserver 磁盘个数  | `2` |
| `kudu.tserver.storage.size`     | Kudu tserver 磁盘大小  | `100Gi` |
| `kudu.tserver.storage.enableHostPath`     | Kudu tserver 是否使用宿主机磁盘(有助于降低成本) | false |
| `kudu.tserver.storage.hostPaths`     | Kudu tserver 宿主机目录列表 (enableHostPath为 true 时生效) | `[/ssd1/kudu_tserver, /ssd2/kudu_tserver]` |
| `impala.XXX`     | Impala 组件 | `开启` |
| `impala.kudu.enabled`  | Impala 是否添加对 Kudu 的支持, 即 --kudu_master_hosts 参数, 参考 [Using Apache Kudu with Apache Impala](https://kudu.apache.org/docs/kudu_impala_integration.html) | `true` |
| `impala.kudu.kuduMasters`  | Kudu Master 地址, 不填会自动生成连接内部Kudu集群, 如果连接外部 Kudu 集群需要手动指定 | `` |
| `sparkoperator.XXX`     | sparkoperator, [文档参考](https://github.com/GoogleCloudPlatform/spark-on-k8s-operator) | `开启` |
| `postgresql.XXX`     | Postgres 单实例版本, [文档参考](https://github.com/mapreducelab/bigdata-helm-charts/tree/develop/postgresql) | `开启` |
| `postgresql-ha.XXX`     | Postgres 高可用版本, [文档参考](https://hub.helm.sh/charts/bitnami/postgresql-ha) | `开启` |
| `hbase.XXX`     | HBase, [文档参考](https://github.com/warp-poke/hbase-helm), 经过裁剪, 只留下 HBase 部分 | `开启` |
| `elasticsearch.XXX`     | Elasticsearch, [文档参考](https://github.com/elastic/helm-charts/tree/master/elasticsearch) | `开启` |
| `kibana.XXX`     | Kibana, [文档参考](https://github.com/elastic/helm-charts/tree/master/kibana) | `开启` |
| `prometheus-operator.XXX`     | prometheus-operator, [文档参考](https://github.com/prometheus-operator/prometheus-operator) | `开启` |
| `prometheus-node-exporter.XXX`     | prometheus-node-exporter, [文档参考](https://github.com/prometheus/node_exporter/) | `开启` |
| `kube-state-metrics.XXX`     | kube-state-metrics, [文档参考](https://github.com/kubernetes/kube-state-metrics/) | `开启` |
| `grafana.XXX`     | grafana, [文档参考](https://github.com/helm/charts/tree/master/stable/grafana) | `开启` |
| `hadoop.XXX`     | Hadoop HDFS, 原始Helm(做了一些可用性优化), [文档参考](https://github.com/apache-spark-on-k8s/kubernetes-HDFS) | `开启` |
| `hadoop.global.dataNodeHostPath`     | Hadoop HDFS DataNode 磁盘目录列表, 注意此项根据实际主机磁盘目录修改 | `开启` |
| `volcano.XXX`     | volcano 调度, [文档参考](https://github.com/volcano-sh/volcano/tree/master/installer/helm/chart/volcano) | `不启动` |
| `flink-operator.XXX`     | flink-operator, [文档参考](https://github.com/GoogleCloudPlatform/flink-on-k8s-operator/blob/master/docs/user_guide.md) | `启动` |
| `flink-job-cluster.XXX`     | flink-job-cluster, 目前由于 flink-operator 自身的一些问题, flink-job-cluster 需要在部署完成时手动开启 | `不启动` |
| `cp-helm-charts.XXX`     | cp-helm-charts, Confluentinc Kafka 发行版  | `启动` |
| `airflow.XXX`     |  Airflow 定时调度组件, [文档参考](https://github.com/helm/charts/tree/master/stable/airflow)  | `启动` |
| `nginx-ingress.XXX` |  nginx-ingress, [文档参考](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) | `启动` |
| `nginx.XXX` | 反向代理, 不用额外的配置 | `启动` |
| `mist.XXX` | Mist 为 Spark serverless proxy 工具, [文档参考](https://github.com/Hydrospheredata/mist) | `启动` |
| `superset.XXX` | Superset, [文档参考](https://github.com/apache/incubator-superset/tree/master/helm/superset) | `启动` |

### 部署须知

- 默认 `values.yaml` 适配腾讯云, 适配其他环境建议新增 `values-xxx.yaml` 进行 patch
- 很多组件使用 PVC, PVC 配额需要根据业务需要进行调整
- 所有 Service 默认的 type 为 ClusterIP 以保证安全性, 需要 Service 设置为 NodePort 可以每个服务单独开启 (做好安全组限制)
- HDFS DataNode 使用宿主机磁盘, 需要指定至少三台主机打 Label: storage=true, HDFS DataNode 便会在这些宿主机上启动
    示例: kubectl label node xxx xxx xxx storage=true
- 自带 Prometheus/Grafana, 各个组件的监控已经在 Grafana 中预配置好了
- 一些组件需要反复重启数次(如 HDFS/HBase/Impala ...), 正常现象, 通常部署完成所需时间约为 10 分钟.


## 腾讯云最佳实践

核心组件为 HDFS / Hive / Kudu / Impala / Spark / Flink
其中 HDFS / Kudu 为存储层组件

HDFS 有多种部署方式, 这里使用了可用性验证比较好的 `DaemonSet` 方式部署
HDFS 部署必须使用宿主机 HostPath 磁盘, 结合 `腾讯云大数据D2机型` 的巨大本地盘可降低存储成本

Kudu 可使用 `PVC` 或者 `宿主机 HostPath` 作为存储, 如果数据量比较小, 使用默认的腾讯云高性能云盘作为PVC便可
如果大数据量想节约成本，建议考虑  `腾讯云高IOIT3机型`, 其提供了高性能SSD本地盘, 可以取得成本和性能的平衡
Kudu 可通过设置 `kudu.tserver.storage.enableHostPath`/`kudu.tserver.storage.hostPaths` 开启 HostPath 作为存储

Impala / Spark / Flink 没有特殊的机型需求, 可根据业务负载选择合适的 CPU/Memory 比例

为了提升稳定性, 可以为存储组件分配独立的节点, 使用 nodeSelector 做服务隔离部署

**请注意配置合适的安全组策略保证数据安全**
