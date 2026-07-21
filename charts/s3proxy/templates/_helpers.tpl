{{- /*
These helpers wrap the comet-common library chart
(https://github.com/comet-ml/common-helm-chart) so naming, labels, and image
rendering stay consistent across Comet charts. Call sites keep using the
s3proxy.* names; only the implementations delegate to comet-common.

Selector labels are the one exception kept local: comet-common.selectorLabels
adds app.kubernetes.io/component, and a Deployment's spec.selector.matchLabels is
immutable, so adopting it would break `helm upgrade` on existing releases.
*/}}

{{- /*
Expand the name of the chart.
*/}}
{{- define "s3proxy.name" -}}
{{- include "comet-common.names.name" . -}}
{{- end }}

{{- /*
Create a default fully qualified app name.
*/}}
{{- define "s3proxy.fullname" -}}
{{- include "comet-common.names.fullname" . -}}
{{- end }}

{{- /*
Create chart name and version as used by the chart label.
*/}}
{{- define "s3proxy.chart" -}}
{{- include "comet-common.names.chart" . -}}
{{- end }}

{{- /*
Common labels (comet-common base set: name, chart, instance, managed-by, version).
*/}}
{{- define "s3proxy.labels" -}}
{{ include "comet-common.labels.base" . }}
{{- end }}

{{- /*
Selector labels. Kept local so the immutable Deployment selector stays
{name, instance}; the name value is sourced from comet-common for consistency.
*/}}
{{- define "s3proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "comet-common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- /*
Create the name of the service account to use.
*/}}
{{- define "s3proxy.serviceAccountName" -}}
{{- include "comet-common.names.serviceAccount" . -}}
{{- end }}
