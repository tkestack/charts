{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.host }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.host }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_port" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.port | quote }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.port | quote }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}


{{- define "storage.Access" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    ip://{{ .Values.global.components.s3.minio.host }}:{{ .Values.global.components.s3.minio.port }}
  {{- else if eq .Values.global.components.s3.providerType "csp" -}}
    ip://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    ip://{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}
  {{- else -}}
    dns://cos-internal.{{ .Values.global.components.s3.cos.region }}.tencentcos.cn
  {{- end -}}
{{- end -}}

{{- define "knowledge.icon" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/app-icon-knowledge_qa.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/app-icon-knowledge_qa.png
  {{- else if eq .Values.global.components.s3.providerType "csp" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/app-icon-knowledge_qa.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/app-icon-knowledge_qa.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/app-icon-knowledge_qa.png
  {{- end -}}
{{- end -}}

{{- define "robot.avatar" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/avatar.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/avatar.png
  {{- else if eq .Values.global.components.s3.providerType "csp" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/avatar.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/avatar.png
  {{- else -}}
    https://qbot-1251316161.cos.ap-nanjing.myqcloud.com/avatar.png
  {{- end -}}
{{- end -}}

{{- define "summary.icon" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/app-icon-summary.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/app-icon-summary.png
  {{- else if eq .Values.global.components.s3.providerType "csp" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/app-icon-summary.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/app-icon-summary.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/app-icon-summary.png
  {{- end -}}
{{- end -}}

{{- define "classify.icon" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/app-icon-classify.png
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/app-icon-classify.png
  {{- else if eq .Values.global.components.s3.providerType "csp" -}}
    {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/app-icon-classify.png
  {{- else if eq .Values.global.components.s3.providerType "cos" -}}
    https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/app-icon-classify.png
  {{- else -}}
    https://cdn.xiaowei.qq.com/static/lke/app-icon-classify.png
  {{- end -}}
{{- end -}}




