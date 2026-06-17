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
Render livenessProbe/readinessProbe/startupProbe from a merged probes block.
Merges Default + Override (override wins per key, like banjo.resourcesConfig),
then — only if merged.enabled is truthy — emits the probe keys from
merged.liveness / .readiness / .startup, each rendered verbatim (any field of
corev1.Probe is passthrough). Emits nothing when disabled or no probes set.
Usage: include "banjo.probesConfig" (dict "Default" $defaults.probes "Override" $item.probes)
*/}}
{{- define "banjo.probesConfig" -}}
{{- $merged := merge (dict) (default dict .Override) (default dict .Default) -}}
{{- if $merged.enabled -}}
{{- $out := list -}}
{{- with $merged.liveness -}}
{{- $out = append $out (printf "livenessProbe:\n%s" (toYaml . | indent 2)) -}}
{{- end -}}
{{- with $merged.readiness -}}
{{- $out = append $out (printf "readinessProbe:\n%s" (toYaml . | indent 2)) -}}
{{- end -}}
{{- with $merged.startup -}}
{{- $out = append $out (printf "startupProbe:\n%s" (toYaml . | indent 2)) -}}
{{- end -}}
{{- join "\n" $out -}}
{{- end -}}
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
Normalize a dict-OR-array map block into a YAML list of {name, ...spec} entries.
- Dict form: keys become "name"; values are merged in as the rest of the spec.
- Array form: each entry must already have "name". Returned verbatim.
- nil/empty: returns nothing.
Usage: include "banjo.dictOrArray" $value  →  yaml-formatted list
*/}}
{{- define "banjo.dictOrArray" -}}
{{- $value := . -}}
{{- if kindIs "map" $value -}}
{{- $list := list -}}
{{- range $k, $v := $value -}}
{{- $entry := dict "name" $k -}}
{{- if kindIs "map" $v -}}
{{- range $kk, $vv := $v -}}
{{- $entry = set $entry $kk $vv -}}
{{- end -}}
{{- end -}}
{{- $list = append $list $entry -}}
{{- end -}}
{{- toYaml $list -}}
{{- else if kindIs "slice" $value -}}
{{- toYaml $value -}}
{{- end -}}
{{- end }}

{{/*
Resolve a per-workload dict-or-array block (volumes / volumeMounts) into a YAML list
of {name, ...spec} entries, merging defaults with the per-item override.
- Dict form (both default + override are maps): merged by NAME, per-item wins (like
  banjo.resourcesConfig / banjo.extraEnvBlock). Each key becomes "name".
- Array form (override is a slice): per-item array wholesale-resets, ignoring defaults
  (same semantics as queues/addons themselves).
- nil/empty on both sides: returns nothing.
Parse the result with fromYamlArray to get a list value.
Usage: include "banjo.namedListConfig" (dict "Default" $defaultBlock "Override" $itemBlock)
*/}}
{{- define "banjo.namedListConfig" -}}
{{- $override := .Override -}}
{{- if kindIs "slice" $override -}}
{{- include "banjo.dictOrArray" $override -}}
{{- else -}}
{{- $merged := merge (dict) (default dict $override) (default dict .Default) -}}
{{- include "banjo.dictOrArray" $merged -}}
{{- end -}}
{{- end }}

{{/*
Render the top-level .Values.extraEnvVars as a k8s pod env array.
Accepts either dict (keyed by env-var name) or array (with explicit name: field).
Dict-form values are full k8s env-var specs minus name (use {value: ...} or {valueFrom: ...}).
*/}}
{{- define "banjo.envVarsBlock" -}}
{{- $vars := .Values.extraEnvVars -}}
{{- if $vars -}}
{{ include "banjo.dictOrArray" $vars }}
{{- end -}}
{{- end }}

{{/*
Generate env configs for app types
*/}}
{{- define "banjo.envTemplate" -}}
- name: {{ .Values.appTypeEnvName }}
  value: {{ .Type | quote }}
{{- with (include "banjo.envVarsBlock" (dict "Values" .Values)) }}
{{ . }}
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
Generate default volumes for app deployments.
Usage: include "banjo.appDefaultVolumes" (dict "Context" $ "Extra" <list>)
  Context: root context.
  Extra (optional): list of fully-formed volume maps (each already including "name"),
    concatenated after the CSI volume + .Values.podVolumes.
*/}}
{{- define "banjo.appDefaultVolumes" -}}
{{- $ := .Context -}}
{{- $extra := default (list) .Extra -}}
{{- if or $.Values.secretsStoreCsiDriver.create $.Values.podVolumes $extra -}}
volumes:
{{- if $.Values.secretsStoreCsiDriver.create }}
  - name: {{ template "banjo.secretname" $ }}
    csi:
      driver: "secrets-store.csi.k8s.io"
      readOnly: true
      volumeAttributes:
        secretProviderClass: {{ template "banjo.secretProviderName" $ }}
{{- end }}
{{- if $.Values.podVolumes }}
{{ $.Values.podVolumes | toYaml | indent 2 }}
{{- end }}
{{- if $extra }}
{{ $extra | toYaml | indent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate default volumes mounts for app deployments.
Usage: include "banjo.appDefaultVolumeMounts" (dict "Context" $ "Extra" <list>)
  Context: root context.
  Extra (optional): list of fully-formed volumeMount maps (each already including "name"),
    concatenated after the CSI mount + .Values.podVolumeMounts.
*/}}
{{- define "banjo.appDefaultVolumeMounts" -}}
{{- $ := .Context -}}
{{- $extra := default (list) .Extra -}}
{{- if or $.Values.secretsStoreCsiDriver.create $.Values.podVolumeMounts $extra -}}
volumeMounts:
{{- if $.Values.secretsStoreCsiDriver.create }}
  - name: {{ template "banjo.secretname" $ }}
    mountPath: /mnt/secrets-store
    readOnly: true
{{- end }}
{{- if $.Values.podVolumeMounts }}
{{ $.Values.podVolumeMounts | toYaml | indent 2 }}
{{- end }}
{{- if $extra }}
{{ $extra | toYaml | indent 2 }}
{{- end }}
{{- end }}
{{- end }}
