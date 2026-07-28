{{/*
Helper functions for multi-service SQL import
*/}}

{{/*
cross-up 公共环境变量（init / upgrade / post-upgrade 共用）
注意：内容从列 0 开始，由调用方通过 nindent 控制缩进
使用方式：{{- include "dataInit.commonEnv" . | nindent 10 }}
*/}}
{{- define "dataInit.commonEnv" -}}
- name: DEPLOY_REGION
  value: _public
- name: INSTALL_NS
  value: {{ .Release.Namespace }}
# ---------- 应用基础URL（第三方插件 MCP 服务器地址） ----------
- name: APP_BASE_URL
  value: {{ printf "%s://%s" (.Values.global.scheme | default "http") (.Values.global.clb | default "") | quote }}
# ---------- ADP apikey ----------
- name: ADP_API_KEY
  value: "{{ dig "modelServices" "adp" "apiKey" "" .Values.global }}"
- name: HUNYUAN_API_KEY
  value: "{{ dig "modelServices" "hunyuan" "apiKey" "" .Values.global }}"
# ---------- MySQL ----------
- name: DB_HOST
  value: "{{ .Values.global.components.db.host }}"
- name: DB_PORT
  value: "{{ .Values.global.components.db.port | default "3306" }}"
- name: DB_USER
  value: "{{ .Values.global.components.db.user }}"
- name: DB_PASSWORD
  value: "{{ .Values.global.components.db.password }}"
- name: DISABLE_SHARDKEY
  value: "{{ eq .Values.global.components.db.providerType "tdsql" | ternary "false" "true" }}"
# ---------- Elasticsearch ----------
- name: ES_HOST
  value: "{{ (index .Values.global.components.es.hosts 0) }}"
- name: ES_PORT
  value: "{{ .Values.global.components.es.port | default "9200" }}"
- name: ES_USERNAME
  value: "{{ .Values.global.components.es.user | default "" }}"
- name: ES_PASSWORD
  value: "{{ .Values.global.components.es.password | default "" }}"
- name: ES_SCHEME
  value: "http"
# ---------- Redis ----------
- name: REDIS_HOST
  value: "{{ index .Values.global.components.redis.hosts 0 }}"
- name: REDIS_PORT
  value: "{{ .Values.global.components.redis.port }}"
- name: REDIS_PASSWORD
  value: "{{ .Values.global.components.redis.password }}"
# ---------- S3 对象存储 ----------
- name: S3_PROVIDER
  value: "{{ .Values.global.components.s3.providerType }}"
- name: S3_HOST
  value: {{ include "ex.s3_host" . | trim | quote }}
- name: S3_RESOURCE_URL
  value: {{ include "ex.s3_resource_url" . | trim | quote }}
{{- if .Values.global.components.s3.cos.enableSts }}
# STS 模式：注入 STS 主凭证。INFRA_MIDDLEWARES_S3_COS_SECRETID/KEY 在此模式下已被
# infra-credentials Secret 置空，data-init 需读取 ADP_ASSUME_ROLE_SECRET_ID/KEY
# 才能拿到真正的主凭证，用于调 STS 换临时凭证并访问 COS。
- name: S3_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: infra-credentials
      key: ADP_ASSUME_ROLE_SECRET_ID
- name: S3_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: infra-credentials
      key: ADP_ASSUME_ROLE_SECRET_KEY
{{- else }}
- name: S3_ACCESS_KEY
  value: {{ include "ex.s3_AK" . | trim | quote }}
- name: S3_SECRET_KEY
  value: {{ include "ex.s3_SK" . | trim | quote }}
{{- end }}
- name: S3_BUCKET_NAME
  value: {{ include "ex.s3_bucket" . | trim | quote }}
- name: S3_RESOURCE_DIR
  value: "{{ .Values.resourcesDir }}"
- name: S3_ENABLE_PROXY
  value: "{{ .Values.global.components.s3.enableProxy | default false }}"
# ---------- 向量数据库 (VDB) ----------
{{- $vdbList := dig "vdb" (list) .Values.global.components | default (list) }}
{{- if gt (len $vdbList) 0 }}
{{- $vdb0 := index $vdbList 0 }}
- name: ENABLE_VDB
  value: {{ $vdb0.enabled | default true | toString | quote }}
{{- if ne ($vdb0.enabled | default true | toString) "false" }}
- name: VDB_ADDR
  value: {{ $vdb0.addr | quote }}
- name: VDB_ACCOUNT
  value: {{ $vdb0.account | quote }}
- name: VDB_APIKEY
  value: {{ $vdb0.apiKey | quote }}
- name: VDB_DATABASES
  value: "db-vdb-0,db-vdb-1,db-vdb-2,db-vdb-3,db-vdb-4"
{{- end }}
{{- else }}
- name: ENABLE_VDB
  value: "false"
{{- end }}
# ---------- Kafka ----------
# 用于 initialize_kafka_topics 步骤：按 initialization/kafka/<version>/topics.csv
# 幂等创建/补齐 topic。
# 兼容三种情况：
#   1) global.components.kafka 未配置        -> ENABLE_KAFKA=false，脚本整段跳过
#   2) global.components.kafka.disabled=true -> ENABLE_KAFKA=false
#   3) 其他                                  -> ENABLE_KAFKA=true 并注入 KAFKA_BOOTSTRAP_SERVERS
{{- if and (hasKey .Values.global.components "kafka") (ne (dig "kafka" "disabled" false .Values.global.components | toString) "true") }}
- name: ENABLE_KAFKA
  value: "true"
- name: KAFKA_HOST
  value: {{ index .Values.global.components.kafka.hosts 0 | quote }}
- name: KAFKA_PORT
  value: {{ .Values.global.components.kafka.port | quote }}
- name: KAFKA_BOOTSTRAP_SERVERS
  value: "{{ index .Values.global.components.kafka.hosts 0 }}:{{ .Values.global.components.kafka.port }}"
- name: KAFKA_VERSION_DIR
  value: "v4.0.3"
{{- else }}
- name: ENABLE_KAFKA
  value: "false"
{{- end }}
# ---------- ClickHouse ----------
{{- if eq (dig "clickhouse" "disabled" false .Values.global.components | toString) "true" }}
- name: ENABLE_CLICKHOUSE
  value: "false"
{{- else }}
- name: ENABLE_CLICKHOUSE
  value: "true"
- name: CH_HOST
  value: {{ index .Values.global.components.clickhouse.hosts 0 | quote }}
- name: CH_PORT
  value: {{ .Values.global.components.clickhouse.port | quote }}
- name: CH_USER
  value: {{ .Values.global.components.clickhouse.user | quote }}
- name: CH_PASSWORD
  value: {{ .Values.global.components.clickhouse.password | quote }}
- name: CH_CLUSTER
  value: "{{ .Values.global.components.clickhouse.cluster | default "default_cluster" }}"
{{- end }}
# ---------- 微信第三方平台信息 ----------
- name: WECHAT_COMPONENT_APP_ID
  value: {{ index .Values.global.wechat.componentAppId | quote }}
- name: WECHAT_COMPONENT_APP_SECRET
  value: {{ index .Values.global.wechat.componentAppSecret | quote }}
- name: WECHAT_COMPONENT_TOKEN
  value: {{ index .Values.global.wechat.componentToken | quote }}
- name: WECHAT_COMPONENT_AES_KEY
  value: {{ index .Values.global.wechat.componentAesKey | quote }}
{{- end -}}

{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.host }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.host }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        cos.{{ .Values.global.components.s3.cos.region }}.{{.Values.global.components.s3.cos.domain}}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_resource_url" -}}
    {{- $prefix := .Values.resourcesDir | default "" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{- if $prefix -}}
            https://{{ .Values.global.components.s3.minio.host }}/{{ $prefix }}
        {{- else -}}
            https://{{ .Values.global.components.s3.minio.host }}
        {{- end -}}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{- if $prefix -}}
            https://{{ .Values.global.components.s3.csp.host }}/{{ $prefix }}
        {{- else -}}
            https://{{ .Values.global.components.s3.csp.host }}
        {{- end -}}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{- if $prefix -}}
            https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.{{.Values.global.components.s3.cos.domain}}/{{ $prefix }}
        {{- else -}}
            https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.{{.Values.global.components.s3.cos.domain}}
        {{- end -}}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_endpoint" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.host }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.host }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        cos.{{ .Values.global.components.s3.cos.region }}.{{.Values.global.components.s3.cos.domain}}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_AK" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.accessKey }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.accessKey }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{ .Values.global.components.s3.cos.secretId }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_SK" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.secretKey }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.secretKey }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{ .Values.global.components.s3.cos.secretKey }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_bucket" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.bucket }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.bucket }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{ .Values.global.components.s3.cos.bucket }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}