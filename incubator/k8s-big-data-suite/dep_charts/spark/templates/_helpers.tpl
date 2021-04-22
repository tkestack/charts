{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create fully qualified names.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "spark.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "history.fullname" -}}
{{- $name := default .Chart.Name .Values.history.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "thirftserver.fullname" -}}
{{- $name := default .Chart.Name .Values.thirftserver.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "thirftserver.master" -}}
{{- $name := default .Chart.Name .Values.thirftserver.master -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "zeppelin-fullname" -}}
{{- $name := default .Chart.Name .Values.zeppelin.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "zeppelin-master" -}}
{{- $name := default .Chart.Name .Values.zeppelin.master -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spark.hadoop.config.name" -}}
{{- if .Values.global.hadoopConfigNameOverride -}}
{{- printf "%s" .Values.global.hadoopConfigNameOverride -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "hadoop" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "spark.hive.config.name" -}}
{{- if .Values.global.hiveConfigNameOverride -}}
{{- printf "%s" .Values.global.hiveConfigNameOverride -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "hive" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "spark.history.opts" -}}
{{- if .Values.sparkHistoryOpts -}}
{{- printf "%s" .Values.sparkHistoryOpts -}}
{{- else -}}
{{- printf "-Dspark.history.ui.port=18080 -Dspark.history.retainedApplications=10 -Dspark.history.fs.logDirectory=hdfs://%s-hadoop-hdfs-nn/spark-history -Dfile.encoding=UTF-8" .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{- define "spark.svc.domain" -}}
{{- printf "%s.svc.cluster.local" .Release.Namespace -}}
{{- end -}}

{{- define "spark.hive.metastore.svc" -}}
{{- if .Values.global.hiveMetastoreSvcOverride -}}
{{- .Values.global.hiveMetastoreSvcOverride -}}
{{- else -}}
{{- $service := .Release.Name -}}
{{- $domain := include "spark.svc.domain" . -}}
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

{{- define "spark.spark.defaults.config" -}}
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
{{- $service := include "spark.hive.metastore.svc" . -}}
{{- printf "spark.hadoop.hive.metastore.uris %s\n" $service -}}
{{- end -}}
{{- end -}}

{{- define "spark.zeppelin.spark.submit.options" -}}
{{- printf "--deploy-mode client" -}}
{{- range $key, $value := index .Values.zeppelin.sparkSubmitOptions -}}
{{ " --conf"}} {{ $key }}{{ "=" }}{{ $value }}
{{- end }}
{{- if not (index .Values.zeppelin.sparkSubmitOptions "spark.driver.host") -}}
{{- $host := include "zeppelin-master" . -}}
{{- printf " --conf spark.driver.host=%s" $host -}}
{{- end -}}
{{- if not (index .Values.zeppelin.sparkSubmitOptions "spark.eventLog.dir") -}}
{{- printf " --conf spark.eventLog.dir=hdfs://%s-hadoop-hdfs-nn/spark-history" .Release.Name -}}
{{- end -}}
{{- if not (index .Values.zeppelin.sparkSubmitOptions "spark.history.fs.logDirectory") -}}
{{- printf " --conf spark.history.fs.logDirectory=hdfs://%s-hadoop-hdfs-nn/spark-history" .Release.Name -}}
{{- end -}}
{{- if not (index .Values.zeppelin.sparkSubmitOptions "spark.hadoop.hive.metastore.uris") -}}
{{- $service := include "spark.hive.metastore.svc" . -}}
{{- printf " --conf spark.hadoop.hive.metastore.uris=%s" $service -}}
{{- end -}}
{{- end -}}

{{- define "spark.thirftserver.start.options" -}}
{{- printf "--master %s" .Values.sparkMaster -}}
{{- range $key, $value := index .Values.thirftserver.startOptions -}}
{{ " --conf"}} {{ $key }}{{ "=" }}{{ $value }}
{{- end }}
{{- if not (index .Values.thirftserver.startOptions "spark.driver.host") -}}
{{- $host := include "thirftserver.master" . -}}
{{- printf " --conf spark.driver.host=%s" $host -}}
{{- end -}}
{{- end -}}