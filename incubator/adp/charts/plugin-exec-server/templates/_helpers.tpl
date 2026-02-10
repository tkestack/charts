{{- define "qbot.s3_storage" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
      type: minio
      minio:
        secret_id: {{ .Values.global.components.s3.minio.secretId }}
        secret_key: {{ .Values.global.components.s3.minio.secretKey }}
        region: ""
        bucket: qbot
        # TODO 替换 MINIO 访问地址
        sts_endpoint: http://{{ .Values.global.components.s3.minio.host }}
        end_point: {{ .Values.global.components.s3.minio.host }}
        use_https: {{ eq .Values.global.scheme "https" }}
        expire_time: 30m
      {{- else if eq .Values.global.components.s3.providerType "obs" -}}
      type: obs
      obs:
        secret_id: {{ .Values.global.components.s3.obs.secretId }}
        secret_key: {{ .Values.global.components.s3.obs.secretKey }}
        region: {{ .Values.global.components.s3.obs.region }}
        bucket: qbot
        sts_endpoint: {{ .Values.global.scheme }}://{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}
        end_point: {{ .Values.global.components.s3.obs.host }}
        use_https: {{ eq .Values.global.scheme "https" }}
        expire_time: 30m
      {{- else if eq .Values.global.components.s3.providerType "csp" -}}
      type: csp
      csp:
        secret_id: {{ .Values.global.components.s3.csp.secretId }}
        secret_key: {{ .Values.global.components.s3.csp.secretKey }}
        region: {{ .Values.global.components.s3.csp.region }}
        bucket: qbot
        sts_endpoint: {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}
        end_point: {{ .Values.global.components.s3.csp.host }}
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


{{- define "adppluginexec.secret_id" -}}
  {{ .Values.global.components.s3.cos.secretId }}
{{- end -}}


{{- define "adppluginexec.secret_key" -}}
  {{ .Values.global.components.s3.cos.secretKey }}
{{- end -}}