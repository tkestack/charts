{{/* ######## GitLab Pages related templates */}}

{{- define "gitlab.pages.config" -}}
pages:
  enabled: {{ or (eq $.Values.global.pages.enabled true) (not (empty $.Values.global.pages.host)) }}
  access_control: {{ eq $.Values.global.pages.accessControl true }}
  artifacts_server: {{ eq $.Values.global.pages.artifactsServer true }}
  path: {{ $.Values.global.pages.path }}
  host: {{ $.Values.global.pages.host }} # TODO: move to "gitlab.pages.host" template
  port: {{ $.Values.global.pages.port | int }}
  https: {{ eq $.Values.global.pages.https true }}
  secret_file: /etc/gitlab/pages/secret
  external_http: {{ eq $.Values.global.pages.externalHttp true }}
  external_https: {{ eq $.Values.global.pages.externalHttps true }}
  {{- if not $.Values.global.appConfig.object_store.enabled }}
  {{-   include "gitlab.appConfig.objectStorage.configuration" (dict "name" "pages" "config" $.Values.global.pages.objectStore "context" $ ) | nindent 2 }}
  {{- end }}
{{- end -}}

{{- define "gitlab.pages.mountSecrets" }}
{{- if or (eq $.Values.global.pages.enabled true) (not (empty $.Values.global.pages.host)) }}
- secret:
    name: {{ template "gitlab.pages.apiSecret.secret" . }}
    items:
      - key: {{ template "gitlab.pages.apiSecret.key" . }}
        path: pages/secret
{{- end -}}
{{- end -}}
