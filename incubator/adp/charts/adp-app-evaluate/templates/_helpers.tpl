{{- define "storage" -}}
{{- if eq .Values.global.components.s3.providerType "cos" }}
cos_map:
  offline:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
    region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
    bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
    domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
    expire_time: 30m
    credential_time: 10m
    assume_role:
      role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
      duration_seconds: 43200
      refresh_ahead_seconds: 300
  realtime:
    secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
    region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
    bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
    domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
    expire_time: 30m
    credential_time: 10m
    assume_role:
      role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
      duration_seconds: 43200
      refresh_ahead_seconds: 300
{{- end }}
{{- end }}