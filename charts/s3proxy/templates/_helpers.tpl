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
