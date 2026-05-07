{{- define "getProductType" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.productType -}}
            {{- .Values.global.productType -}}
        {{- else -}}
            lke
        {{- end -}}
    {{- else -}}
        lke
    {{- end -}}
{{- end -}}