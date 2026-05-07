{{/*
获取 ProductType 值
TKE 环境返回 1，其他环境返回 2
*/}}
{{- define "getProductType" -}}
{{- $isTKE := false -}}
{{- $nodes := lookup "v1" "Node" "" "" -}}
{{- if $nodes -}}
  {{- range $nodes.items -}}
    {{- range $key, $value := .metadata.labels -}}
      {{- if contains "tke.cloud.tencent" $key -}}
        {{- $isTKE = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if $isTKE -}}
1
{{- else -}}
2
{{- end -}}
{{- end -}}
