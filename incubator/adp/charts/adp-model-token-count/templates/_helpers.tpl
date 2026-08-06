{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}

{{- define "ex.s3_port" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        fail "we don not support this type objectstorage"
    {{- end -}}
{{- end -}}