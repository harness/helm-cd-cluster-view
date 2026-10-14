{{/*
Expand the name of the chart.
*/}}
{{- define "service-discovery-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "service-discovery-agent.fullname" -}}
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
Namespace where the agent runs and namespaced resources are created.
*/}}
{{- define "service-discovery-agent.agentNamespace" -}}
{{- default .Release.Namespace .Values.agentNamespace }}
{{- end }}

{{/*
Name of the service account to use. When serviceAccount.create is false this
is the externally managed account supplied by the user.
*/}}
{{- define "service-discovery-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else if .Values.serviceAccount.create }}
{{- include "service-discovery-agent.fullname" . }}
{{- else }}
{{- fail "serviceAccount.name must be set when serviceAccount.create is false" }}
{{- end }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "service-discovery-agent.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "service-discovery-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
harness.io/component: service-discovery
harness.io/created-by: service-discovery-server
{{- if .Values.commonLabels }}
{{- toYaml .Values.commonLabels | nindent 0 }}
{{- end }}
{{- end }}

{{/*
Common annotations applied to all resources.
*/}}
{{- define "service-discovery-agent.annotations" -}}
{{- if .Values.commonAnnotations }}
{{- toYaml .Values.commonAnnotations }}
{{- end }}
{{- end }}
