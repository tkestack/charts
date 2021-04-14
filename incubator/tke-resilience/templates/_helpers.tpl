{{/* vim: set filetype=mustache: */}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tke-resilience.fullname" -}}
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
{{- define "tke-resilience.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "eklet.labels" -}}
hybridcloud.tencentcloud.com/component: eklet
hybridcloud.tencentcloud.com/vpc-id: {{ .Values.cloud.vpcID }}
{{- end -}}

{{- define "eks-admission.labels" -}}
hybridcloud.tencentcloud.com/component: eks-admission-controller
{{- end -}}

{{- define "scheduler.labels" -}}
scheduler.alpha.kubernetes.io/critical-pod: ""
tke.prometheus.io/scrape: "true"
prometheus.io/scheme: "http"
prometheus.io/port: "10251"
component: kube-scheduler
tier: control-plane
{{- end -}}

{{- define "node.labels" -}}
eks.tke.cloud.tencent.com/version: v2
node.kubernetes.io/instance-type: eklet
{{- end -}}

{{- define "isTKEkubeVendor" -}}
  {{- if contains "tke" .Capabilities.KubeVersion.GitVersion -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end }}