{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "ollama.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ollama.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ollama.fullname" -}}
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
{{- define "ollama.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ollama.labels" -}}
helm.sh/chart: {{ include "ollama.chart" . }}
{{ include "ollama.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ollama.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ollama.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ollama.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ollama.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the pull model list
*/}}
{{- define "ollama.modelPullList" -}}
{{- with .Values.ollama.models.pull -}}
{{- . | uniq | join " " -}}
{{- end -}}
{{- end -}}

{{/*
Create the run model list
*/}}
{{- define "ollama.modelRunList" -}}
{{- with .Values.ollama.models.run -}}
{{- . | uniq | join " " -}}
{{- end -}}
{{- end -}}

{{/*
Create the create template model list
*/}}
{{- define "ollama.modelCreateTemplateList" -}}
{{- $createModels := .Values.ollama.models.create | default dict -}}
{{- $modelNames := list -}}
{{- range $createModels -}}
{{- if .template -}}
  {{- $modelNames = append $modelNames .name -}}
{{- end -}}
{{- end -}}
{{- $modelNames | uniq | join " " -}}
{{- end -}}

{{/*
Create the create configMap model list
*/}}
{{- define "ollama.modelCreateConfigMapList" -}}
{{- $createModels := .Values.ollama.models.create | default dict -}}
{{- $modelNames := list -}}
{{- range $createModels -}}
{{- if .configMapRef -}}
  {{- $modelNames = append $modelNames .name -}}
{{- end -}}
{{- end -}}
{{- $modelNames | uniq | join " " -}}
{{- end -}}

{{/*
Models mount path
*/}}
{{- define "ollama.modelsMountPath" -}}
{{- printf "%s/models" ( default "/root/.ollama") }}
{{- end -}}