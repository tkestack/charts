{{/*
Helper functions for multi-service SQL import
*/}}


{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.host }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.host }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{ .Values.global.components.s3.cos.bucket }}.cos.{{ .Values.global.components.s3.cos.region }}.myqcloud.com
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_AK" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.accessKey }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.accessKey }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{ .Values.global.components.s3.cos.secretId }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_SK" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.secretKey }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.secretKey }}
    {{- else if eq .Values.global.components.s3.providerType "cos" -}}
        {{ .Values.global.components.s3.cos.secretKey }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}