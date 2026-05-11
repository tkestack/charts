{{- define "qbot.s3_storage" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
      type: minio
      minio:
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
      obs:
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
        sts_endpoint: {{ .Values.global.scheme }}://{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}:{{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "port" }}
        end_point: {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
        use_https: {{ eq .Values.global.scheme "https" }}
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
      {{- end -}}
{{- end -}}