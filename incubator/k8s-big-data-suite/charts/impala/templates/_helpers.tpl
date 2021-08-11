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

{{- define "impala.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "statestored.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "statestored" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "catalogd.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "catalogd" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "coord-exec.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "coord-exec" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "shell.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "shell" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "hadoop.conf.name" -}}
{{- if .Values.hadoopConfName -}}
{{- printf "%s" .Values.hadoopConfName -}}
{{- else -}}
{{- $name := default "hadoop" .Values.hadoopName -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "hive.conf.name" -}}
{{- printf "%s-%s" .Release.Name "hive" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
  Generate Kudu Masters String
*/}}
{{- define "kudu.kudu_masters" -}}
{{- $root := . -}}
{{- if .Values.kudu.enabled -}}
    {{- if .Values.kudu.kuduMasters -}}
        {{- .Values.kudu.kuduMasters -}}
    {{- else -}}
        {{- $master_replicas := .Values.kudu.masterReplicas | int -}}
        {{range $index := until $master_replicas }}{{if ne $index 0}},{{end}}kudu-master-{{ $index }}.kudu-masters.{{- $root.Release.Namespace -}}.svc.cluster.local{{end}}
    {{- end -}}
{{- end -}}
{{- end -}}
