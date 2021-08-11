{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "hive.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{- define "hive.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "metastore.fullname" -}}
{{- $name := default .Chart.Name .Values.metastore.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "server.fullname" -}}
{{- $name := default .Chart.Name .Values.server.name -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hadoop.conf.name" -}}
{{- if .Values.hadoopConfName -}}
{{- printf "%s" .Values.hadoopConfName -}}
{{- else -}}
{{- $name := default "hadoop" .Values.hadoopName -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hive.jdbcUrl" -}}
{{- if .Values.jdbcUrl -}}
{{- printf "%s" .Values.jdbcUrl -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresqlName -}}
{{- printf "%s%s-%s.%s.%s%s" "jdbc:postgresql://" .Release.Name $name .Release.Namespace "svc.cluster.local" "/metastore" | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hive-metastore-svc" -}}
{{- if .Values.global.metastoreOverride -}}
{{- .Values.global.metastoreOverride -}}
{{- else -}}
{{- $service := include "metastore.fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- $replicas := .Values.metastore.replicas | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "thrift://%s-%d.%s-headless.%s:9083," $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "thrift://%s-%d.%s-headless.%s:9083" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "hive-zookeeper-fullname" -}}
{{- $fullname := .Release.Name -}}
{{- if contains "zookeeper" $fullname -}}
{{- printf "%s" $fullname -}}
{{- else -}}
{{- printf "%s-zookeeper" $fullname | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hive-zookeeper-quorum" -}}
{{- if .Values.global.zookeeperQuorumOverride -}}
{{- .Values.global.zookeeperQuorumOverride -}}
{{- else -}}
{{- $service := include "hive-zookeeper-fullname" . -}}
{{- $domain := include "svc-domain" . -}}
{{- $replicas := .Values.global.zookeeperQuorumSize | int -}}
{{- range $i, $e := until $replicas -}}
  {{- if ne $i 0 -}}
    {{- printf "%s-%d.%s-headless.%s:2181," $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- range $i, $e := until $replicas -}}
  {{- if eq $i 0 -}}
    {{- printf "%s-%d.%s-headless.%s:2181" $service $i $service $domain -}}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}