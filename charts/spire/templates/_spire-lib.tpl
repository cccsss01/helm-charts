{{- define "spire-lib.cluster-name" }}
{{- if ne (len (dig "spire" "clusterName" "" .Values.global)) 0 }}
{{- .Values.global.spire.clusterName }}
{{- else }}
{{- .Values.clusterName }}
{{- end }}
{{- end }}

{{- define "spire-lib.trust-domain" }}
{{- if ne (len (dig "spire" "trustDomain" "" .Values.global)) 0 }}
{{- .Values.global.spire.trustDomain }}
{{- else }}
{{- .Values.trustDomain }}
{{- end }}
{{- end }}

{{- define "spire-lib.bundle-configmap" }}
{{- if ne (len (dig "spire" "bundleConfigMap" "" .Values.global)) 0 }}
{{- .Values.global.spire.bundleConfigMap }}
{{- else }}
{{- .Values.bundleConfigMap }}
{{- end }}
{{- end }}

{{- define "spire-lib.cluster-domain" -}}
{{- if ne (len (dig "k8s" "clusterDomain" "" .Values.global)) 0 }}
{{- .Values.global.k8s.clusterDomain }}
{{- else }}
{{- .Values.clusterDomain }}
{{- end }}
{{- end }}

{{- define "spire-lib.registry" }}
{{- if ne (len (dig "spire" "image" "registry" "" .global)) 0 }}
{{- .global.spire.image.registry }}
{{- else }}
{{- .image.registry }}
{{- end }}
{{- end }}

{{- define "spire-lib.image" -}}
{{- $registry := include "spire-lib.registry" . }}
{{- $repo := .image.repository }}
{{- $tag := (default .image.tag .image.version) | toString }}
{{- if eq (substr 0 7 $tag) "sha256:" }}
{{- printf "%s/%s@%s" $registry $repo $tag }}
{{- else if .appVersion }}
{{- printf "%s/%s:%s" $registry $repo (default .appVersion $tag) }}
{{- else if $tag }}
{{- printf "%s/%s:%s" $registry $repo $tag }}
{{- else }}
{{- printf "%s/%s" $registry $repo }}
{{- end }}
{{- end }}

{{/*
Take in an array of, '.', a failure string to display, and boolean to to display it,
if strict checking is enabled and the boolean is true
*/}}
{{- define "spire-lib.strict-check" }}
{{ $root := index 0 }}
{{ $message := index 1 }}
{{ $condition := index 2 }}
{{- if (dig "spire" "strictChecking" false $root.Values.global) }}
{{- if $condition }}
{{- fail $message }}
{{- end }}
{{- end }}
{{- end }}
