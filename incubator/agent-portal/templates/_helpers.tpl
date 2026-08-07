{{/*
Expand the name of the chart.
*/}}
{{- define "agent-portal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "agent-portal.fullname" -}}
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
{{- define "agent-portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "agent-portal.labels" -}}
helm.sh/chart: {{ include "agent-portal.chart" . }}
{{ include "agent-portal.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "agent-portal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "agent-portal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "agent-portal.name" . }}
{{- end }}

{{/*
Runtime configuration Secret name
*/}}
{{- define "agent-portal.secretName" -}}
{{- printf "%s-env" (include "agent-portal.fullname" .) }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "agent-portal.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}
