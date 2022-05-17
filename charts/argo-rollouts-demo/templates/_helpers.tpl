#######################################################
###############        GENERAL       ##################
#######################################################

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to
this (by the DNS naming spec). If release name contains chart name it will
be used as a full name.
*/}}
{{- define "project.fullname" -}}
{{- if ne (.Values.global.projectName | toString) "" -}}
{{- .Values.global.projectName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "web.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "web.name" -}}
{{- default .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

#######################################################
###############         WEB          ##################
#######################################################
{{/*
Sets extra web labels
*/}}
{{- define "web.labels" -}}
  {{- if .Values.web.labels }}
    {{- $tp := typeOf .Values.web.labels }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.web.labels . | nindent 4 }}
    {{- else }}
      {{- toYaml .Values.web.labels | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets extra web labels
*/}}
{{- define "web.template.labels" -}}
  {{- if .Values.web.labels }}
    {{- $tp := typeOf .Values.web.labels }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.web.labels . | nindent 8 }}
    {{- else }}
      {{- toYaml .Values.web.labels | nindent 8 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets extra web annotations
*/}}
{{- define "web.template.annotations" -}}
  {{- if .Values.web.annotations }}
      annotations:
    {{- $tp := typeOf .Values.web.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.web.annotations . | nindent 8 }}
    {{- else }}
      {{- toYaml .Values.web.annotations | nindent 8 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "web.replicas" -}}
  {{ if eq .mode "ha" }}
    {{- .Values.web.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Inject extra environment vars in the format key:value, if populated
*/}}
{{- define "web.extraEnvironmentVars" -}}
{{- if .extraEnvironmentVars -}}
{{- range $key, $value := .extraEnvironmentVars }}
- name: {{ printf "%s" $key | replace "." "_" | upper | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end -}}
{{- end -}}
{{/*
Inject extra environment populated by secrets, if populated
*/}}
{{- define "web.extraSecretEnvironmentVars" -}}
{{- if .extraSecretEnvironmentVars -}}
{{- range .extraSecretEnvironmentVars }}
- name: {{ .envName }}
  valueFrom:
   secretKeyRef:
     name: {{ .secretName }}
     key: {{ .secretKey }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Set's the node selector for pod placement when running in standalone and HA modes.
*/}}
{{- define "web.nodeselector" -}}
{{- end -}}


{{/*
Set's the affinity for pod placement when running in standalone and HA modes.
*/}}
{{- define "web.affinity" -}}
{{- end -}}

{{/*
Sets extra ingress annotations
*/}}
{{- define "web.ingress.annotations" -}}
  {{- if .Values.web.ingress.annotations }}
  annotations:
    {{- tpl .Values.web.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Set's the container resources if the user has set any.
*/}}
{{- define "web.resources" -}}
  {{- if .Values.web.resources -}}
          resources:
{{ toYaml .Values.web.resources | indent 12}}
  {{ else }}
  {{ end }}
{{- end -}}

{{/*
Set's up configmap or secrets mounts.
*/}}
{{- define "web.volumes" -}}
    {{ if .Values.web.extraVolumes }}
      volumes:
      {{- range .Values.web.extraVolumes  }}
        - name: {{ .name  }}
          {{ .type }}:
          {{- if (eq .type "configMap") }}
            name: {{ .name  }}
          {{- else if (eq .type "secret") }}
            secretName: {{ .name }}
          {{- end }}
      {{- end }}
    {{ end }}
{{- end -}}

{{/*
Set's which additional volumes should be mounted to the container.
*/}}
{{- define "web.mounts" -}}
  {{ if .Values.web.extraVolumes }}
          volumeMounts:
    {{- range .Values.web.extraVolumes }}
          - name: {{ .name }}
            readOnly: false
            mountPath: {{ .path | default "/usr/src/app/storage" }}
            {{ if .subPath }}
            subPath: {{ .subPath }}
            {{ end }}
    {{- end }}
  {{- end }}
{{- end -}}