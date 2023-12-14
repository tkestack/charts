{{/*
Expand the name of the chart.
*/}}
{{- define "opentelemetry-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opentelemetry-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opentelemetry-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opentelemetry-operator.labels" -}}
helm.sh/chart: {{ include "opentelemetry-operator.chart" . }}
{{ include "opentelemetry-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opentelemetry-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opentelemetry-operator.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opentelemetry-operator.serviceAccountName" -}}
{{- if .Values.manager.serviceAccount.create }}
{{- default (include "opentelemetry-operator.name" .) .Values.manager.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.manager.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "opentelemetry-operator.podAnnotations" -}}
{{- if .Values.manager.podAnnotations }}
{{- .Values.manager.podAnnotations | toYaml }}
{{- end }}
{{- end }}

{{- define "opentelemetry-operator.podLabels" -}}
{{- if .Values.manager.podLabels }}
{{- .Values.manager.podLabels | toYaml }}
{{- end }}
{{- end }}

{{/*
Create an ordered name of the MutatingWebhookConfiguration
*/}}
{{- define "opentelemetry-operator.MutatingWebhookName" -}}
{{- printf "%s-%s" (.Values.admissionWebhooks.namePrefix | toString) (include "opentelemetry-operator.fullname" .) | trimPrefix "-" }}
{{- end }}

{{/*
根据地域确定上报地址
*/}}
{{- define "opentelemetry-operator.endpoint" -}}
{{if eq .Values.env.TKE_REGION "ap-guangzhou"}}http://pl.ap-guangzhou.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "ap-shanghai"}}http://pl.ap-shanghai.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "ap-beijing"}}http://pl.ap-beijing.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "ap-hongkong"}}http://pl.ap-hongkong.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "ap-shanghai-fsi"}}http://pl.ap-shanghai-fsi.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "ap-beijing-fsi"}} http://pl.ap-beijing-fsi.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "ap-singapore"}}http://pl.ap-singapore.apm.tencentcs.com{{
else if eq .Values.env.TKE_REGION "na-siliconvalley"}}http://pl.na-siliconvalley.apm.tencentcs.com{{
else}}http://pl.ap-guangzhou.apm.tencentcs.com{{end}}{{end}}


