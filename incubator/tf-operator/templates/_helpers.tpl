{{/*
Expand the name of the chart.
*/}}
{{- define "tf-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tf-operator.fullname" -}}
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
{{- define "tf-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tf-operator.labels" -}}
helm.sh/chart: {{ include "tf-operator.chart" . }}
{{ include "tf-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tf-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tf-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tf-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tf-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Namespace name
*/}}
{{- define "tf-operator.namespaceName" -}}
{{- if .Values.namespace.create }}
{{- default (include "tf-operator.fullname" .) .Values.namespace.name }}
{{- else }}
{{- default "default" "kubeflow" }}
{{- end }}
{{- end }}

{{/*
Create the Service annotations for Prometheus
*/}}
{{- define "tf-operator.serviceAnnotations" -}}
prometheus.io/path: "{{ .Values.prometheus.path }}"
prometheus.io/scrape: "{{ .Values.prometheus.scrape }}"
prometheus.io/port: "{{ .Values.prometheus.port }}"
{{- end }}