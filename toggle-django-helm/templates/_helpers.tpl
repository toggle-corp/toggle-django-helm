{{/*
    Expand the name of the chart.
*/}}
{{- define "django-app.name" -}}
    {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
    Create a default fully qualified app name.
    We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
    If release name contains chart name it will be used as a full name.
    https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names
*/}}
{{- define "django-app.fullname" -}}
    {{- if .Values.fullnameOverride -}}
        {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
        {{- $name := default .Chart.Name .Values.nameOverride -}}
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
{{- define "django-app.chart" -}}
    {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "django-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "django-app.fullname" .) .Values.serviceAccountName }}
{{- else }}
{{- default "default" .Values.serviceAccountName }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret to be used by the django-app
*/}}
{{- define "django-app.secretname" -}}
{{- if .Values.secretsName }}
  {{- .Values.secretsName -}}
{{- else }}
  {{- printf "%s-secret" (include "django-app.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the configmap to be used by the django-app
*/}}
{{- define "django-app.envConfigMapName" -}}
{{- if .Values.envConfigMapName }}
  {{- .Values.envConfigMapName -}}
{{- else }}
  {{- printf "%s-env-name" (include "django-app.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Generate image metadata
*/}}
{{- define "django-app.imageConfig" -}}
{{- $default := deepCopy .Default -}}
{{- $override := deepCopy (default dict .Override) -}}
{{- $merged := (
    merge
        (dict)
        $override
        $default
    )
-}}
image: "{{ printf "%s:%s" $merged.name $merged.tag }}"
imagePullPolicy: {{ default "IfNotPresent" $merged.imagePullPolicy }}
{{- end }}

{{/*
Generate resources metadata
*/}}
{{- define "django-app.resourcesConfig" -}}
{{- $default := deepCopy .Default -}}
{{- $override := deepCopy (default dict .Override) -}}
{{
     (
        merge
            (dict)
            $override
            $default
        ) | toYaml
}}
{{- end }}

{{/*
Generate env configs for deployments
*/}}
{{- define "django-app.envFromTemplate" -}}
- secretRef:
    name: {{ template "django-app.secretname" . }}
{{- if .Values.extraSecretsName }}
- secretRef:
    name: {{ .Values.extraSecretsName }}
{{- end }}
- configMapRef:
    name: {{ template "django-app.envConfigMapName" . }}
{{- if .Values.extraConfigMapName }}
- configMapRef:
    name: {{ .Values.extraConfigMapName }}
{{- end }}
{{- end }}

{{/*
Generate env configs for app types
*/}}
{{- define "django-app.envTemplate" -}}
- name: {{ .Values.appTypeEnvName }}
  value: {{ .Type | quote }}
{{- if .Values.extraEnvVars }}
{{ toYaml .Values.extraEnvVars }}
{{- end }}
{{- end }}

{{/*
Generate default annotations for app deployments
*/}}
{{- define "django-app.appDefaultAnnotations" -}}
reloader.stakater.com/auto: "true"
checksum/secret: {{ include (print .Template.BasePath "/config/secret.yaml") . | sha256sum }}
checksum/configmap: {{ include (print .Template.BasePath "/config/configmap.yaml") . | sha256sum }}
{{- with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate default labels for app deployments
*/}}
{{- define "django-app.appDefaultLabels" -}}
{{- with .Values.podLabels -}}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate default volumes for app deployments
*/}}
{{- define "django-app.appDefaultVolumes" -}}
{{- if .Values.podVolumes }}
volumes:
{{ .Values.podVolumes | toYaml | indent 2 }}
{{- end }}
{{- end }}

{{/*
Generate default volumes mounts for app deployments
*/}}
{{- define "django-app.appDefaultVolumeMounts" -}}
{{- if .Values.podVolumeMounts }}
volumeMounts:
{{ .Values.podVolumeMounts | toYaml | indent 2 }}
{{- end }}
{{- end }}
