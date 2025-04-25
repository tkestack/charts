{{/*
Expand the name of the chart.
*/}}
{{- define "dynamo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dynamo.fullname" -}}
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

{{- define "nats.server" -}}
{{- if .Values.natsServerOverride }}
{{- .Values.natsServerOverride }}
{{- else }}
{{- $name := .Release.Name | trunc 63 | trimSuffix "-" }}
{{- printf "nats://%s-nats:4222" $name }}
{{- end }}
{{- end }}

{{- define "etcd.endpoints" -}}
{{- if .Values.etcdEndpointsOverride }}
{{- .Values.etcdEndpointsOverride }}
{{- else }}
{{- $name := .Release.Name | trunc 63 | trimSuffix "-" }}
{{- printf "%s-etcd:2379" $name }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dynamo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dynamo.labels" -}}
helm.sh/chart: {{ include "dynamo.chart" . }}
{{ include "dynamo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dynamo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dynamo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "dynamo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dynamo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Annotations of rdma
*/}}
{{- define "rdma.annotations" -}}
{{- if eq .Values.rdma.networkMode "tke-bridge" }}
tke.cloud.tencent.com/networks: "tke-bridge,tke-rdma-ipvlan"
{{- else if eq .Values.rdma.networkMode "tke-route-eni" }}
tke.cloud.tencent.com/networks: "tke-route-eni,tke-rdma-ipvlan"
{{- end }}
{{- end }}
