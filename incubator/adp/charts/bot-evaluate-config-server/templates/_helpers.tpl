{{- define "storage" -}}
{{- if eq .Values.global.components.s3.providerType "minio" }}
type: minio
min_io_map:
  offline:
    secret_id: {{ .Values.global.components.s3.minio.secretId }}
    secret_key: {{ .Values.global.components.s3.minio.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ .Values.global.components.s3.minio.host }}
    end_point: {{ .Values.global.components.s3.minio.host }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
  realtime:
    secret_id: {{ .Values.global.components.s3.minio.secretId }}
    secret_key: {{ .Values.global.components.s3.minio.secretKey }}
    region: ""
    bucket: qbot
    sts_endpoint: http://{{ .Values.global.components.s3.minio.host }}
    end_point: {{ .Values.global.components.s3.minio.host }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
    credential_time: 10m
{{- else if eq .Values.global.components.s3.providerType "obs" }}
type: obs
obs_map:
  offline:
    secret_id: {{ .Values.global.components.s3.obs.secretId }}
    secret_key: {{ .Values.global.components.s3.obs.secretKey }}
    region: {{ .Values.global.components.s3.obs.region }}
    bucket: qbot
    sts_endpoint: {{ .Values.global.scheme }}://{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}
    end_point: {{ .Values.global.components.s3.obs.host }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
    credential_time: 10m
  realtime:
    secret_id: {{ .Values.global.components.s3.obs.secretId }}
    secret_key: {{ .Values.global.components.s3.obs.secretKey }}
    region: {{ .Values.global.components.s3.obs.region }}
    bucket: qbot
    sts_endpoint: {{ .Values.global.scheme }}://{{ .Values.global.components.s3.obs.host }}:{{ .Values.global.components.s3.obs.port }}
    end_point: {{ .Values.global.components.s3.obs.host }}
    use_https: {{ eq .Values.global.scheme "https" }}
    expire_time: 30m
    credential_time: 10m
{{- else if eq .Values.global.components.s3.providerType "csp" }}
type: csp
csp_map:
  offline:
    secret_id: {{ .Values.global.components.s3.csp.secretId }}
    secret_key: {{ .Values.global.components.s3.csp.secretKey }}
    region: {{ .Values.global.components.s3.csp.region }}
    bucket: qbot
    end_point: {{ .Values.global.components.s3.csp.host }}
    protocol: http
    batchnum: 10
    use_path_style: true
    expire_time: 30m
    credential_time: 10m
  realtime:
    secret_id: {{ .Values.global.components.s3.csp.secretId }}
    secret_key: {{ .Values.global.components.s3.csp.secretKey }}
    region: {{ .Values.global.components.s3.csp.region }}
    bucket: qbot
    end_point: {{ .Values.global.components.s3.csp.host }}
    protocol: http
    batchnum: 10
    use_path_style: true
    expire_time: 30m
    credential_time: 10m
{{- else }}
type: cos
cos_map:
  offline:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    app_id: {{ printf "%.0f" .Values.global.components.s3.cos.appId | quote }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: {{ .Values.global.components.s3.cos.bucket }}
    domain: {{ .Values.global.components.s3.cos.domain }}
    expire_time: 30m
    credential_time: 10m
  realtime:
    secret_id: {{ .Values.global.components.s3.cos.secretId }}
    secret_key: {{ .Values.global.components.s3.cos.secretKey }}
    app_id: {{ printf "%.0f" .Values.global.components.s3.cos.appId | quote }}
    region: {{ .Values.global.components.s3.cos.region }}
    bucket: {{ .Values.global.components.s3.cos.bucket }}
    domain: {{ .Values.global.components.s3.cos.domain }}
    expire_time: 30m
    credential_time: 10m
{{- end }}
{{- end }}


{{- define "client.http_cos" -}}
{{- if eq .Values.global.components.s3.providerType "minio" }}
target: ip://minio.ti-inf.svc.cluster.local:80
{{- else }}
target: dns://cos-internal.{{ .Values.global.components.s3.cos.region }}.tencentcos.cn
{{- end }}
{{- end }}
