{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "client.fullname" -}}
{{- $name := default .Chart.Name .Values.client.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ssh.fullname" -}}
{{- $name := default .Chart.Name .Values.ssh.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "client.svc.domain" -}}
{{- printf "%s.svc.cluster.local" .Release.Namespace -}}
{{- end -}}

{{- define "client.zookeeper.quorum" -}}
{{- if .Values.global.zookeeperQuorumOverride -}}
{{- .Values.global.zookeeperQuorumOverride -}}
{{- else -}}
{{- $service := .Release.Name -}}
{{- $domain := include "client.svc.domain" . -}}
{{- $replicas := .Values.global.zookeeperQuorumSize | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "%s-%d.%s-zookeeper-headless.%s-zookeeper:2181," $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "%s-%d.%s-headless.%s:2181" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "client.hadoop.config.name" -}}
{{- if .Values.global.hadoopConfigNameOverride -}}
{{- printf "%s" .Values.global.hadoopConfigNameOverride -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "hadoop" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "client.hive.config.name" -}}
{{- if .Values.global.hiveConfigNameOverride -}}
{{- printf "%s" .Values.global.hiveConfigNameOverride -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "hive" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "client.hive.metastore.svc" -}}
{{- if .Values.global.hiveMetastoreSvcOverride -}}
{{- .Values.global.hiveMetastoreSvcOverride -}}
{{- else -}}
{{- $service := .Release.Name -}}
{{- $domain := include "client.svc.domain" . -}}
{{- $replicas := .Values.global.hiveMetastoreSize | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "thrift://%s-hive-metastore-%d.%s-hive-metastore-headless.%s:9083," $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "thrift://%s-hive-metastore-%d.%s-hive-metastore-headless.%s:9083" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "client.spark.config.eventLog.dir" -}}
{{- if not (index .Values "spark-defaults.conf" "spark.eventLog.dir") -}}
{{- printf "spark.eventLog.dir hdfs://%s-hadoop-hdfs-nn/spark-history" .Release.Name -}}
{{- end -}}
{{- end }}

{{- define "client.spark.defaults.config" -}}
{{- range $key, $value := index .Values "spark-defaults.conf" -}}
{{ $key }} {{ $value }}{{ printf "\n" }}
{{- end }}
{{- if not (index .Values "spark-defaults.conf" "spark.eventLog.dir") -}}
{{- printf "spark.eventLog.dir hdfs://%s-hadoop-hdfs-nn/spark-history\n" .Release.Name -}}
{{- end -}}
{{- if not (index .Values "spark-defaults.conf" "spark.history.fs.logDirectory") -}}
{{- printf "spark.history.fs.logDirectory hdfs://%s-hadoop-hdfs-nn/spark-history\n" .Release.Name -}}
{{- end -}}
{{- if not (index .Values "spark-defaults.conf" "spark.hadoop.hive.metastore.uris") -}}
{{- $service := include "client.hive.metastore.svc" . -}}
{{- printf "spark.hadoop.hive.metastore.uris %s\n" $service -}}
{{- end -}}
{{- end -}}
