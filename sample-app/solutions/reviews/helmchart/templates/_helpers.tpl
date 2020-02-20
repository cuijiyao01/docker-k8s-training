{{/* vim: set filetype=mustache: */}}
{{/*
Complete tages for labels selectors etc.
*/}}
{{- define "labels.reviews.app" }}
component: reviews
module: app
release: {{ .Release.Name }}
{{- end -}}

{{/*
Complete tages for labels selectors etc.
*/}}
{{- define "labels.reviews.db" }}
component: reviews
module: db
release: {{ .Release.Name }}
{{- end -}}


{{/*
Lables for resources.
*/}}
{{- define "labels.resources" }}
heritage: {{ .Release.Service | quote }}
revision: {{ .Release.Revision | quote }}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end -}}


