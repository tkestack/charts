{{/* ######### Gitaly related templates */}}

{{/*
Return gitaly host for internal statefulsets
*/}}
{{- define "gitlab.gitaly.storage.internal" -}}
{{-   $releaseName := .Release.Name -}}
{{-   range $i, $storage := .Values.global.gitaly.internal.names -}}
{{-     $qualServiceName := (include "gitlab.gitaly.qualifiedServiceName" (dict "index" $i "context" $ ) ) -}}
{{-     printf "%s:\n" $storage -}}
{{-     printf  "path: /var/opt/gitlab/repo\n" | indent 2 -}}
{{-     if $.Values.global.gitaly.tls.enabled }}
{{-       printf "gitaly_address: tls://%s.%s.svc:%d\n" $qualServiceName $.Release.Namespace 8076 -}}
{{-     else }}
{{-       printf "gitaly_address: tcp://%s.%s.svc:%d\n" $qualServiceName $.Release.Namespace 8075 -}}
{{-     end -}}
{{-   end -}}
{{- end }}


{{/*
Return gitaly storage for external hosts
*/}}
{{- define "gitlab.gitaly.storage.external" -}}
{{-   range $i, $storage := .Values.global.gitaly.external -}}
{{-     printf "%s:\n" $storage.name -}}
{{-     printf  "path: /var/opt/gitlab/repo\n" | indent 2 -}}
{{-     if include "gitlab.boolean.local" (dict "global" $.Values.global.gitaly.tls.enabled "local" $storage.tlsEnabled "default" false) }}
{{-       printf "gitaly_address: tls://%s:%d\n" $storage.hostname (default 8076 $storage.port | int64) -}}
{{-     else }}
{{-       printf "gitaly_address: tcp://%s:%d\n" $storage.hostname (default 8075 $storage.port | int64) -}}
{{-     end -}}
{{-   end -}}
{{- end -}}


{{/*
Return the gitaly storages list
*/}}
{{- define "gitlab.gitaly.storages" -}}
{{- /* Create default entry when gitaly host specified */ -}}
{{-   if .Values.global.gitaly.host -}}
default:
  path: /var/opt/gitlab/repo
  {{-   if $.Values.global.gitaly.tls.enabled }}
  gitaly_address: {{ printf "tls://%s:%d" .Values.global.gitaly.host (default 8076 .Values.global.gitaly.port | int64 ) }}
  {{-   else }}
  gitaly_address: {{ printf "tcp://%s:%d" .Values.global.gitaly.host (default 8075 .Values.global.gitaly.port | int64 ) }}
  {{-   end -}}
{{-   else -}}
{{- /* global.gitaly host is not specified */ -}}
{{-     if .Values.global.gitaly.enabled }}
{{- /* Internal default repo */ -}}
{{        template "gitlab.gitaly.storage.internal" . }}
{{-     end -}}
{{-     if .Values.global.gitaly.external -}}
{{- /* External repos */ -}}
{{        template "gitlab.gitaly.storage.external" . }}
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Return the number of replicas set for Gitaly statefulset
*/}}
{{- define "gitlab.gitaly.replicas" -}}
{{-   if .Values.global.gitaly.host }} 0 {{- else if .Values.global.praefect.enabled }}{{ .Values.global.praefect.gitalyReplicas }}{{- else }} {{ len .Values.global.gitaly.internal.names }} {{- end }}
{{- end -}}


{{- define "gitlab.gitaly.storageNames" -}}
{{- if $.Values.global.praefect.enabled -}}
{{ range until ($.Values.global.praefect.gitalyReplicas | int) }} {{ printf "%s-gitaly-%d" $.Release.Name . | quote }}, {{- end }}
{{- else -}}
{{- range (coalesce $.Values.internal.names $.Values.global.gitaly.internal.names) }} {{ . | quote }}, {{- end }}
{{- end -}}
{{- end -}}

{{/* 
Return the appropriate block for the Gitaly client secret.
This differs depending on whether or not Praefect is enabled
*/}}
{{- define "gitlab.gitaly.clientSecret" -}}
{{- $secret := include "gitlab.gitaly.authToken.secret" . }}
{{- $key := include "gitlab.gitaly.authToken.key" . }}
{{- if $.Values.global.praefect.enabled -}}
{{- $secret = include "gitlab.praefect.authToken.secret" . }}
{{- $key = include "gitlab.praefect.authToken.key" . }}
{{- end -}}
name: {{ $secret }}
items:
  - key: {{ $key }}
{{- end -}}
