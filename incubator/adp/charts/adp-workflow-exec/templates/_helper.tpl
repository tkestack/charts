{{- define "qbot.s3_storage" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
      type: minio
      min_io_map:
        default:
          secret_id: cspuser
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: ""
          bucket: qbot
          # TODO 替换 MINIO 访问地址
          sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          external_end_point: {{ .Values.global.clb }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
          credential_time: 10m
      {{- else if eq .Values.global.components.s3.providerType "obs" -}}
      type: obs
      obs_map:
        default:
          secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
          secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
          region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
          bucket: qbot
          sts_endpoint: {{ .Values.global.scheme }}://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
          credential_time: 10m
      {{- else if eq .Values.global.components.s3.providerType "csp" -}}
      type: csp
      csp:
        default:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: qbot
          sts_endpoint: {{ .Values.global.scheme }}://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
          credential_time: 10m
      {{- else -}}
      type: cos
      cos_map:
        default:
          secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
          secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
          app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
          region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
          bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
          domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
          expire_time: 30m
          credential_time: 10m
          # AssumeRole STS 配置：仅当 global.components.s3.cos.enableSts=true 时启用
          # role_arn 非空 + 主凭证（环境变量 ADP_ASSUME_ROLE_SECRET_ID/_KEY 由 K8s Secret 注入）
          # 三者齐全时 IsValid()=true，业务自动切换为 STS 临时凭证模式
          assume_role:
            role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
            duration_seconds: 43200
            refresh_ahead_seconds: 300
      {{- end -}}
{{- end -}}