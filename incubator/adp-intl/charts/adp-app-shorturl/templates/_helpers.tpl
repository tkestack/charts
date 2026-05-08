{{- define "adp-app-shorturl.storageConfig" -}}
{{- if eq .Values.global.components.s3.providerType "obs" }}
scheme:
  minio: 1
  realtime: 1
  obs: 1
type: obs
obs:
  secret_id: {{ .Values.global.components.s3.cos.secretId }}
  secret_key: {{ .Values.global.components.s3.cos.secretKey }}
  region: {{ .Values.global.components.s3.cos.region }}
  bucket: qbot
  sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
  end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  use_https: {{ eq .Values.global.scheme "https" }}
  expire_time: 30m
obs_list:
  obs:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: qbot
    sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: qbot
    sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
{{- else }}
scheme:
  minio: 1
  realtime: 1
  obs: 1
type: minio
minio:
  secret_id: {{ .Values.global.components.s3.cos.secretId }}
  secret_key: {{ .Values.global.components.s3.cos.secretKey }}
  region: ""
  bucket: qbot
  sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  external_end_point: {{ .Values.global.clb }}
  use_https: {{ eq .Values.global.scheme "https" }}
  expire_time: 30m
minio_list:
  minio:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    external_end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    external_end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
{{- end }}
{{- end -}}

{{- define "adp-app-shorturl.s3Config" -}}
{{- if eq .Values.global.components.s3.providerType "obs" }}
scheme:
  minio: 1
  realtime: 1
  obs: 1
  adp_default: 1
type: obs
obs:
  secret_id: {{ .Values.global.components.s3.cos.secretId }}
  secret_key: {{ .Values.global.components.s3.cos.secretKey }}
  region: {{ .Values.global.components.s3.cos.region }}
  bucket: qbot
  sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
  end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  use_https: {{ eq .Values.global.scheme "https" }}
  expire_time: 30m
obs_map:
  obs:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: qbot
    sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  adp_default:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: qbot
    sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: qbot
    sts_endpoint: "http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}"
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
{{- else }}
scheme:
  minio: 1
  realtime: 1
  obs: 1
  adp_default: 1
type: minio
minio:
  secret_id: {{ .Values.global.components.s3.cos.secretId }}
  secret_key: {{ .Values.global.components.s3.cos.secretKey }}
  region: ""
  bucket: qbot
  sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  end_point: {{ .Values.global.clb }}
  use_https: {{ eq .Values.global.scheme "https" }}
  expire_time: 30m
min_io_map:
  adp_default:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  minio:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
{{- end }}
{{- end -}}
