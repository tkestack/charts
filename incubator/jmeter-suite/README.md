
# JMeter suit Chart

* This scheme provides the visualization interface of Grafana and the capacity of Influx storage

## 中文说明
https://cloud.tencent.com/developer/article/1757898

## Installing the Chart

To install the chart with the release name `my-release`:

```shell script
$ helm install my-release .
```



## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```shell script
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.



## Configuration

| Parameter                                 | Description                                   | Default                                                 |
|-------------------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `distributed-jmeter.enabled`              | Install distributed-jmeter or not             | `true`                                                  |
| `distributed-jmeter.server.replicaCount`  | The number of jmeter nodes you want to create | `3`                                                     |
| `distributed-jmeter.server.heap_size`     | Heap size of master node                      | `2g`                                                     |
| `distributed-jmeter.master.heap_size`     | Heap size of server node                      | `2g`                                                     |
| `grafana.enabled`                         | Install grafana for jmeter or not             | `true`                                                  |
| `influxdb.enabled`                        | Install influx db for jmeter or not           | `true`                                                  |
| `influxdb.persistence.enabled`            | Creat pvc or not                              | `true`                                                  |
| `influxdb.persistence.size`               | Size of influx db, must in [10, 32000]        | `20Gi`                                                  |



## Start test
To start test, you should run:
```shell script
$ sh start_test.sh your_test.jmx
```
You can get this script from: https://github.com/tkestack/charts/ in directory incubator/jmeter-suite or in stable/jmeter-suite


## Stop test
To stop test, you should run:
```shell script
$ sh stop_test.sh
```
You can get this script from: https://github.com/tkestack/charts/ in directory incubator/jmeter-suite or in stable/jmeter-suite


## View results
Get JMeter IP:
```shell script
$ kubectl get node -o wide | grep $(kubectl get pod -o wide | grep grafana | awk '{print $7}') | awk '{print $7}'
```

Result host:
```
http://$JMETER_IP:31221
```


## JMeter Backend Listener
In order to write JMeter data to influx DB, you should create a new backend listener in JMeter script as follows：

| Parameter                    | Value                                                               | Description                                             |
|------------------------------|---------------------------------------------------------------------|---------------------------------------------------------|
| `influxdbMetricsSender`      | `org.apache.jmeter.visualizers.backend.influxdb.HttpMetricsSender`  | Influx component for JMeter                             |
| `influxdbUrl`                | `http://jmeter-influxdb:8086/write?db=jmeter`                       | Influx DB host                                          |
| `measurement`                | `jmeter`                                                            | Measurement name                                        |
| `percentiles`                | `90;95;99`                                                          | Time consumption statistics                             |

JMeter backend listener:
```xml
        <BackendListener guiclass="BackendListenerGui" testclass="BackendListener" testname="Backend Listener" enabled="true">
          <elementProp name="arguments" elementType="Arguments" guiclass="ArgumentsPanel" testclass="Arguments" enabled="true">
            <collectionProp name="Arguments.arguments">
              <elementProp name="influxdbMetricsSender" elementType="Argument">
                <stringProp name="Argument.name">influxdbMetricsSender</stringProp>
                <stringProp name="Argument.value">org.apache.jmeter.visualizers.backend.influxdb.HttpMetricsSender</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="influxdbUrl" elementType="Argument">
                <stringProp name="Argument.name">influxdbUrl</stringProp>
                <stringProp name="Argument.value">http://jmeter-influxdb:8086/write?db=jmeter</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="application" elementType="Argument">
                <stringProp name="Argument.name">application</stringProp>
                <stringProp name="Argument.value">xxx</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="measurement" elementType="Argument">
                <stringProp name="Argument.name">measurement</stringProp>
                <stringProp name="Argument.value">jmeter</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="summaryOnly" elementType="Argument">
                <stringProp name="Argument.name">summaryOnly</stringProp>
                <stringProp name="Argument.value">false</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="samplersRegex" elementType="Argument">
                <stringProp name="Argument.name">samplersRegex</stringProp>
                <stringProp name="Argument.value">.*</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="percentiles" elementType="Argument">
                <stringProp name="Argument.name">percentiles</stringProp>
                <stringProp name="Argument.value">90;95;99</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
              <elementProp name="testTitle" elementType="Argument">
                <stringProp name="Argument.name">testTitle</stringProp>
                <stringProp name="Argument.value">xxxxx</stringProp>
                <stringProp name="Argument.metadata">=</stringProp>
              </elementProp>
            </collectionProp>
          </elementProp>
          <stringProp name="classname">org.apache.jmeter.visualizers.backend.influxdb.InfluxdbBackendListenerClient</stringProp>
        </BackendListener>
```
