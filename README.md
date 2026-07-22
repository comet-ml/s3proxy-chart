# s3proxy

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.3.0](https://img.shields.io/badge/AppVersion-3.3.0-informational?style=flat-square)

A Helm chart for deploying S3Proxy - Access other storage backends via the S3 API

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://ghcr.io/comet-ml | comet-common | 0.3.0 |

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if using filesystem backend with persistence)

## S3Proxy version compatibility

The chart tracks S3Proxy (`andrewgaul/s3proxy`) through `appVersion` (currently `3.3.0`); override it with `image.tag`. Minimum supported version is `2.7.0`.

S3Proxy `3.0.0` deprecated the Apache jclouds storage backends (`s3`, `aws-s3`, `azureblob`, `filesystem`, `transient`) in favor of SDK / NIO2 providers. Upstream has announced that `3.3.0` is the last release to bundle jclouds and that future releases "will lack its Atmos and B2 storage backends" (no jclouds-free release has shipped yet; `3.3.0` remains the latest). The jclouds providers still work on 3.x, but are deprecated:

- `filesystem` / `transient`: already default to the non-deprecated `*-nio2` variants (`nio2: true`).
- `azureblob`: **defaults to `provider: azureblob-sdk`** (the Azure SDK provider, which signs correctly against custom endpoints such as Azurite). The legacy jclouds `azureblob` provider is deprecated and mis-signs against custom endpoints; set `provider: azureblob` only if you specifically need it. On real Azure, `azureblob-sdk` may require `config.backends.azureblob.regions` for bucket creation.
- `s3`, `googleCloudStorage`, `openstackSwift`: SDK providers exist upstream (`aws-s3-sdk`, `google-cloud-storage-sdk`, `openstack-swift-sdk`). `rackspaceCloudfiles` is OpenStack-Swift-compatible and may be served by `openstack-swift-sdk`. Migrating the chart defaults to the SDK providers is tracked separately.
- `b2` (and Atmos, if ever added) are jclouds-only with **no SDK successor**. These are the backends upstream has said future releases will drop.

### Our compatibility plan

- **Through S3Proxy `3.3.0` (chart `0.x`):** all current backends, including the jclouds-only `b2`, are supported. This is where the chart sits today.
- **Guardrail:** the chart **hard-fails at render time** if `b2` (or `atmos`) is enabled while the effective S3Proxy version (`image.tag`, else `appVersion`) is greater than `3.3.0`, so an upgrade past the jclouds sunset cannot silently ship a broken backend. Pin `image.tag` to `3.3.0` or earlier, or disable the backend.
- **When S3Proxy ships its first jclouds-free release:** the chart moves to `1.x.x` (major bump), migrates the remaining backends to their SDK providers, and drops `b2`/`atmos`. Tracked in the SDK-migration follow-up.

## Installation

### Install the chart

```bash
# Install with default values (filesystem backend)
helm install my-s3proxy oci://ghcr.io/comet-ml/s3proxy

# Install with custom values
helm install my-s3proxy oci://ghcr.io/comet-ml/s3proxy -f override-values.yaml
```

## Configuration

The following section lists the configurable parameters of the s3proxy chart and their default values.

## Values

*Scroll sideways to see all columns.*

<table>
	<thead>
		<th>Key</th>
		<th>Description</th>
		<th>Type</th>
		<th>Default</th>
	</thead>
	<tbody>
		<tr>
			<td><code>affinity</code></td>
			<td>Affinity for pod assignment</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>autoscaling.enabled</code></td>
			<td>Enable HPA</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>autoscaling.maxReplicas</code></td>
			<td>Maximum number of replicas</td>
			<td><code>int</code></td>
			<td><code>100</code></td>
		</tr>
		<tr>
			<td><code>autoscaling.minReplicas</code></td>
			<td>Minimum number of replicas</td>
			<td><code>int</code></td>
			<td><code>1</code></td>
		</tr>
		<tr>
			<td><code>autoscaling.targetCPUUtilizationPercentage</code></td>
			<td>Target CPU utilization percentage</td>
			<td><code>int</code></td>
			<td><code>80</code></td>
		</tr>
		<tr>
			<td><code>config.auth.identity</code></td>
			<td>S3 Access Key ID for client authentication</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.auth.secret</code></td>
			<td>S3 Secret Access Key for client authentication</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.auth.type</code></td>
			<td>Authorization type (none, aws-v2, aws-v4, aws-v2-or-v4)</td>
			<td><code>string</code></td>
			<td><code>"aws-v4"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.account</code></td>
			<td>Storage account name</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.enabled</code></td>
			<td>Enable Azure Blob Storage backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.endpoint</code></td>
			<td>Azure endpoint</td>
			<td><code>string</code></td>
			<td><code>https://{{ .Values.config.backends.azureblob.account }}.blob.core.windows.net</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.key</code></td>
			<td>Storage account key configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"accountKey","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.key.existingSecret</code></td>
			<td>Name of existing secret containing the storage account key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.key.secretKey</code></td>
			<td>Key in the existing secret containing the storage account key</td>
			<td><code>string</code></td>
			<td><code>"accountKey"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.key.value</code></td>
			<td>Storage account key value</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.provider</code></td>
			<td>Provider type. Defaults to <code>azureblob-sdk</code> (Azure SDK): it signs correctly against custom endpoints (Azurite, Azure Gov/China, private endpoints) and is the non-deprecated provider on S3Proxy 3.x. The legacy jclouds <code>azureblob</code> provider is deprecated upstream and mis-signs against custom endpoints; on real Azure <code>azureblob-sdk</code> may require <code>regions</code> to be set for bucket creation.</td>
			<td><code>string</code></td>
			<td><code>"azureblob-sdk"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.regions</code></td>
			<td>jclouds region(s) for the backend, emitted as <code>jclouds.regions=</code>. The azureblob-sdk provider requires this on real Azure to create buckets (without it <code>aws s3 mb</code> fails with InvalidLocationConstraint / "no jclouds.regions configured"). Comma-separated for multiple. Not needed against Azurite. Leave empty to omit.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.sasToken</code></td>
			<td>SAS token configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"sasToken","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.sasToken.existingSecret</code></td>
			<td>Name of existing secret containing the SAS token</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.sasToken.secretKey</code></td>
			<td>Key in the existing secret containing the SAS token</td>
			<td><code>string</code></td>
			<td><code>"sasToken"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.sasToken.value</code></td>
			<td>SAS token value</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.account</code></td>
			<td>B2 account ID</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.applicationKey</code></td>
			<td>B2 application key configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"applicationKey","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.applicationKey.existingSecret</code></td>
			<td>Name of existing secret containing the application key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.applicationKey.secretKey</code></td>
			<td>Key in the existing secret containing the application key</td>
			<td><code>string</code></td>
			<td><code>"applicationKey"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.applicationKey.value</code></td>
			<td>Application key value</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.b2.enabled</code></td>
			<td>Enable Backblaze B2 backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.basedir</code></td>
			<td>Base directory for filesystem backend</td>
			<td><code>string</code></td>
			<td><code>"/data/s3proxy"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.credential</code></td>
			<td>jclouds credential. S3Proxy requires jclouds.credential in every backend properties file; the filesystem backend ignores the value. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.enabled</code></td>
			<td>Enable filesystem backend</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.identity</code></td>
			<td>jclouds identity. S3Proxy requires jclouds.identity in every backend properties file; the filesystem backend ignores the value, so the "local" placeholder is fine. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.nio2</code></td>
			<td>Use NIO2 implementation (filesystem-nio2) instead of standard filesystem</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.clientEmail</code></td>
			<td>Service account email or user email</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.enabled</code></td>
			<td>Enable Google Cloud Storage backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.privateKey</code></td>
			<td>Private key configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"private.key","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.privateKey.existingSecret</code></td>
			<td>Name of existing secret containing the private key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.privateKey.secretKey</code></td>
			<td>Key in the existing secret containing the private key (in PEM format)</td>
			<td><code>string</code></td>
			<td><code>"private.key"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.privateKey.value</code></td>
			<td>Private key value (in PEM format)</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.projectID</code></td>
			<td>GCP project ID</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.authURL</code></td>
			<td>Authentication URL</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.enabled</code></td>
			<td>Enable OpenStack Swift backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.password</code></td>
			<td>Password configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"password","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.password.existingSecret</code></td>
			<td>Name of existing secret containing the password</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.password.secretKey</code></td>
			<td>Key in the existing secret containing the password</td>
			<td><code>string</code></td>
			<td><code>"password"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.password.value</code></td>
			<td>Password value</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.region</code></td>
			<td>Region</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.tenantName</code></td>
			<td>Tenant name</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.userName</code></td>
			<td>Username</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.apiKey</code></td>
			<td>API key configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"apiKey","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.apiKey.existingSecret</code></td>
			<td>Name of existing secret containing the API key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.apiKey.secretKey</code></td>
			<td>Key in the existing secret containing the API key</td>
			<td><code>string</code></td>
			<td><code>"apiKey"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.apiKey.value</code></td>
			<td>API key value</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.enabled</code></td>
			<td>Enable Rackspace Cloud Files backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.region</code></td>
			<td>Region (uk or us)</td>
			<td><code>string</code></td>
			<td><code>"us"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.rackspaceCloudfiles.userName</code></td>
			<td>Username</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.accessKeyID</code></td>
			<td>S3 Access Key ID for backend</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.aws</code></td>
			<td>Use AWS-specific S3 provider (aws-s3) instead of generic S3 provider</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.enabled</code></td>
			<td>Enable S3 backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.endpoint</code></td>
			<td>S3 endpoint</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.region</code></td>
			<td>AWS region</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.secretAccessKey</code></td>
			<td>S3 Secret Access Key configuration</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"secretAccessKey","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.secretAccessKey.existingSecret</code></td>
			<td>Name of existing secret containing the secret access key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.secretAccessKey.secretKey</code></td>
			<td>Key in the existing secret containing the secret access key</td>
			<td><code>string</code></td>
			<td><code>"secretAccessKey"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.secretAccessKey.value</code></td>
			<td>Secret access key value</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.credential</code></td>
			<td>jclouds credential. S3Proxy requires jclouds.credential in every backend properties file; the transient backend ignores the value. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.enabled</code></td>
			<td>Enable transient (in-memory) backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.identity</code></td>
			<td>jclouds identity. S3Proxy requires jclouds.identity in every backend properties file; the transient backend ignores the value, so the "local" placeholder is fine. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.nio2</code></td>
			<td>Use NIO2 implementation (transient-nio2) instead of standard transient</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.buckets.alias</code></td>
			<td>Map virtual bucket names to actual backend buckets</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>config.cors.allowCredential</code></td>
			<td>Allow credentials</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.cors.allowHeaders</code></td>
			<td>Allowed headers</td>
			<td><code>list</code></td>
			<td><code>["Accept","Content-Type"]</code></td>
		</tr>
		<tr>
			<td><code>config.cors.allowMethods</code></td>
			<td>Allowed methods</td>
			<td><code>list</code></td>
			<td><code>["GET","PUT","POST","HEAD","DELETE"]</code></td>
		</tr>
		<tr>
			<td><code>config.cors.allowOrigins</code></td>
			<td>Allowed origins (e.g., ["https://example.com", "https://.+\\.example\\.com"])</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.cors.enabled</code></td>
			<td>Enable CORS support</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.logLevel</code></td>
			<td>Log level for S3Proxy (DEBUG, INFO, WARN, ERROR)</td>
			<td><code>string</code></td>
			<td><code>"INFO"</code></td>
		</tr>
		<tr>
			<td><code>config.middlewares.eventualConsistency</code></td>
			<td>Enable eventual consistency modeling</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.middlewares.largeObjectMocking</code></td>
			<td>Enable large object mocking</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.middlewares.readOnly</code></td>
			<td>Make backend read-only</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.middlewares.shardedBackend</code></td>
			<td>Enable sharded backend containers</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.tls.enabled</code></td>
			<td>Enable native in-pod HTTPS (S3Proxy <code>secure-endpoint</code>). When enabled, S3Proxy serves HTTPS only on <code>service.targetPort</code> (the plaintext endpoint is not bound), so TLS is terminated in the pod rather than at the ingress. Requires a PKCS12 (or JKS) keystore and its password. <code>tcpSocket</code> health probes are unaffected (they do not perform a TLS handshake).</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.tls.keystore.existingSecret</code></td>
			<td>Name of an existing Secret holding the keystore file (binary PKCS12/JKS). Takes precedence over <code>value</code>. Use this for a customer-provided keystore or a cert-manager-issued one (<code>Certificate.spec.keystores.pkcs12</code>).</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.tls.keystore.secretKey</code></td>
			<td>Key within <code>keystore.existingSecret</code> (or, when <code>value</code> is used, within the chart's own Secret) that holds the keystore file</td>
			<td><code>string</code></td>
			<td><code>"keystore.p12"</code></td>
		</tr>
		<tr>
			<td><code>config.tls.keystore.value</code></td>
			<td>Inline base64-encoded keystore, stored in the chart's own Secret and mounted as a file. Used only when <code>keystore.existingSecret</code> is empty. Convenient for testing; prefer <code>existingSecret</code> in production.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.tls.keystorePassword.existingSecret</code></td>
			<td>Name of an existing Secret holding the keystore password. Takes precedence over <code>value</code>.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.tls.keystorePassword.secretKey</code></td>
			<td>Key within <code>keystorePassword.existingSecret</code> that holds the keystore password</td>
			<td><code>string</code></td>
			<td><code>"keystore-password"</code></td>
		</tr>
		<tr>
			<td><code>config.tls.keystorePassword.value</code></td>
			<td>Inline keystore password, stored in the chart's own Secret and merged into the backend properties by the secret-merge initContainer (kept out of the ConfigMap). Used only when <code>keystorePassword.existingSecret</code> is empty.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.virtualHost</code></td>
			<td>Virtual Host configuration</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>configMergeImage.pullPolicy</code></td>
			<td>Config merge container image pull policy</td>
			<td><code>string</code></td>
			<td><code>"IfNotPresent"</code></td>
		</tr>
		<tr>
			<td><code>configMergeImage.repository</code></td>
			<td>Config merge container image repository</td>
			<td><code>string</code></td>
			<td><code>"busybox"</code></td>
		</tr>
		<tr>
			<td><code>configMergeImage.tag</code></td>
			<td>Config merge container image tag</td>
			<td><code>string</code></td>
			<td><code>"1.36"</code></td>
		</tr>
		<tr>
			<td><code>extraEnvVars</code></td>
			<td>Additional environment variables</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>extraVolumeMounts</code></td>
			<td>Additional volume mounts</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>extraVolumes</code></td>
			<td>Additional volumes</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>fullnameOverride</code></td>
			<td>String to fully override s3proxy.fullname template</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>image.pullPolicy</code></td>
			<td>Image pull policy</td>
			<td><code>string</code></td>
			<td><code>"IfNotPresent"</code></td>
		</tr>
		<tr>
			<td><code>image.repository</code></td>
			<td>S3Proxy image repository</td>
			<td><code>string</code></td>
			<td><code>"andrewgaul/s3proxy"</code></td>
		</tr>
		<tr>
			<td><code>image.tag</code></td>
			<td>Overrides the image tag whose default is the chart appVersion</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>imagePullSecrets</code></td>
			<td>Image pull secrets</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>ingress.annotations</code></td>
			<td>Ingress annotations</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>ingress.className</code></td>
			<td>Ingress class name</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>ingress.enabled</code></td>
			<td>Enable ingress</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>ingress.hosts</code></td>
			<td>Ingress hosts configuration</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>ingress.tls</code></td>
			<td>TLS configuration</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>nameOverride</code></td>
			<td>String to partially override s3proxy.fullname template</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>nodeSelector</code></td>
			<td>Node selector for pod assignment</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>persistence.accessMode</code></td>
			<td>PVC Access Mode</td>
			<td><code>string</code></td>
			<td><code>"ReadWriteOnce"</code></td>
		</tr>
		<tr>
			<td><code>persistence.annotations</code></td>
			<td>PVC annotations</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>persistence.enabled</code></td>
			<td>Enable persistence using PVC</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>persistence.existingClaim</code></td>
			<td>Use existing PVC</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>persistence.size</code></td>
			<td>PVC Storage Request</td>
			<td><code>string</code></td>
			<td><code>"10Gi"</code></td>
		</tr>
		<tr>
			<td><code>persistence.storageClass</code></td>
			<td>Storage Class</td>
			<td><code>string</code></td>
			<td><code>""</code> (uses default StorageClass)</td>
		</tr>
		<tr>
			<td><code>podAnnotations</code></td>
			<td>Annotations to add to the pod</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>podLabels</code></td>
			<td>Extra labels to add to the pod (merged with the chart's selector labels)</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>podSecurityContext</code></td>
			<td>Pod security context</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>replicaCount</code></td>
			<td>Number of S3Proxy replicas</td>
			<td><code>int</code></td>
			<td><code>1</code></td>
		</tr>
		<tr>
			<td><code>resources</code></td>
			<td>Resource limits and requests</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>securityContext</code></td>
			<td>Container security context</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>service.annotations</code></td>
			<td>Service annotations</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>service.port</code></td>
			<td>Service port</td>
			<td><code>int</code></td>
			<td><code>9000</code></td>
		</tr>
		<tr>
			<td><code>service.targetPort</code></td>
			<td>Target port (controls both the container port and S3Proxy bind port)</td>
			<td><code>int</code></td>
			<td><code>9000</code></td>
		</tr>
		<tr>
			<td><code>service.type</code></td>
			<td>Kubernetes service type</td>
			<td><code>string</code></td>
			<td><code>"ClusterIP"</code></td>
		</tr>
		<tr>
			<td><code>serviceAccount.annotations</code></td>
			<td>Annotations to add to the service account</td>
			<td><code>object</code></td>
			<td><code>{}</code></td>
		</tr>
		<tr>
			<td><code>serviceAccount.create</code></td>
			<td>Specifies whether a service account should be created</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>serviceAccount.name</code></td>
			<td>The name of the service account to use. If not set and create is true, a name is generated using the fullname template</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>tolerations</code></td>
			<td>Tolerations for pod assignment</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
	</tbody>
</table>

## Usage Examples

### Example 1: Filesystem Backend with Authentication

```yaml
# values-filesystem.yaml
config:
  auth:
    type: "aws-v4"
    identity: "myaccesskey"
    secret: "mysecretkey"
  backends:
    filesystem:
      enabled: true
      nio2: true
    filesystem:
      basedir: "/data/s3proxy"

persistence:
  enabled: true
  size: 20Gi
```

Install:
```bash
helm install s3proxy-fs ./s3proxy -f values-filesystem.yaml
```

### Example 2: AWS S3 Backend

```yaml
# values-aws-s3.yaml
config:
  auth:
    type: "aws-v4"
    identity: "proxy-access-key"  # For clients connecting to s3proxy
    secret: "proxy-secret-key"
  backend:
    provider: "aws-s3"
    awsS3:
      region: "us-west-2"
      accessKeyID: "aws-access-key-id"  # For s3proxy to connect to AWS
      secretAccessKey: "aws-secret-access-key"

persistence:
  enabled: false  # Not needed for S3 backend
```

Install:
```bash
helm install s3proxy-s3 ./s3proxy -f values-aws-s3.yaml
```

### Example 3: Azure Blob Storage Backend

```yaml
# values-azure.yaml
config:
  auth:
    type: "aws-v4"
    identity: "myaccesskey"
    secret: "mysecretkey"
  backend:
    provider: "azureblob"
    azureblob:
      account: "mystorageaccount"
      key: "storageaccountkey"

persistence:
  enabled: false  # Not needed for Azure backend
```

Install:
```bash
helm install s3proxy-azure ./s3proxy -f values-azure.yaml
```

### Example 4: Google Cloud Storage Backend

```yaml
# values-gcs.yaml
config:
  auth:
    type: "aws-v4"
    identity: "myaccesskey"
    secret: "mysecretkey"
  backend:
    provider: "google-cloud-storage"
    googleCloudStorage:
      projectID: "my-project"
      clientEmail: "service-account@my-project.iam.gserviceaccount.com"
      privateKey: |
        -----BEGIN RSA PRIVATE KEY-----
        ...
        -----END RSA PRIVATE KEY-----

persistence:
  enabled: false  # Not needed for GCS backend
```

### Example 5: Anonymous Access (No Authentication)

```yaml
# values-anonymous.yaml
config:
  auth:
    type: "none"
  backends:
    transient:
      enabled: true
      nio2: true  # In-memory storage

persistence:
  enabled: false
```

## Testing the Installation

Once deployed, you can test S3Proxy using the AWS CLI:

```bash
# Get the service endpoint
kubectl get svc

# Port-forward for local testing
kubectl port-forward svc/my-s3proxy 8080:8080

# Configure AWS CLI (if authentication is enabled)
export AWS_ACCESS_KEY_ID=myaccesskey
export AWS_SECRET_ACCESS_KEY=mysecretkey

# Test S3 operations
aws --endpoint-url http://localhost:8080 s3 ls
aws --endpoint-url http://localhost:8080 s3 mb s3://test-bucket
aws --endpoint-url http://localhost:8080 s3 cp test.txt s3://test-bucket/
aws --endpoint-url http://localhost:8080 s3 ls s3://test-bucket/
```

## TLS / HTTPS (native, in-pod)

By default S3Proxy binds plain HTTP and TLS is expected to be terminated at the
ingress. Set `config.tls.enabled=true` to have **S3Proxy itself terminate HTTPS in
the pod** (S3Proxy's `secure-endpoint`). When enabled:

- S3Proxy serves **HTTPS only** on `service.targetPort` (the plaintext endpoint is
  not bound). The container/Service port is named `https`.
- The health probes are `tcpSocket`, which only check the TCP accept (no TLS
  handshake), so they keep working unchanged against the TLS port.
- A **PKCS12** keystore is expected (Jetty's default keystore type; JKS also works
  if supplied). S3Proxy exposes only the keystore path and password, so the chart
  does not set a keystore type.
- The keystore **password is never written to the ConfigMap**; it is merged into
  the backend properties from the Secret by the config-merge initContainer.

### Option A: existing Secret (recommended; also the cert-manager path)

Reference a Secret that already holds the keystore file and the password. This is
also how a cert-manager `Certificate` with `spec.keystores.pkcs12` delivers a
keystore (point `keystore.existingSecret` at that Secret, and
`keystorePassword.existingSecret` at the password Secret it references):

```yaml
config:
  tls:
    enabled: true
    keystore:
      existingSecret: my-tls        # holds the PKCS12 archive
      secretKey: keystore.p12
    keystorePassword:
      existingSecret: my-tls        # holds the password (may be the same Secret)
      secretKey: keystore-password
```

### Option B: inline keystore + password

Provide the base64-encoded keystore and the password inline; both are stored in the
chart's own Secret. Convenient for testing; prefer Option A in production.

```yaml
config:
  tls:
    enabled: true
    keystore:
      value: "<base64-encoded PKCS12 keystore>"
    keystorePassword:
      value: "changeit"
```

Create a PKCS12 keystore, for example:

```bash
# From an existing cert + key:
openssl pkcs12 -export -inkey tls.key -in tls.crt \
  -out keystore.p12 -passout pass:changeit
# Inline value:
base64 -w0 keystore.p12
# Or as an existing Secret (Option A):
kubectl create secret generic my-tls \
  --from-file=keystore.p12=keystore.p12 \
  --from-literal=keystore-password=changeit
```

Testing over HTTPS (the CI keystore above is self-signed, so skip verification):

```bash
aws --endpoint-url https://localhost:9000 --no-verify-ssl s3 ls
```

## CORS Configuration

To enable CORS support:

```yaml
config:
  cors:
    enabled: true
    allowOrigins:
      - "https://example.com"
      - "https://.+\\.example\\.com"
    allowMethods:
      - "GET"
      - "PUT"
      - "POST"
      - "HEAD"
      - "DELETE"
    allowHeaders:
      - "Accept"
      - "Content-Type"
    allowCredential: true
```

## Middleware Configuration

S3Proxy supports various middlewares:

```yaml
config:
  middlewares:
    readOnly: false           # Make backend read-only
    eventualConsistency: true # Enable eventual consistency modeling
    shardedBackend: true      # Enable sharded backend containers
    largeObjectMocking: false # Enable large object mocking
```

## Bucket Configuration

### Bucket Aliasing

Map virtual bucket names to actual backend buckets:

```yaml
config:
  buckets:
    alias:
      virtual-bucket: "real-backend-bucket"
      another-bucket: "actual-bucket-name"
```

### Bucket Locator (routing buckets to backends)

When more than one backend is enabled, assign buckets to a specific backend with
that backend's own `bucketLocators` list. S3Proxy reads bucket-locators per
backend, so each list is emitted only into that backend's properties file. Glob
patterns are supported. A bucket that matches no backend's list falls through to
the first-enabled backend (the default).

```yaml
config:
  backends:
    s3:
      enabled: true
      # ... credentials ...
      bucketLocators:
        - "prod-*"
        - "customer-data"
    filesystem:
      enabled: true
      bucketLocators:
        - "scratch-*"   # everything else also lands here (first-enabled default)
```

## Monitoring

Check S3Proxy logs:
```bash
kubectl logs deployment/my-s3proxy
```

## Upgrading

```bash
helm upgrade my-s3proxy ./s3proxy -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall my-s3proxy
```

This will remove all resources created by the chart. If using persistence, the PVC will be retained by default.

## Troubleshooting

### Common Issues

1. **Authentication failures**: Ensure `config.auth.identity` and `config.auth.secret` are set correctly for client authentication.

2. **Backend connection issues**: Verify backend credentials are correctly configured in the appropriate section (e.g., `config.backend.awsS3.*`).

3. **Persistence issues**: Check that your cluster has a default StorageClass or specify one explicitly.

4. **Port conflicts**: If port 8080 is already in use, change `service.port` and `service.targetPort`.

## References

- [S3Proxy GitHub Repository](https://github.com/gaul/s3proxy)
- [S3Proxy Docker Hub](https://hub.docker.com/r/andrewgaul/s3proxy/)
- [Storage Backend Examples](https://github.com/gaul/s3proxy/wiki/Storage-backend-examples)

## License

This Helm chart is provided as-is. S3Proxy itself is licensed under the Apache License 2.0.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
