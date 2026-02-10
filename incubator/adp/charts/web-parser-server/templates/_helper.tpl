{{- define "web-parser-server.cos.secretId" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.secretId }}
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.components.s3.obs.secretId }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.secretId }}
    {{- else -}}
        {{ .Values.global.components.s3.cos.secretId }}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.secretKey" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ .Values.global.components.s3.minio.secretKey }}
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.components.s3.obs.secretKey }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.secretKey }}
    {{- else -}}
        {{ .Values.global.components.s3.cos.secretKey }}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.bucket" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        qbot
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        qbot
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        qbot
    {{- else -}}
        {{ .Values.global.components.s3.cos.bucket }}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.endpoint" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{- $host := .Values.global.components.s3.minio.host -}}
        {{- $port := .Values.global.components.s3.minio.port -}}
        {{- if $port -}}
            {{ $host }}:{{ $port }}
        {{- else -}}
            {{ $host }}
        {{- end -}}
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.components.s3.csp.host }}:{{ .Values.global.components.s3.csp.port }}
    {{- else -}}
        cos.{{ .Values.global.components.s3.cos.region }}.{{ .Values.global.components.s3.cos.domain }}
    {{- end -}}
{{- end -}}

{{- define "web-parser-server.cos.protocol" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        http
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.scheme }}
    {{- else if eq .Values.global.components.s3.providerType "csp" -}}
        {{ .Values.global.scheme }}
    {{- else -}}
        https
    {{- end -}}
{{- end -}}
