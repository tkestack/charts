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

{{- define "opentelemetry-operator.jobName" -}}
{{- $name := include "opentelemetry-operator.name" . -}}
{{- printf "%s-wait-for-manager" $name | trunc 63 | trimSuffix "-" }}
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
{{- $endpoint := .Values.env.ENDPOINT }}
{{- $ss := $endpoint | split ":" -}}
{{- $scheme := index $ss "_0" -}}
{{- $host := index $ss "_1" | trimPrefix "//" -}}
{{- if eq $scheme "https" -}}
{{- printf "%s://%s:91" $scheme $host -}}
{{- else -}}
{{- printf "%s://%s:90" $scheme $host -}}
{{- end -}}
{{- end }}

{{- define "opentelemetry-operator.apiRegion" -}}
{{- $apiRegion := .Values.env.API_REGION | default "" -}}
{{- if eq $apiRegion "" -}}
{{- $endpoint := .Values.env.ENDPOINT | default "" -}}
{{- $hostWithPort := regexReplaceAll "^https?://([^/]+).*$" $endpoint "${1}" -}}
{{- $host := regexReplaceAll ":\\d+$" $hostWithPort "" -}}
{{- $host = regexReplaceAll "^pl\\." $host "" -}}
{{- if eq $host "ap-hongkong-qcloud.apm.tencentcs.com" -}}
{{- $apiRegion = "ap-hongkong" -}}
{{- else if eq $host "qcloud.apm.tencentcs.com" -}}
{{- $apiRegion = "ap-singapore" -}}
{{- else if eq $host "175.27.25.26" -}}
{{- $apiRegion = "ap-qingyuan" -}}
{{- else -}}
{{- $region := regexReplaceAll "^([^.]+)\\.apm\\.tencentcs\\.com$" $host "${1}" -}}
{{- if and (ne $region "") (ne $region $host) -}}
{{- $apiRegion = $region -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $apiRegion -}}
{{- end -}}


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
  "ap-guangzhou-wxzf" "gzwxzfccr.ccs.tencentyun.com"
  "ap-shenzhen-jxcft" "szjxcftccr.ccs.tencentyun.com"
  "ap-shanghai-hq-cft" "shhqcftccr.ccs.tencentyun.com"
  "ap-shanghai-hq-uat-cft" "shhqcftfzhjccr.ccs.tencentyun.com"
  "ap-shanghai-wxzf" "shwxzfccr.ccs.tencentyun.com"
  "ap-shanghai-adc" "shadcccr.ccs.tencentyun.com"
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


{{- define "opentelemetry-operator.jobImageRepository" -}}
{{- $parts := regexSplit "/" .Values.waitForManager.image.repository -1 -}}
{{- printf "%s/%s" (include "regionRepositoryMap" .Values.env.TKE_REGION) (join "/" (slice $parts 1 (len $parts))) -}}
{{- end -}}

{{/*
自动检测集群是否为 cilium-overlay 网络模式。
通过 lookup 函数查询 kube-system 命名空间下的 cilium-config ConfigMap，
兼容 Cilium 新旧版本的配置方式：
- Cilium < 1.14：tunnel 字段为 vxlan 或 geneve
- Cilium >= 1.14：routing-mode 为 tunnel 且 tunnel-protocol 为 vxlan 或 geneve
*/}}
{{- define "opentelemetry-operator.isCiliumOverlay" -}}
{{- $ciliumConfig := (lookup "v1" "ConfigMap" "kube-system" "cilium-config") -}}
{{- if $ciliumConfig -}}
  {{- $tunnel := index (default dict $ciliumConfig.data) "tunnel" | default "" -}}
  {{- $routingMode := index (default dict $ciliumConfig.data) "routing-mode" | default "" -}}
  {{- $tunnelProtocol := index (default dict $ciliumConfig.data) "tunnel-protocol" | default "" -}}
  {{- if or (eq $tunnel "vxlan") (eq $tunnel "geneve") (and (eq $routingMode "tunnel") (or (eq $tunnelProtocol "vxlan") (eq $tunnelProtocol "geneve"))) -}}
true
  {{- else -}}
false
  {{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
自动检测 api-server 是否部署在独立的网络控制面（托管模式）。
通过对比 kubernetes service 的 endpoint IP 与集群 Node IP 来判断：
- 如果 api-server IP 不在任何 Node IP 中，说明 api-server 在独立控制面（托管集群）
- 如果 api-server IP 在某个 Node IP 中，说明 api-server 在集群内部（自建集群）
- 如果 endpoint 或 Node 信息不完整（IP 列表为空），返回 "false"（无法确认托管，保守处理）
- 如果 lookup 返回空（helm template 等场景），返回 "unknown"

获取 api-server IP 的策略（版本兼容）：
- 优先使用 EndpointSlice API (discovery.k8s.io/v1)，适用于 K8s >= 1.21
- 如果 EndpointSlice 不可用（K8s < 1.21 或权限不足），fallback 到 Endpoints API (v1)
*/}}
{{- define "opentelemetry-operator.isApiServerManaged" -}}
{{- $nodes := (lookup "v1" "Node" "" "") -}}
{{- /* 优先尝试 EndpointSlice API (discovery.k8s.io/v1, K8s >= 1.21) */ -}}
{{- $endpointSlices := (lookup "discovery.k8s.io/v1" "EndpointSlice" "default" "") -}}
{{- $apiIPs := list -}}
{{- $endpointFound := false -}}
{{- if and $endpointSlices $endpointSlices.items -}}
  {{- range $slice := $endpointSlices.items -}}
    {{- $svcName := index (default dict $slice.metadata.labels) "kubernetes.io/service-name" | default "" -}}
    {{- if eq $svcName "kubernetes" -}}
      {{- range $ep := $slice.endpoints -}}
        {{- range $addr := $ep.addresses -}}
          {{- $apiIPs = append $apiIPs $addr -}}
        {{- end -}}
      {{- end -}}
      {{- $endpointFound = true -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- /* 如果 EndpointSlice 未获取到数据，fallback 到 Endpoints API (v1) */ -}}
{{- if not $endpointFound -}}
  {{- $endpoints := (lookup "v1" "Endpoints" "default" "kubernetes") -}}
  {{- if $endpoints -}}
    {{- range $subset := $endpoints.subsets -}}
      {{- range $addr := $subset.addresses -}}
        {{- $apiIPs = append $apiIPs $addr.ip -}}
      {{- end -}}
    {{- end -}}
    {{- $endpointFound = true -}}
  {{- end -}}
{{- end -}}
{{- if and $endpointFound $nodes -}}
  {{- /* 获取所有 Node 的 InternalIP 列表 */ -}}
  {{- $nodeIPs := list -}}
  {{- range $node := $nodes.items -}}
    {{- range $addr := $node.status.addresses -}}
      {{- if eq $addr.type "InternalIP" -}}
        {{- $nodeIPs = append $nodeIPs $addr.address -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- /* 如果 apiIPs 或 nodeIPs 为空，信息不完整，无法准确判断，直接返回 false */ -}}
  {{- if or (eq (len $apiIPs) 0) (eq (len $nodeIPs) 0) -}}
false
  {{- else -}}
  {{- /* 检查是否有任何 api-server IP 在 Node IP 列表中 */ -}}
  {{- $found := false -}}
  {{- range $apiIP := $apiIPs -}}
    {{- if has $apiIP $nodeIPs -}}
      {{- $found = true -}}
    {{- end -}}
  {{- end -}}
  {{- if $found -}}
false
  {{- else -}}
true
  {{- end -}}
  {{- end -}}
{{- else -}}
unknown
{{- end -}}
{{- end -}}

{{/*
判断是否需要启用 hostNetwork。
优先级：
1. 用户显式设置 hostNetwork: true → 启用
2. 用户手动设置 networkMode: "cilium-overlay" → 启用
3. networkMode 为空（默认）时，自动检测：
   a. 检测集群 CNI 类型是否为 cilium-overlay
   b. 如果是 cilium-overlay，进一步检测 api-server 是否在独立控制面
   c. 两个条件同时满足时才启用 hostNetwork
   d. 如果 lookup 无法工作（helm template 等场景），不启用 hostNetwork
*/}}
{{- define "opentelemetry-operator.hostNetwork" -}}
{{- if .Values.hostNetwork -}}
true
{{- else if eq (toString .Values.networkMode) "cilium-overlay" -}}
true
{{- else if eq (toString .Values.networkMode) "" -}}
  {{- /* networkMode 为空时，自动检测 */ -}}
  {{- $isCiliumOverlay := include "opentelemetry-operator.isCiliumOverlay" . -}}
  {{- if eq $isCiliumOverlay "true" -}}
    {{- /* 检测到 Cilium-Overlay，进一步判断 api-server 部署方式 */ -}}
    {{- $isManaged := include "opentelemetry-operator.isApiServerManaged" . -}}
    {{- if eq $isManaged "true" -}}
true
    {{- else -}}
false
    {{- end -}}
  {{- else -}}
false
  {{- end -}}
{{- else -}}
false
{{- end -}}
{{- end -}}


{{/*
Instrumentation resource spec definition.
用于在多个地方复用 Instrumentation 资源定义
*/}}
{{- define "opentelemetry-operator.instrumentation" -}}
apiVersion: opentelemetry.io/v1alpha1
kind: Instrumentation
metadata:
  name: default-instrumentation
  namespace: opentelemetry-operator-system
spec:
  exporter:
    endpoint: {{ .Values.env.ENDPOINT | quote | trim }}
  propagators:
    - tracecontext
    - baggage
    - b3
  resource:
    resourceAttributes:
      token: {{ .Values.env.APM_TOKEN }}
  java:
    image:
  nodejs:
    image:
  python:
    image:
    env:
      - name: OTEL_EXPORTER_OTLP_ENDPOINT
        value: {{ printf "%s/otlp" (include "opentelemetry-operator.host" . ) | quote | trim }}
  dotnet:
    image:
    env:
      - name: OTEL_EXPORTER_OTLP_ENDPOINT
        value: {{ printf "%s/otlp" (include "opentelemetry-operator.host" . ) | quote | trim }}
  go:
    image: ccr.ccs.tencentyun.com/tapm/autoinstrumentation-go:v0.8.0-alpha
{{- end -}}
