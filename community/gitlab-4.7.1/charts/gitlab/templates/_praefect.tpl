{{/*
Return the default praefect storage line for gitlab.yml
*/}}
{{- define "gitlab.praefect.storages" -}}
default:
  path: /var/opt/gitlab/repo
{{- $scheme := "tcp" -}}
{{- $port := include "gitlab.praefect.externalPort" $ -}}
{{- if $.Values.global.praefect.tls.enabled -}}
{{- $scheme = "tls" -}}
{{- $port = include "gitlab.praefect.tls.externalPort" $ -}}
{{- end }}
  gitaly_address: {{ printf "%s" $scheme }}://{{ template "gitlab.praefect.serviceName" $ }}.{{.Release.Namespace}}.svc:{{ $port }}
{{- end -}}

{{/*
Return the resolvable name of the praefect service
*/}}
{{- define "gitlab.praefect.serviceName" -}}
{{- coalesce .Values.serviceName .Values.global.praefect.serviceName (printf "%s-praefect" $.Release.Name) -}}
{{- end -}}

{{/*
Return a list of Gitaly pod names
*/}}
{{- define "gitlab.praefect.gitalyPodNames" -}}
{{ range until ($.Values.global.praefect.gitalyReplicas | int) }}{{ printf "%s-gitaly-%d" $.Release.Name . }},{{- end}}
{{- end -}}
