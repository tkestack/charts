{{- define "qbot.s3_storage" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
      type: minio
      min_io_map:
        default:
          secret_id: cspuser
          secret_key: {{ .Values.global.components.s3.cos.secretKey | default "" }}
          region: ""
          bucket: qbot
          sts_endpoint: http://minio.{{ .Release.Namespace }}.svc.cluster.local
          end_point: minio.{{ .Release.Namespace }}.svc.cluster.local
          external_end_point: {{ .Values.global.clb }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
        offline:
          secret_id: cspuser
          secret_key: {{ .Values.global.components.s3.cos.secretKey | default "" }}
          region: ""
          bucket: qbot
          sts_endpoint: http://minio.{{ .Release.Namespace }}.svc.cluster.local
          end_point: minio.{{ .Release.Namespace }}.svc.cluster.local
          external_end_point: {{ .Values.global.clb }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
        realtime:
          secret_id: cspuser
          secret_key: {{ .Values.global.components.s3.cos.secretKey | default "" }}
          region: ""
          bucket: qbot
          sts_endpoint: http://minio.{{ .Release.Namespace }}.svc.cluster.local
          end_point: minio.{{ .Release.Namespace }}.svc.cluster.local
          external_end_point: {{ .Values.global.clb }}
          use_https: {{ eq .Values.global.scheme "https" }}
          expire_time: 30m
      {{- else -}}
      type: cos
      cos:
        secret_id: {{ .Values.global.components.s3.cos.secretId }}
        secret_key: {{ .Values.global.components.s3.cos.secretKey }}
        app_id: {{ .Values.global.components.s3.cos.appId | quote }}
        region: {{ .Values.global.components.s3.cos.region }}
        bucket: {{ .Values.global.components.s3.cos.bucket }}
        domain: {{ .Values.global.components.s3.cos.domain }}
        expire_time: {{ .Values.global.components.s3.cos.expireTime | default "30m" }}
      cos_map:
        default:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          app_id: {{ .Values.global.components.s3.cos.appId | quote }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: {{ .Values.global.components.s3.cos.bucket }}
          domain: {{ .Values.global.components.s3.cos.domain }}
          expire_time: {{ .Values.global.components.s3.cos.expireTime | default "30m" }}
        offline:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          app_id: {{ .Values.global.components.s3.cos.appId | quote }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: {{ .Values.global.components.s3.cos.bucket }}
          domain: {{ .Values.global.components.s3.cos.domain }}
          expire_time: {{ .Values.global.components.s3.cos.expireTime | default "30m" }}
        realtime:
          secret_id: {{ .Values.global.components.s3.cos.secretId }}
          secret_key: {{ .Values.global.components.s3.cos.secretKey }}
          app_id: {{ .Values.global.components.s3.cos.appId | quote }}
          region: {{ .Values.global.components.s3.cos.region }}
          bucket: {{ .Values.global.components.s3.cos.bucket }}
          domain: {{ .Values.global.components.s3.cos.domain }}
          expire_time: {{ .Values.global.components.s3.cos.expireTime | default "30m" }}
      {{- end -}}

{{- end -}}
