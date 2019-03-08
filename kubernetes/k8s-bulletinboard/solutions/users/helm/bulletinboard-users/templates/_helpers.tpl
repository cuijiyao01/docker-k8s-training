{{/* vim: set filetype=mustache: */}}
{{/*
Complete tages for labels selectors etc.
*/}}
{{- define "tags.users.app" }}
component: {{ .Values.App.Component }}
module: {{ .Values.App.Module }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Complete metaclass labels entry
*/}}
{{- define "labels.users.app" }}
  labels:
    heritage: {{ .Release.Service | quote }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- include "tags.users.app" . | indent 4 }}    
{{- end -}}

{{/*
Complete tages for labels selectors etc.
*/}}
{{- define "tags.users.db" }}
component: {{ .Values.Db.Component }}
module: {{ .Values.Db.Module }}
release: {{ .Release.Name }}
{{- end -}}

{{/*
Complete metaclass labels entry
*/}}
{{- define "labels.users.db" }}
  labels:
    heritage: {{ .Release.Service | quote }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- include "tags.users.db" . | indent 4 }}    
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
{{- tpl (.Files.Get "initdb.txt") . | b64enc }}
{{- end -}}

{{/*
template for initdb sql secret
*/}}
{{- define "vcap-services.encoded" -}}
{{- tpl (.Files.Get "files/VCAP_SERVICES.string") . | b64enc }}
{{- end -}}


{{- define "db-name" -}}
{{- include "add-release-name" (dict "dot" . "name" .Values.Db.Name) -}}
{{- end -}}

{{/*
template for db connection
*/}}
{{- define "db-connection" -}}
{{- printf "%s-0.%s" (include "db-name" .) (include "add-release-name" (dict "dot" . "name" .Values.Db.ServiceName)) -}}
{{- end -}}



