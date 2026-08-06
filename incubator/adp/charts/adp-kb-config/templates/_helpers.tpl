{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        cos-internal.{{ .Values.global.components.s3.cos.region }}.tencentcos.cn
    {{- end -}}
{{- end -}}

{{- define "ex.s3_port" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        {{ "443" | quote }}
    {{- end -}}
{{- end -}}

{{- define "storage.Access" -}}
  {{- if eq .Values.global.components.s3.providerType "cos" -}}
    dns://cos-internal.{{ .Values.global.components.s3.cos.region }}.tencentcos.cn
  {{- end -}}
{{- end -}}
