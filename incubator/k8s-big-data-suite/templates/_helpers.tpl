{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "svc-domain" -}}
{{- printf "%s.svc.cluster.local" .Release.Namespace -}}
{{- end -}}

{{- define "ingress.name" -}}
{{- printf "%s-%s" .Release.Name "ingress" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nginx.name" -}}
{{- printf "%s-%s" .Release.Name "nginx-proxy" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.airflow.name" -}}
{{- printf "%s-%s" .Release.Name "airflow-web" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.history.name" -}}
{{- printf "%s-%s" .Release.Name "spark-history" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.kibana.name" -}}
{{- printf "%s-%s" .Release.Name "kibana" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.grafana.name" -}}
{{- printf "%s-%s" .Release.Name "grafana" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.zeppelin.name" -}}
{{- printf "%s-%s" .Release.Name "zeppelin-controller" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.hive.name" -}}
{{- printf "%s-%s" .Release.Name "hive-server" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.hbase.name" -}}
{{- printf "%s-%s" .Release.Name "hbase-master" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.kudu.name" -}}
{{- printf "kudu-master-ui" -}}
{{- end -}}

{{- define "service.catalogd.name" -}}
{{- printf "%s-%s" .Release.Name "impala-catalogd" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.coord.name" -}}
{{- printf "%s-%s" .Release.Name "impala-coord-exec" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.statestored.name" -}}
{{- printf "%s-%s" .Release.Name "impala-statestored" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.prometheus.name" -}}
{{- printf "%s-%s" .Release.Name "prometheus-operator-prometheus" | trunc 127 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.alertmanager.name" -}}
{{- printf "%s-%s" .Release.Name "prometheus-operator-alertmanager" | trunc 127 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.hdfs.name" -}}
{{- printf "%s-%s" .Release.Name "hadoop-hdfs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.superset.name" -}}
{{- printf "%s-%s" .Release.Name "superset" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "service.postgresql.name" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hadoop-fullname" -}}
{{- printf "%s-%s" .Release.Name "hadoop" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the name of the namenode pod 0.
*/}}
{{- define "hadoop-namenode-pod-0" -}}
{{- template "hadoop-fullname" . -}}-hdfs-nn-0
{{- end -}}

{{/*
Construct the name of the namenode pod 1.
*/}}
{{- define "hadoop-namenode-pod-1" -}}
{{- template "hadoop-fullname" . -}}-hdfs-nn-1
{{- end -}}

{{/*
Construct the full name of the namenode statefulset member 0.
*/}}
{{- define "hadoop-namenode-svc-0" -}}
{{- $pod := include "hadoop-namenode-pod-0" . -}}
{{- $service := include "hadoop-fullname"  . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s.%s-hdfs-nn.%s" $pod $service $domain -}}
{{- end -}}

{{/*
Construct the full name of the namenode statefulset member 1.
*/}}
{{- define "hadoop-namenode-svc-1" -}}
{{- $pod := include "hadoop-namenode-pod-1" . -}}
{{- $service := include "hadoop-fullname"  . -}}
{{- $domain := include "svc-domain" . -}}
{{- printf "%s.%s-hdfs-nn.%s" $pod $service $domain -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

