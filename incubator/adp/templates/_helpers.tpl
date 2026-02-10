{{/*
Expand the name of the chart.
*/}}
{{- define "adp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "adp.fullname" -}}
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
{{- define "adp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "adp.labels" -}}
helm.sh/chart: {{ include "adp.chart" . }}
{{ include "adp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "adp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "adp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
判断是否需要 initContainer
直接检测节点 label 中是否包含 "tke.cloud.tencent"
这是一个全局 helper 函数，可以被所有子 chart 使用
*/}}
{{- define "needInitContainer" -}}
{{- $needInit := false -}}
{{- $nodes := lookup "v1" "Node" "" "" -}}
{{- if $nodes -}}
  {{- range $nodes.items -}}
    {{- range $key, $value := .metadata.labels -}}
      {{- if contains "tke.cloud.tencent" $key -}}
        {{- $needInit = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $needInit -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
获取 ProductType 值
TKE 环境返回 1，其他环境返回 2
这是一个全局 helper 函数，可以被所有子 chart 使用
*/}}
{{- define "getProductType" -}}
{{- $isTKE := false -}}
{{- $nodes := lookup "v1" "Node" "" "" -}}
{{- if $nodes -}}
  {{- range $nodes.items -}}
    {{- range $key, $value := .metadata.labels -}}
      {{- if contains "tke.cloud.tencent" $key -}}
        {{- $isTKE = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $isTKE -}}
1
{{- else -}}
2
{{- end -}}
{{- end -}}

{{/*
依赖检查器 - Volumes 模板
用于挂载依赖检查脚本和 helmfile 配置
使用方式：{{- include "dependencyChecker.volumes" . | nindent 8 }}
*/}}
{{- define "dependencyChecker.volumes" -}}
{{- if eq (include "needInitContainer" .) "true" }}
- name: dependency-checker-script
  configMap:
    name: dependency-checker-script
    defaultMode: 0755
- name: helmfile-config
  configMap:
    name: helmfile-config
{{- end }}
{{- end -}}

{{/*
依赖检查器 - InitContainer 模板
用于等待依赖项就绪
使用方式：{{- include "dependencyChecker.initContainer" . | nindent 8 }}
*/}}
{{- define "dependencyChecker.initContainer" -}}
{{- if eq (include "needInitContainer" .) "true" }}
- name: wait-for-dependencies
  image: ccr.ccs.tencentyun.com/tke-market/kubectl:20260130
  env:
    - name: RELEASE_NAME
      value: "{{ .Values.helmfileReleaseName | default .Chart.Name }}"
    - name: NAMESPACE
      value: "{{ .Release.Namespace }}"
  command:
    - /bin/bash
    - /scripts/check-dependencies.sh
  volumeMounts:
    - name: dependency-checker-script
      mountPath: /scripts
    - name: helmfile-config
      mountPath: /helmfile
{{- end }}
{{- end -}}
