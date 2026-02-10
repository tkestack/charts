{{- define "qbot.thoughtIcon" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/thinking.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/thinking.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/thinking.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/thinking.png
  {{- end -}}
{{- end -}}