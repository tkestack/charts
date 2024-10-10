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
{{- .Values.fullnameOverride | trunc 45 | trimSuffix "-" }}
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


{{- define "opentelemetry-operator.host" -}}
{{- $endpoint :=.Values.env.ENDPOINT}}
{{- $ss := $endpoint | split ":" -}}
{{- printf "%s:%s" (index $ss "_0") (index $ss "_1") -}}
{{end}}


{{- define "regionRepositoryMap" -}}
{{- $region := . -}}
{{- $map := dict
  "ap-guangzhou" "ccr.ccs.tencentyun.com"
  "ap-shanghai-fsi" "shjrccr.ccs.tencentyun.com"
  "ap-beijing-fsi" "bjjrccr.ccs.tencentyun.com"
  "ap-hongkong" "hkccr.ccs.tencentyun.com"
  "ap-singapore" "sgccr.ccs.tencentyun.com"
  "na-siliconvalley" "uswccr.ccs.tencentyun.com"
  "eu-frankfurt" "deccr.ccs.tencentyun.com"
  "na-ashburn" "useccr.ccs.tencentyun.com"
  "sa-saopaulo" "saoccr.ccs.tencentyun.com"
  "ap-bangkok" "thccr.ccs.tencentyun.com"
  "ap-jakarta" "jktccr.ccs.tencentyun.com"
  "na-toronto" "caccr.ccs.tencentyun.com"
  "ap-seoul" "krccr.ccs.tencentyun.com"
  "ap-tokyo" "jpccr.ccs.tencentyun.com"
  "ap-mumbai" "inccr.ccs.tencentyun.com"
  "ap-shenzhen-fsi" "szjrccr.ccs.tencentyun.com"
  "ap-taipei" "tpeccr.ccs.tencentyun.com" -}}
{{- $result := index $map $region | default "ccr.ccs.tencentyun.com" -}}
{{- $result -}}
{{- end -}}


{{/*
Modify image repository by region.
*/}}
{{- define "opentelemetry-operator.managerImageRepository" -}}
{{- $parts := regexSplit "/" .Values.manager.image.repository -1 -}}
{{- printf "%s/%s" (include "regionRepositoryMap" .Values.env.TKE_REGION) (join "/" (slice $parts 1 (len $parts))) -}}
{{- end -}}


{{/*
Modify collector image repository by region.
*/}}
{{- define "opentelemetry-operator.managerCollectorImageRepository" -}}
{{- $parts := regexSplit "/" .Values.manager.collectorImage.repository -1 -}}
{{- printf "%s/%s" (include "regionRepositoryMap" .Values.env.TKE_REGION) (join "/" (slice $parts 1 (len $parts))) -}}
{{- end -}}


{{/*
Modify kubeRBACProxy image repository by region.
*/}}
{{- define "opentelemetry-operator.proxyImageRepository" -}}
{{- $parts := regexSplit "/" .Values.kubeRBACProxy.image.repository -1 -}}
{{- printf "%s/%s" (include "regionRepositoryMap" .Values.env.TKE_REGION) (join "/" (slice $parts 1 (len $parts))) -}}
{{- end -}}
