{{/*
Expand the name of the chart.
*/}}
{{- define "metavac-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metavac-common.fullname" -}}
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
{{- define "metavac-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the namespace to deploy to
*/}}
{{- define "metavac-common.namespace" -}}
    {{- if .Release.Namespace -}}
        {{- .Release.Namespace }}
    {{- else if .Values.global.namespace -}}
        {{- .Values.global.namespace }}
    {{- else -}}
default
    {{- end -}}
{{- end -}}

{{/*
Webhook name configuration
*/}}
{{- define "metavac-common.webhook.app_name" -}}
{{- .Values.webhook.name }}-webhook
{{- end -}}

{{/*
Webhook name configuration
*/}}
{{- define "metavac-common.webhook.app_full_name" -}}
{{- include "metavac-common.fullname" . }}-{{ include "metavac-common.webhook.app_name" . }}
{{- end -}}

{{/*
Webhook name configuration
*/}}
{{- define "metavac-common.webhook.name" -}}
{{- .Values.webhook.name }}{{ .Values.webhook.domain }}
{{- end -}}

{{/*
Webhook service account name configuration
*/}}
{{- define "metavac-common.webhook.service_account.name" -}}
{{- if .Values.webhook.service_account.create -}}
{{- .Values.webhook.service_account.name }}
{{- else -}}
default-webhook-service-account
{{- end -}}
{{- end -}}

{{/*
Webhook CA certificate
*/}}
{{- define "metavac-common.webhook.cert" -}}
{{- .Files.Get (cat .Values.cert_source_dir "/ca.crt" | nospace) | b64enc }}
{{- end -}}

{{/*
Webhook signing key file
*/}}
{{- define "metavac-common.webhook.key" -}}
{{- .Files.Get (cat .Values.cert_source_dir "/ca.key" | nospace) | b64enc }}
{{- end -}}