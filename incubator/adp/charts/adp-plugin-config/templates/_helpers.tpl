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
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
        offline:
          secret_id: cspuser
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: ""
          bucket: qbot
          # TODO 替换 MINIO 访问地址
          sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
        realtime:
          secret_id: cspuser
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: ""
          bucket: qbot
          # TODO 替换 MINIO 访问地址
          sts_endpoint: http://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
      {{- else if eq .Values.global.components.s3.providerType "obs" -}}
      type: obs
      obs_map:
        default:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: qbot
          sts_endpoint: {{ .Values.global.scheme }}://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
        offline:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: qbot
          sts_endpoint: {{ .Values.global.scheme }}://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
        realtime:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: qbot
          sts_endpoint: {{ .Values.global.scheme }}://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}
          end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
      {{- else if eq .Values.global.components.s3.providerType "csp" -}}
      type: csp
      csp:
        secret_id: {{ .Values.global.components.s3.cos.secretId }}
        secret_key: {{ .Values.global.components.s3.cos.secretKey }}
        region: {{ .Values.global.components.s3.cos.region }}
        bucket: qbot
        end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
        protocol: http
        batchnum: 10
        use_path_style: true
        expire_time: 30m
      {{- else -}}
      type: cos
      cos:
        secret_id: {{ .Values.global.components.s3.cos.secretId }}
        secret_key: {{ .Values.global.components.s3.cos.secretKey }}
        app_id: {{ printf "%.0f" .Values.global.components.s3.cos.appId | quote }}
        region: {{ .Values.global.components.s3.cos.region }}
        bucket: {{ .Values.global.components.s3.cos.bucket }}
        domain: {{ .Values.global.components.s3.cos.domain }}
        expire_time: 30m
      cos_map:
        default:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          app_id: {{ printf "%.0f" .Values.global.components.s3.cos.appId | quote }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: {{ .Values.global.components.s3.cos.bucket }}
          domain: {{ .Values.global.components.s3.cos.domain }}
          expire_time: 30m
          # AssumeRole STS 配置：仅当 global.components.s3.cos.stsKey 非空时启用
          # role_arn 非空 + 主凭证（环境变量 ADP_ASSUME_ROLE_SECRET_ID/_KEY 由 K8s Secret 注入）
          # 三者齐全时 IsValid()=true，业务自动切换为 STS 临时凭证模式
          assume_role:
            role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
            duration_seconds: 43200
            refresh_ahead_seconds: 300
        offline:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          app_id: {{ printf "%.0f" .Values.global.components.s3.cos.appId | quote }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: {{ .Values.global.components.s3.cos.bucket }}
          domain: {{ .Values.global.components.s3.cos.domain }}
          expire_time: 30m
          # AssumeRole STS 配置：仅当 global.components.s3.cos.stsKey 非空时启用
          # role_arn 非空 + 主凭证（环境变量 ADP_ASSUME_ROLE_SECRET_ID/_KEY 由 K8s Secret 注入）
          # 三者齐全时 IsValid()=true，业务自动切换为 STS 临时凭证模式
          assume_role:
            role_arn: {{ .Values.global.components.s3.cos.stsRoleArn | quote }}
            duration_seconds: 43200
            refresh_ahead_seconds: 300
        realtime:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          app_id: {{ printf "%.0f" .Values.global.components.s3.cos.appId | quote }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: {{ .Values.global.components.s3.cos.bucket }}
          domain: {{ .Values.global.components.s3.cos.domain }}
          expire_time: 30m
      {{- end -}}
{{- end -}}