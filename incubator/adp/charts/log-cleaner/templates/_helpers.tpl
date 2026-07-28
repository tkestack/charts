{{/*
  log-cleaner - 通用标签
*/}}
{{- define "log-cleaner.labels" -}}
app: log-cleaner
app.kubernetes.io/name: log-cleaner
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "log-cleaner.selectorLabels" -}}
app: log-cleaner
app.kubernetes.io/name: log-cleaner
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
