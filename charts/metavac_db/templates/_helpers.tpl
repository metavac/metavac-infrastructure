{{/*
Expand the name of the chart.
*/}}
{{- define "metavac-db.name" -}}
{{- default .Chart.Name .Values.nameOverride .Values.global.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metavac-db.fullname" -}}
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
{{- define "metavac-db.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metavac-db.labels" -}}
helm.sh/chart: {{ include "metavac-db.chart" . }}
{{ include "metavac-db.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metavac-db.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metavac-db.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "metavac-db.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "metavac-db.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the namespace to deploy to
*/}}
{{- define "metavac-db.namespace" -}}
{{- default "default" .Values.global.namespace .Release.namespace }}
{{- end }}

{{/*
Mongo Connection URL to deploy to
*/}}
{{- define "metavac-db.mongo.url" -}}
{{- .Values.db.url }}
{{- end }}

{{/*
Mongo Database name to deploy to
*/}}
{{- define "metavac-db.mongo.name" -}}
{{- .Values.db.name }}
{{- end }}

{{/*
Mongo Database ca_cert_file_path
*/}}
{{- define "metavac-db.mongo.ca_cert_file_path" -}}
{{- tpl .Values.global.cert_mongo_dir . }}/ca.crt
{{- end }}

{{/*
Mongo Database key_file_path
*/}}
{{- define "metavac-db.mongo.key_file_path" -}}
{{ tpl .Values.global.cert_mongo_dir . }}/id.pem
{{- end }}