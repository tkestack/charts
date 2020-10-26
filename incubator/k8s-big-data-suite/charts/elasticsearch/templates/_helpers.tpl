{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "uname" -}}
{{ .Values.clusterName }}-{{ .Values.nodeGroup }}
{{- end -}}

{{- define "data-paths" -}}
{{- if .Values.hostVolume.enabled }}
    {{- range $index, $path := .Values.hostVolume.paths -}}
      {{- if ne $index 0 -}}
        /usr/share/elasticsearch/data{{ $index }},
      {{- end -}}
    {{- end -}}
    {{- range $index, $path := .Values.hostVolume.paths -}}
      {{- if eq $index 0 -}}
        /usr/share/elasticsearch/data{{ $index }}
      {{- end -}}
    {{- end -}}
{{- else }}/usr/share/elasticsearch/data{{- end -}}
{{- end -}}

{{- define "data-paths-with-space" -}}
{{- if .Values.hostVolume.enabled }}
    {{- range $index, $path := .Values.hostVolume.paths -}}
        /usr/share/elasticsearch/data{{ $index }}{{ " " }}
    {{- end -}}
{{- else }}/usr/share/elasticsearch/data{{- end -}}
{{- end -}}
