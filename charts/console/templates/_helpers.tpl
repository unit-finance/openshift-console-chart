{{/*
Expand the name of the chart.
*/}}
{{- define "openshift-console.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openshift-console.fullname" -}}
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
{{- define "openshift-console.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openshift-console.labels" -}}
helm.sh/chart: {{ include "openshift-console.chart" . }}
{{ include "openshift-console.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openshift-console.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openshift-console.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "openshift-console.authnKey" -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "openshift-console.fullname" . ) -}}
{{- $authnKey := default (randAlphaNum 32 | b64enc) .Values.secrets.oidcCookiesEncryption.authnKey -}}
{{- if $existing.data -}}
  {{- if $existing.data.authnKey -}}
    {{ " " $existing.data.authnKey }}
  {{- else -}}
    {{- $authnKey | indent 1 }}
  {{- end }}
{{- else -}}
  {{- $authnKey | indent 1  }}
{{- end }}
{{- end }}

{{- define "openshift-console.encryptKey" -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace (include "openshift-console.fullname" . ) -}}
{{- $encryptKey := default (randAlphaNum 32 | b64enc) .Values.secrets.oidcCookiesEncryption.encryptKey -}}
{{- if $existing.data -}}
  {{- if $existing.data.encryptKey -}}
    {{- $existing.data.encryptKey }}
  {{- else -}}
    {{- $encryptKey | indent 1 }}
  {{- end }}
{{- else -}}
  {{- $encryptKey | indent 1 }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "openshift-console.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "openshift-console.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}