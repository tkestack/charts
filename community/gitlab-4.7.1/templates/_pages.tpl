{{/* ######### gitlab-pages related templates */}}

{{/*
Return the gitlab-pages secret
*/}}

{{- define "gitlab.pages.apiSecret.secret" -}}
{{- default (printf "%s-gitlab-pages-secret" .Release.Name) $.Values.global.pages.apiSecret.secret | quote -}}
{{- end -}}

{{- define "gitlab.pages.apiSecret.key" -}}
{{- default "shared_secret" $.Values.global.pages.apiSecret.key | quote -}}
{{- end -}}
