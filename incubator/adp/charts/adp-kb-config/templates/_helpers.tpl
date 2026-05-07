{{- define "ex.s3_host" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        minio.{{ .Release.Namespace }}.svc.cluster.local
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.components.s3.obs.host }}
    {{- else -}}
        cos-internal.{{ .Values.global.components.s3.cos.region }}.tencentcos.cn
    {{- end -}}
{{- end -}}

{{- define "ex.s3_port" -}}
    {{- if eq .Values.global.components.s3.providerType "minio" -}}
        {{ "80" | quote }}
    {{- else if eq .Values.global.components.s3.providerType "obs" -}}
        {{ .Values.global.components.s3.obs.port | quote }}
    {{- else -}}
        {{ "443" | quote }}
    {{- end -}}
{{- end -}}


{{- define "storage.Access" -}}
  {{- if eq .Values.global.components.s3.providerType "minio" -}}
    ip://minio.{{ .Release.Namespace }}.svc.cluster.local:80
  {{- else if eq .Values.global.components.s3.providerType "obs" -}}
    ip://{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}
  {{- else -}}
    dns://cos-internal.{{ .Values.global.components.s3.cos.region }}.tencentcos.cn
  {{- end -}}
{{- end -}}
