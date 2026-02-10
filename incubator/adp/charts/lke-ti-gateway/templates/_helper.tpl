# encode the secret 
{{- define "secret.encode" -}}  
  {{- . | toString | b64enc | quote }} #{{- . | toString -}}  
{{- end -}}



{{- define "ex.acp_version" -}}
  
  {{- $isacp := (lookup "v1" "Namespace" "" "cpaas-system") -}}
  
  {{- if $isacp -}}
    {{- $acp_spec := (lookup "product.alauda.io/v1alpha1" "ProductBase" "cpaas-system" "base").spec -}}
    {{- $acp_spec.version | trimPrefix  "v" | semver -}}
  {{- else -}}
    {{- semver "0.0.1" -}}
  {{- end -}}
{{- end -}}