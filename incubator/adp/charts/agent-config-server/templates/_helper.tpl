{{- define "qbot.default_icon" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/agent-robot.png
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/agent-robot.png
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/agent-robot.png
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/agent-robot.png
    {{- else -}}
        https://cdn.xiaowei.qq.com/static/lke/agent-robot.png
     {{- end -}}
{{- end -}}


{{- define "qbot.workflow_tool_icon" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/workflow-tool.svg
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/workflow-tool.svg
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/workflow-tool.svg
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/workflow-tool.svg
    {{- else -}}
        https://qidian-qbot-1251316161.cos.ap-guangzhou.myqcloud.com/public/workflow-tool.svg
     {{- end -}}
{{- end -}}

{{- define "qbot.QQ_brower" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/plugin_files/QQ_brower.png
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/plugin_files/QQ_brower.png
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/plugin_files/QQ_brower.png
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/plugin_files/QQ_brower.png
    {{- else -}}
        https://qidian-qbot-1251316161.cos.ap-guangzhou.myqcloud.com/public/plugin_files/QQ%E6%B5%8F%E8%A7%88%E5%99%A8.png
     {{- end -}}
{{- end -}}

{{- define "qbot.pe_icon" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.clb }}/qbot/public/pe_icon.png
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.scheme }}://qbot.{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}/public/pe_icon.png
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.scheme }}://{{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}/qbot/public/pe_icon.png
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        https://{{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com/qbot/public/pe_icon.png
    {{- else -}}
        https://lke-realtime-1251316161.cos.ap-guangzhou.myqcloud.com/icon/pe_icon.png
     {{- end -}}
{{- end -}}



