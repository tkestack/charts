{{/* ######### KAS related templates */}}

{{- define "gitlab.kas.mountSecrets" -}}
{{- if .Values.global.kas.enabled -}}
# mount secret for kas
- secret:
    name: {{ template "gitlab.kas.secret" . }}
    items:
      - key: {{ template "gitlab.kas.key" . }}
        path: kas/.gitlab_kas_secret
{{- end -}}
{{- end -}}{{/* "gitlab.kas.mountSecrets" */}}

{{/*
Returns the KAS hostname.
If the hostname is set in `global.hosts.kas.name`, that will be returned,
otherwise the hostname will be assembed using `kas` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.kas.hostname" -}}
{{- coalesce .Values.global.hosts.kas.name (include "gitlab.assembleHost"  (dict "name" "kas" "context" . )) -}}
{{- end -}}
