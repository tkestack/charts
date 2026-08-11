{{/*
Expand the name of the chart.
*/}}
{{- define "agent-portal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "agent-portal.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "agent-portal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "agent-portal.labels" -}}
helm.sh/chart: {{ include "agent-portal.chart" . }}
{{ include "agent-portal.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "agent-portal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "agent-portal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "agent-portal.name" . }}
{{- end }}

{{/*
Runtime configuration Secret name
*/}}
{{- define "agent-portal.secretName" -}}
{{- printf "%s-env" (include "agent-portal.fullname" .) }}
{{- end }}

{{/*
Image reference
*/}}
{{- define "agent-portal.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | default .Chart.AppVersion) }}
{{- end }}

{{/*
Built-in ADP platform-manager RSA public key for activation-code decrypt.
Users do not need to fill this; leave LICENSE_PUBLIC_KEY empty in values.
*/}}
{{- define "agent-portal.defaultLicensePublicKey" -}}
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAurReoU7qNrUu+hVIiCLM
yXfOUZIODPMuR9xphD8S+/Df8DDj40lVOgU3sh0sghFmkhva71fji+N+a279wsjd
MDBd5ZO7hBApxOdm82TUVnx1be+PhvIkChDKIbOlZJ+GG/gbZsrbCzR+1yHI6h5u
DmumU4WRGpBg28/6quJ2nl1GUWJAjNCtGdPozJ0Q2Gm0nq1MrQPf5fjBzxJ2GI83
iM8We8MyeNQO/iAbr+iUqG1XsjD4QqDUUqcgBYRGexS0HHuGYrDWEUvkBnsgqdpR
zVgqxxJhsDCz7IiqFaTugJJDIoH2/uPJ4rAwSxko481Li1VCKpQQ6KN2mM7cMEeK
nGakkgkI0OI5znUgC5vBoprUkEO0pk1JcaIrEnEZm5pZCrBJsSbCLQLbiDReSe7q
XTO54hyFiHv1huweQB5psL/2O0WvKcSM4H4zgAWSSEatxZ/MKD8ESmjgLcUg6KFo
8aGyRNJLv3+nE7qMLagJDtt0Gqinutu/SXwurj75+Xb2DQWD5JGvkwvvlt5Muvcd
2HjdhWqwM5sR37a58YK3Rd/M+XqFpOjgXQ1si3m1CyXGAOscgm4/p5pFBgUOjmfI
tyqsHyMMdAugX6Duo20FkKZwC/gPtAeNYso/Vxt0wRifIrJZPUkdTTOPcmtx+a+6
+8Dhq8soyKlm51Dc6ia0cUECAwEAAQ==
-----END PUBLIC KEY-----
{{- end }}
