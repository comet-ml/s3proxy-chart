{{- /*
This chart uses the comet-common library chart
(https://github.com/comet-ml/common-helm-chart) directly for naming, labels, and
image rendering: call sites use comet-common.names.*, comet-common.labels.base,
and comet-common.images.image. Only s3proxy-specific helpers live in this file.

s3proxy.selectorLabels is kept local rather than using comet-common.selectorLabels:
the latter adds app.kubernetes.io/component, and a Deployment's
spec.selector.matchLabels is immutable, so adopting it would break `helm upgrade`
on existing releases.
*/}}

{{- /*
Selector labels. The immutable Deployment selector stays {name, instance}; the
name value is sourced from comet-common for consistency.
*/}}
{{- define "s3proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "comet-common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- /*
Container/Service port name: "https" when native TLS is enabled (S3Proxy binds a
secure-endpoint), otherwise "http". Shared by service.yaml and deployment.yaml
(port + tcpSocket probes) so the port name tracks the actual protocol.
*/}}
{{- define "s3proxy.portName" -}}
  {{- ternary "https" "http" .Values.config.tls.enabled -}}
{{- end }}

{{- /*
Backend credential existingSecrets as data ({name, backend, prop, secret, key}), so
deployment.yaml renders the mounts/volumes with one range. <backend> matches the
backend-<name>.properties filename; <prop> is the jclouds key the initContainer writes.
*/}}
{{- define "s3proxy.externalBackendSecrets" -}}
{{- $b := .Values.config.backends -}}
{{- $out := list -}}
  {{- if and $b.s3.enabled $b.s3.secretAccessKey.existingSecret -}}
    {{- $out = append $out (dict "name" "s3-credential" "backend" "s3" "prop" "jclouds.credential" "secret" $b.s3.secretAccessKey.existingSecret "key" $b.s3.secretAccessKey.secretKey) -}}
  {{- end -}}
  {{- if and $b.azureblob.enabled $b.azureblob.key.existingSecret -}}
    {{- $out = append $out (dict "name" "azureblob-credential" "backend" "azureblob" "prop" "jclouds.credential" "secret" $b.azureblob.key.existingSecret "key" $b.azureblob.key.secretKey) -}}
  {{- end -}}
  {{- if and $b.azureblob.enabled $b.azureblob.sasToken.existingSecret -}}
    {{- $out = append $out (dict "name" "azureblob-sas" "backend" "azureblob" "prop" "jclouds.session-token" "secret" $b.azureblob.sasToken.existingSecret "key" $b.azureblob.sasToken.secretKey) -}}
  {{- end -}}
  {{- if and $b.openstackSwift.enabled $b.openstackSwift.password.existingSecret -}}
    {{- $out = append $out (dict "name" "openstack-swift-credential" "backend" "openstack-swift" "prop" "jclouds.credential" "secret" $b.openstackSwift.password.existingSecret "key" $b.openstackSwift.password.secretKey) -}}
  {{- end -}}
{{- $out | toJson -}}
{{- end }}
