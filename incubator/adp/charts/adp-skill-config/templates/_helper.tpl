{{- define "qbot.s3_storage" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
      type: cos
      cos:
        secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
        secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
        app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
        region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
        bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
        domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
        expire_time: 30m
        # AssumeRole STS 配置：仅当 global.components.s3.cos.stsKey 非空时启用
        # role_arn 非空 + 主凭证（环境变量 ADP_ASSUME_ROLE_SECRET_ID/_KEY 由 K8s Secret 注入）
        # 三者齐全时 IsValid()=true，业务自动切换为 STS 临时凭证模式
        assume_role:
          role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
          duration_seconds: 43200
          refresh_ahead_seconds: 300
      cos_map:
        default:
          secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
          secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
          app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
          region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
          bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
          domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
          expire_time: 30m
          # AssumeRole STS 配置：仅当 global.components.s3.cos.stsKey 非空时启用
          # role_arn 非空 + 主凭证（环境变量 ADP_ASSUME_ROLE_SECRET_ID/_KEY 由 K8s Secret 注入）
          # 三者齐全时 IsValid()=true，业务自动切换为 STS 临时凭证模式
          assume_role:
            role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
            duration_seconds: 43200
            refresh_ahead_seconds: 300
        offline:
          secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
          secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
          app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
          region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
          bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
          domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
          expire_time: 30m
          # AssumeRole STS 配置：仅当 global.components.s3.cos.stsKey 非空时启用
          # role_arn 非空 + 主凭证（环境变量 ADP_ASSUME_ROLE_SECRET_ID/_KEY 由 K8s Secret 注入）
          # 三者齐全时 IsValid()=true，业务自动切换为 STS 临时凭证模式
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
        sandbox:
          secret_id: ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
          secret_key: ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
          app_id: ${INFRA_MIDDLEWARES_S3_COS_APPID}
          region: ${INFRA_MIDDLEWARES_S3_COS_REGION}
          bucket: ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
          domain: ${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
          expire_time: 7776000s
          credential_time: 10m
    {{- end -}}
{{- end -}}