{{- define "qbot.hunyuanIconUrl" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/hunyuan.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/hunyuan.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/hunyuan.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/hunyuan.png
  {{- end -}}
{{- end -}}



{{- define "qbot.avatarIconUrl" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/avatar.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/avatar.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/avatar.png
  {{- else -}}
    https://qbot-1251316161.cos.ap-nanjing.myqcloud.com/avatar.png
  {{- end -}}
{{- end -}}


{{- define "qbot.dsIconUrl" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/ds.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/ds.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/ds.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/ds.png
  {{- end -}}
{{- end -}}



{{- define "qbot.app-default-avatar" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/app-default-avatar.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/app-default-avatar.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/app-default-avatar.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/app-default-avatar.png
  {{- end -}}
{{- end -}}