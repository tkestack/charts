{{- define "adp-app-shorturl.storageConfig" -}}
{{- if eq .Values.global.components.s3.providerType "cos" }}
scheme:
  minio: 1
  realtime: 1
  obs: 1
type: minio
minio:
  secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
  secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
  region: ""
  bucket: qbot
  sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  external_end_point: {{ .Values.global.clb }}
  use_https: {{ eq .Values.global.scheme "https" }}
  expire_time: 30m
minio_list:
  minio:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    external_end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
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
{{- if eq .Values.global.components.s3.providerType "cos" }}
scheme:
  minio: 1
  realtime: 1
  obs: 1
  adp_default: 1
type: minio
minio:
  secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
  secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
  region: ""
  bucket: qbot
  sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
  end_point: {{ .Values.global.clb }}
  use_https: {{ eq .Values.global.scheme "https" }}
  expire_time: 30m
min_io_map:
  adp_default:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  minio:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    end_point: {{ .Values.global.clb }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
{{- end }}
{{- end -}}
