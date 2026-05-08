{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ index .Values.global.objectstorage (.Values.global.components.s3.providerType) "host" }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.objectstorage.csp.host }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_port" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ "80" | quote }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.objectstorage.csp.port | quote }}
    {{- else -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}