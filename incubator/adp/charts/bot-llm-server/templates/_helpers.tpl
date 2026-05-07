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