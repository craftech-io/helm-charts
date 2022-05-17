
###############################################################
###############         CANARY TEMPLATES       ################
###############################################################

{{/*
Sets Canary steps
*/}}
{{- define "canary.steps" -}}
  {{- if .Values.rollout.canary }}
      steps:
      {{- $tp := typeOf .Values.rollout.canary.steps }}
      {{- if eq $tp "string" }}
      {{- tpl .Values.rollout.canary.steps . | nindent 6 }}
      {{- else }}
      {{- toYaml .Values.rollout.canary.steps | nindent 6 }}
      {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets Canary stableMetadata
*/}}
{{- define "canary.stableMetadata" -}}
      {{- if .Values.rollout.canary.stableMetadata }}
      # metadata which will be attached to the stable pods
      stableMetadata:
        {{- if and .Values.rollout.canary.stableMetadata .Values.rollout.canary.stableMetadata.annotations }}
        annotations:
          {{- $tp := typeOf .Values.rollout.canary.stableMetadata.annotations }}
          {{- if eq $tp "bool" }}
          {{- tpl .Values.rollout.canary.stableMetadata.annotations . | nindent 8 }}
          {{- else }}
          role: stable
          {{- end }}
        {{- end }}
        {{- if and .Values.rollout.canary.stableMetadata .Values.rollout.canary.stableMetadata.labels }}
        labels:
          {{- $tp := typeOf .Values.rollout.canary.stableMetadata.labels }}
          {{- if eq $tp "bool" }}
          {{- tpl .Values.rollout.canary.stableMetadata.labels . | nindent 8 }}
          {{- else }}
          role: stable
          {{- end }}
        {{- end }}
        {{- else }}     
      stableMetadata:
        annotations:
          role: stable
        labels:
          role: stable
      {{- end -}}
{{- end -}}

{{/*
Sets Canary canaryMetadata
*/}}
{{- define "canary.canaryMetadata" -}}
      {{- if .Values.rollout.canary.canaryMetadata }}
      # metadata which will be attached to the stable pods
      canaryMetadata:
        {{- if and .Values.rollout.canary.canaryMetadata .Values.rollout.canary.canaryMetadata.annotations }}
        annotations:
          {{- $tp := typeOf .Values.rollout.canary.canaryMetadata.annotations }}
          {{- if eq $tp "string" }}
          {{- tpl .Values.rollout.canary.canaryMetadata.annotations . | nindent 8 }}
          {{- else }}
          role: canary
          {{- end }}
        {{- end }}
        {{- if and .Values.rollout.canary.canaryMetadata .Values.rollout.canary.canaryMetadata.labels }}
        labels:
          {{- $tp := typeOf .Values.rollout.canary.canaryMetadata.labels }}
          {{- if eq $tp "string" }}
          {{- tpl .Values.rollout.canary.canaryMetadata.labels . | nindent 8 }}
          {{- else }}        
          role: canary
          {{- end }}
        {{- end }}
      {{- else }}     
      canaryMetadata:
        annotations:
          role: canary
        labels:
          role: canary
      {{- end -}}
{{- end -}}

{{/*
Sets Canary maxUnavailable
*/}}
{{- define "canary.maxUnavailable" -}}
      {{- if .Values.rollout.canary.maxUnavailable }}
      # The maximum number of pods that can be unavailable during the update.
      # Value can be an absolute number (ex: 5) or a percentage of total pods
      # at the start of update (ex: 10%). Absolute number is calculated from
      # percentage by rounding down. This can not be 0 if  MaxSurge is 0. By
      # default, a fixed value of 1 is used. Example: when this is set to 30%,
      # the old RC can be scaled down by 30% immediately when the rolling
      # update starts. Once new pods are ready, old RC can be scaled down
      # further, followed by scaling up the new RC, ensuring that at least 70%
      # of original number of pods are available at all times during the
      # update. +optional
      maxUnavailable: {{ .Values.rollout.canary.maxUnavailable }}
      {{- end }}
{{- end -}}

{{/*
Sets Canary maxSurge
*/}}
{{- define "canary.maxSurge" -}}
      {{- if .Values.rollout.canary.maxSurge }}
      # The maximum number of pods that can be scheduled above the original
      # number of pods. Value can be an absolute number (ex: 5) or a
      # percentage of total pods at the start of the update (ex: 10%). This
      # can not be 0 if MaxUnavailable is 0. Absolute number is calculated
      # from percentage by rounding up. By default, a value of 1 is used.
      # Example: when this is set to 30%, the new RC can be scaled up by 30%
      # immediately when the rolling update starts. Once old pods have been
      # killed, new RC can be scaled up further, ensuring that total number
      # of pods running at any time during the update is at most 130% of
      # original pods. +optional      
      maxSurge:  {{ .Values.rollout.canary.maxSurge }}
      {{- end }}
{{- end -}}

{{/*
Sets Canary scaleDownDelaySeconds
*/}}
{{- define "canary.scaleDownDelaySeconds" -}}
      {{- if .Values.rollout.canary.scaleDownDelaySeconds }}
      # Adds a delay before scaling down the previous ReplicaSet when the
      # canary strategy is used with traffic routing (default 30 seconds).
      # A delay in scaling down the previous ReplicaSet is needed after
      # switching the stable service selector to point to the new ReplicaSet,
      # in order to give time for traffic providers to re-target the new pods.
      # This value is ignored with basic, replica-weighted canary without
      # traffic routing.
      scaleDownDelaySeconds: {{ .Values.rollout.canary.scaleDownDelaySeconds }}
      {{- end }}
{{- end -}}

{{/*
Sets Canary scaleDownDelayRevisionLimit
*/}}
{{- define "canary.scaleDownDelayRevisionLimit" -}}
      {{- if .Values.rollout.canary.scaleDownDelayRevisionLimit }}
      # Limits the number of old RS that can run at one time before getting
      # scaled down. Defaults to nil
      scaleDownDelayRevisionLimit: {{ .Values.rollout.canary.scaleDownDelayRevisionLimit }}
      {{- end }}
{{- end -}}

{{/*
Sets Canary antiAffinity
*/}}
{{- define "canary.antiAffinity" -}}
      {{- if .Values.rollout.canary.antiAffinity }}
      # Anti Affinity configuration between desired and previous ReplicaSet.
      # Only one must be specified
      # https://argoproj.github.io/argo-rollouts/features/anti-affinity/anti-affinity/      
      antiAffinity:
        {{ template "canary.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution" . }}
        {{ template "canary.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution" . }}
      {{- end }}
{{- end -}}

{{/*
Sets Canary antiAffinity requiredDuringSchedulingIgnoredDuringExecution
*/}}
{{- define "canary.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution" -}}
  {{- if .Values.rollout.canary.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution }}
        requiredDuringSchedulingIgnoredDuringExecution:
          weight: {{ .Values.rollout.canary.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution.weight | quote }}
  {{- end -}}
{{- end -}}

{{/*
Sets Canary antiAffinity preferredDuringSchedulingIgnoredDuringExecution
*/}}
{{- define "canary.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution" -}}
  {{- if .Values.rollout.canary.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution }}
        preferredDuringSchedulingIgnoredDuringExecution:
          weight: {{ .Values.rollout.canary.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution.weight | quote }}
  {{- end -}}
{{- end -}}


{{/*
Sets Canary dynamicStableScale
*/}}
{{- define "canary.dynamicStableScale" -}}
      {{- if .Values.rollout.canary.dynamicStableScale }}
      # It is possible to dynamically reduce the scale of the stable ReplicaSet 
      # during an update such that it scales down as the traffic weight increases to canary.
      # Set true or false +optional      
      dynamicStableScale:  {{ .Values.rollout.canary.dynamicStableScale }}
      {{- end }}
{{- end -}}

{{/*
Sets Canary abortScaleDownDelaySeconds
*/}}
{{- define "canary.abortScaleDownDelaySeconds" -}}
      {{- if .Values.rollout.canary.abortScaleDownDelaySeconds }}
      # Adds a delay before scaling down the previous ReplicaSet when the
      # canary strategy is used with traffic routing (default 30 seconds).
      # A delay in scaling down the previous ReplicaSet is needed after
      # switching the stable service selector to point to the new ReplicaSet,
      # in order to give time for traffic providers to re-target the new pods.
      # This value is ignored with basic, replica-weighted canary without
      # traffic routing.
      abortScaleDownDelaySeconds: {{ .Values.rollout.canary.abortScaleDownDelaySeconds }}
      {{- end }}
{{- end -}}

###############################################################
###############       BLUE GREEN TEMPLATES     ################
###############################################################

{{/*
Sets BlueGreen previewReplicaCount
*/}}
{{- define "blueGreen.previewReplicaCount" -}}
      {{- if .Values.rollout.blueGreen.previewReplicaCount }}
      # The number of replicas to run under the preview service before the
      # switchover. Once the rollout is resumed the new ReplicaSet will be fully
      # scaled up before the switch occurs +optional
      previewReplicaCount: {{ .Values.rollout.blueGreen.previewReplicaCount  }}     
      {{- end }}
{{- end -}}

{{/*
Sets BlueGreen autoPromotionEnabled
*/}}
{{- define "blueGreen.autoPromotionEnabled" -}}
      {{- if .Values.rollout.blueGreen.autoPromotionEnabled }}
      # autoPromotionEnabled disables automated promotion of the new stack by pausing the rollout
      # immediately before the promotion. If omitted, the default behavior is to promote the new
      # stack as soon as the ReplicaSet are completely ready/available.
      # Rollouts can be resumed using: `kubectl argo rollouts promote ROLLOUT`
      autoPromotionEnabled: {{ .Values.rollout.blueGreen.autoPromotionEnabled  }}
      {{- end }}
{{- end -}}

{{/*
Sets BlueGreen autoPromotionSeconds
*/}}
{{- define "blueGreen.autoPromotionSeconds" -}}
      {{- if .Values.rollout.blueGreen.autoPromotionSeconds }}
      # Automatically promotes the current ReplicaSet to active after the
      # specified pause delay in seconds after the ReplicaSet becomes ready.
      # If omitted, the Rollout enters and remains in a paused state until
      # manually resumed by resetting spec.Paused to false. +optional
      autoPromotionSeconds: {{ int .Values.rollout.blueGreen.autoPromotionSeconds }}
      {{- end }}
{{- end -}}

{{/*
Sets BlueGreen scaleDownDelaySeconds
*/}}
{{- define "blueGreen.scaleDownDelaySeconds" -}}
      {{- if .Values.rollout.blueGreen.scaleDownDelaySeconds }}
      # Adds a delay before scaling down the previous ReplicaSet. If omitted,
      # the Rollout waits 30 seconds before scaling down the previous ReplicaSet.
      # A minimum of 30 seconds is recommended to ensure IP table propagation
      # across the nodes in a cluster.
      scaleDownDelaySeconds: {{ int .Values.rollout.blueGreen.scaleDownDelaySeconds }}
      {{- end }}
{{- end -}}

{{/*
Sets BlueGreen scaleDownDelayRevisionLimit
*/}}
{{- define "blueGreen.scaleDownDelayRevisionLimit" -}}
      {{- if .Values.rollout.blueGreen.scaleDownDelayRevisionLimit }}
      # Limits the number of old RS that can run at once before getting scaled
      # down. Defaults to nil
      scaleDownDelayRevisionLimit: {{ .Values.rollout.blueGreen.scaleDownDelayRevisionLimit }}
      {{- end }}
{{- end -}}

{{/*
Sets BlueGreen abortScaleDownDelaySeconds
*/}}
{{- define "blueGreen.abortScaleDownDelaySeconds" -}}
      {{- if .Values.rollout.blueGreen.abortScaleDownDelaySeconds }}
      # Adds a delay before scaling down the previous ReplicaSet when the
      # canary strategy is used with traffic routing (default 30 seconds).
      # A delay in scaling down the previous ReplicaSet is needed after
      # switching the stable service selector to point to the new ReplicaSet,
      # in order to give time for traffic providers to re-target the new pods.
      # This value is ignored with basic, replica-weighted canary without
      # traffic routing.
      abortScaleDownDelaySeconds: {{ .Values.rollout.blueGreen.abortScaleDownDelaySeconds }}
      {{- end }}
{{- end -}}


{{/*
Sets BlueGreen antiAffinity
*/}}
{{- define "blueGreen.antiAffinity" -}}
      {{- if .Values.rollout.blueGreen.antiAffinity }}
      # Anti Affinity configuration between desired and previous ReplicaSet.
      # Only one must be specified
      # https://argoproj.github.io/argo-rollouts/features/anti-affinity/anti-affinity/      
      antiAffinity:
        {{ template "blueGreen.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution" . }}
        {{ template "blueGreen.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution" . }}
      {{- end }}
{{- end -}}

{{/*
Sets BlueGreen antiAffinity requiredDuringSchedulingIgnoredDuringExecution
*/}}
{{- define "blueGreen.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution" -}}
  {{- if .Values.rollout.blueGreen.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution }}
        requiredDuringSchedulingIgnoredDuringExecution:
          weight: {{ .Values.rollout.blueGreen.antiAffinity.requiredDuringSchedulingIgnoredDuringExecution.weight  }}
  {{- end -}}
{{- end -}}

{{/*
Sets BlueGreen antiAffinity preferredDuringSchedulingIgnoredDuringExecution
*/}}
{{- define "blueGreen.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution" -}}
  {{- if .Values.rollout.blueGreen.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution }}
        preferredDuringSchedulingIgnoredDuringExecution:
          weight: {{ .Values.rollout.blueGreen.antiAffinity.preferredDuringSchedulingIgnoredDuringExecution.weight }}
  {{- end -}}
{{- end -}}

{{/*
Sets BlueGreen Ingress Annotations
*/}}
{{- define "blueGreen.ingressPreview.annotations" -}}
  {{- if .Values.rollout.blueGreen.ingressPreview.annotations }}
  annotations:
    {{- tpl .Values.rollout.blueGreen.ingressPreview.annotations . | nindent 4 }}
  {{- else }}
  annotations:
    {{- tpl .Values.web.ingress.annotations . | nindent 4 }}
  {{- end }}
{{- end -}}