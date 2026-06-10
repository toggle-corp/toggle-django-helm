{{/*
    Expand the name of the chart.
*/}}
{{- define "banjo.name" -}}
    {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
    Create a default fully qualified app name.
    We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
    If release name contains chart name it will be used as a full name.
    https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names
*/}}
{{- define "banjo.fullname" -}}
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
{{- define "banjo.chart" -}}
    {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "banjo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "banjo.fullname" .) .Values.serviceAccountName }}
{{- else }}
{{- default "default" .Values.serviceAccountName }}
{{- end }}
{{- end }}

{{/*
Create the name of the secret provider class
*/}}
{{- define "banjo.secretProviderName" -}}
{{- if .Values.secretsStoreCsiDriverProviderName }}
  {{- .Values.secretsStoreCsiDriverProviderName -}}
{{- else }}
  {{- printf "%s-secret-provider" (include "banjo.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the secret
*/}}
{{- define "banjo.secretname" -}}
{{- if .Values.secretsName }}
  {{- .Values.secretsName -}}
{{- else }}
  {{- printf "%s-secret" (include "banjo.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the configmap
*/}}
{{- define "banjo.envConfigMapName" -}}
{{- if .Values.envConfigMapName }}
  {{- .Values.envConfigMapName -}}
{{- else }}
  {{- printf "%s-env-name" (include "banjo.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Generate image metadata
*/}}
{{- define "banjo.imageConfig" -}}
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
{{- with $merged.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Generate resources metadata
*/}}
{{- define "banjo.resourcesConfig" -}}
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
{{- define "banjo.envFromTemplate" -}}
- secretRef:
    name: {{ template "banjo.secretname" . }}
{{- if .Values.extraSecretsName }}
- secretRef:
    name: {{ .Values.extraSecretsName }}
{{- end }}
- configMapRef:
    name: {{ template "banjo.envConfigMapName" . }}
{{- if .Values.extraConfigMapName }}
- configMapRef:
    name: {{ .Values.extraConfigMapName }}
{{- end }}
{{- end }}

{{/*
Generate env configs for app types
*/}}
{{- define "banjo.envTemplate" -}}
- name: {{ .Values.appTypeEnvName }}
  value: {{ .Type | quote }}
{{- if .Values.extraEnvVars }}
{{ toYaml .Values.extraEnvVars }}
{{- end }}
{{- end }}

{{/*
Merge per-component extraEnv maps (defaults + override) and render as a k8s env array.
Override wins per key. Values are tpl-evaluated against the root context.
Usage: include "banjo.extraEnvBlock" (dict "Default" $defaultsBlock "Override" $itemBlock "Context" $)
*/}}
{{- define "banjo.extraEnvBlock" -}}
{{- $default := default dict (default dict .Default).extraEnv -}}
{{- $override := default dict (default dict .Override).extraEnv -}}
{{- $merged := merge (dict) $override $default -}}
{{- range $k, $v := $merged }}
- name: {{ $k }}
  value: {{ tpl (toString $v) $.Context | quote }}
{{- end }}
{{- end }}

{{/*
Generate default annotations for app deployments
*/}}
{{- define "banjo.appDefaultDeploymentAnnotations" -}}
annotations:
  reloader.stakater.com/auto: "true"
{{- end }}

{{/*
Generate default annotations for app pods
*/}}
{{- define "banjo.appDefaultAnnotations" -}}
checksum/secret: {{ include (print .Template.BasePath "/config/secret.yaml") . | sha256sum }}
checksum/configmap: {{ include (print .Template.BasePath "/config/configmap.yaml") . | sha256sum }}
{{- with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate default labels for app deployments
*/}}
{{- define "banjo.appDefaultLabels" -}}
{{- with .Values.podLabels -}}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Generate default volumes for app deployments
*/}}
{{- define "banjo.appDefaultVolumes" -}}
{{- if or .Values.secretsStoreCsiDriver.create .Values.podVolumes -}}
volumes:
{{- if .Values.secretsStoreCsiDriver.create }}
  - name: {{ template "banjo.secretname" . }}
    csi:
      driver: "secrets-store.csi.k8s.io"
      readOnly: true
      volumeAttributes:
        secretProviderClass: {{ template "banjo.secretProviderName" . }}
{{- end }}
{{- if .Values.podVolumes }}
{{ .Values.podVolumes | toYaml | indent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate default volumes mounts for app deployments
*/}}
{{- define "banjo.appDefaultVolumeMounts" -}}
{{- if or .Values.secretsStoreCsiDriver.create .Values.podVolumeMounts -}}
volumeMounts:
{{- if .Values.secretsStoreCsiDriver.create }}
  - name: {{ template "banjo.secretname" . }}
    mountPath: /mnt/secrets-store
    readOnly: true
{{- end }}
{{- if .Values.podVolumeMounts }}
{{ .Values.podVolumeMounts | toYaml | indent 2 }}
{{- end }}
{{- end }}
{{- end }}
