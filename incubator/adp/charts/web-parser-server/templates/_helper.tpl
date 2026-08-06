{{- define "web-parser-server.cos.secretId" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        ${INFRA_MIDDLEWARES_S3_COS_SECRETID}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.secretKey" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        ${INFRA_MIDDLEWARES_S3_COS_SECRETKEY}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.bucket" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        ${INFRA_MIDDLEWARES_S3_COS_BUCKET}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.endpoint" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        cos.${INFRA_MIDDLEWARES_S3_COS_REGION}.${INFRA_MIDDLEWARES_S3_COS_DOMAIN}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.protocol" -}}
    {{- if eq .Values.global.components.s3.providerType "cos" -}}
        https
    {{- end -}}
{{- end -}}
