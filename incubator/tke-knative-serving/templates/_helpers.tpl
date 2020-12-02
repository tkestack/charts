{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "knative-serving.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "knative-serving.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "knative-serving.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "knative-serving.labels" -}}
helm.sh/chart: {{ include "knative-serving.chart" . }}
{{ include "knative-serving.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "knative-serving.selectorLabels" -}}
app.kubernetes.io/name: {{ include "knative-serving.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}


{{/*
Create a default activator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "knative-serving.core.activator.name" -}}
{{- printf "%s" .Values.core.activator.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default autoscaler name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "knative-serving.core.autoscaler.name" -}}
{{- printf "%s" .Values.core.autoscaler.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default controller name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "knative-serving.core.controller.name" -}}
{{- printf "%s" .Values.core.controller.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default webhook name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "knative-serving.core.webhook.name" -}}
{{- printf "%s" .Values.core.webhook.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create a default istio networking name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "knative-serving.istio.networking.name" -}}
{{- printf "%s-%s" .Values.istio.networking.name "istio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default istio webhook name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "knative-serving.istio.webhook.name" -}}
{{- printf "%s-%s" "istio" .Values.istio.webhook.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

