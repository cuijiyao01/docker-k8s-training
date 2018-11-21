{{/*
Complete tages for labels selectors etc.
*/}}
{{- define "tags.ads.db" }}
component: {{ .Values.Db.Component }}
module: {{ .Values.Db.Module }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Complete metaclass labels entry
*/}}
{{- define "labels.ads.db" }}
  labels:
    heritage: {{ .Release.Service | quote }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- include "tags.ads.db" . | indent 4 }}    
{{- end -}}

{{/*
Ads release name prefix to string and truncates to 63 chars.
Used for Names of Chart entities
*/}}
{{- define "add-release-name" -}}
{{- $name := index . "name" -}}
{{- $dot := index . "dot" -}}
{{- printf "%s-%s" $dot.Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
template for initdb sql secret
*/}}
{{- define "initdb.encoded" -}}
{{- tpl (.Files.Get "initdb.txt") . | b64enc}}
{{- end -}}

{{/*
template for applications-k8s secret
*/}}
{{- define "applicationsk8s.encoded" -}}
{{- tpl (.Files.Get "applications-k8s.txt") . | b64enc}}
{{- end -}}

{{/*
template for db connection
*/}}
{{- define "db-connection" -}}
{{- printf "%s-0.%s" (include "add-release-name" (dict "dot" . "name" .Values.Db.StatefulsetName)) (include "add-release-name" (dict "dot" . "name" .Values.Db.ServiceName)) -}}
{{- end -}}

{{/*
This is bonus to make the chart "complete".
*/}}

{{/*
Complete tages for labels selectors etc.
*/}}
{{- define "tags.ads.app" }}
component: {{ .Values.App.Component }}
module: {{ .Values.App.Module }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Complete metaclass labels entry
*/}}
{{- define "labels.ads.app" }}
  labels:
    heritage: {{ .Release.Service | quote }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- include "tags.ads.app" . | indent 4 }}    
{{- end -}}


