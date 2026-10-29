# s3proxy

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.1.1](https://img.shields.io/badge/AppVersion-4.1.1-informational?style=flat-square)

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

Chart `1.x` targets **S3Proxy 4.x** (`appVersion` currently `4.1.1`; override with `image.tag`). Minimum supported version is `4.0.0`.

S3Proxy `4.0.0` removed Apache jclouds and, with it, the Atmos and B2 backends and the `-sdk` / `-nio2` provider-name variants. Each backend now has a single native/SDK implementation selected by its plain name — `filesystem`, `transient`, `aws-s3`, `azureblob`, `google-cloud-storage`, `openstack-swift` — so the chart no longer exposes the `aws:` / `nio2:` / `azureblob.provider` toggles.

- **`filesystem` / `transient`** — the NIO2 implementations (no toggle).
- **`s3`** — the `aws-s3` AWS SDK provider; serves AWS or any S3-compatible endpoint (set `endpoint`). Supports **keyless** auth: leave `accessKeyID`/`secretAccessKey` empty and set `s3.keyless: true` to use the AWS default credential chain (IRSA / EKS Pod Identity / EC2 instance profile).
- **`azureblob`** — the Azure SDK; supports Managed/Workload Identity via `azureblob.managedIdentity: true` (no static key) — see "Example 3b".
- **`googleCloudStorage`** — the Google SDK; a static service-account JSON key is required (`serviceAccountKey.value` / `.existingSecret`). **Keyless GCS (Workload Identity/ADC) is not supported by S3Proxy 4.x** — an empty credential selects an unauthenticated (emulator-only) client, not ADC.
- **`openstackSwift`** — the openstack4j SDK (Keystone v3); set `projectName` and, if non-default, `projectDomainName` / `userDomainName`.

Removed in chart `1.x`: the `b2` and `rackspaceCloudfiles` backends (jclouds-only, dropped upstream). Rackspace Cloud Files is OpenStack-Swift-compatible — configure it via the `openstackSwift` backend.

- **Guardrail:** the chart **hard-fails at render time** if the effective S3Proxy version (`image.tag`, else `appVersion`) parses as semver and is older than `4.0.0`, so it cannot render a 4.x-only config against a 3.x image. Use chart `0.x` for S3Proxy 3.x.

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
			<td><code>config.auth.existingSecret</code></td>
			<td>Name of an existing Secret holding both client authentication credentials (see <code>identityKey</code>/<code>secretKey</code>). Takes precedence over <code>identity</code>/<code>secret</code>, which are otherwise stored in plaintext in the chart-owned Secret; prefer this when the values file lives in Git.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.auth.identity</code></td>
			<td>S3 Access Key ID for client authentication, stored in the chart-owned Secret. Ignored when <code>existingSecret</code> is set.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.auth.identityKey</code></td>
			<td>Key within <code>existingSecret</code> that holds the S3 Access Key ID</td>
			<td><code>string</code></td>
			<td><code>"accessKeyId"</code></td>
		</tr>
		<tr>
			<td><code>config.auth.secret</code></td>
			<td>S3 Secret Access Key for client authentication, stored in the chart-owned Secret. Ignored when <code>existingSecret</code> is set.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.auth.secretKey</code></td>
			<td>Key within <code>existingSecret</code> that holds the S3 Secret Access Key</td>
			<td><code>string</code></td>
			<td><code>"secretAccessKey"</code></td>
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
			<td>Enable Azure Blob Storage backend (provider <code>azureblob</code>, Azure SDK)</td>
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
			<td><code>config.backends.azureblob.managedIdentity</code></td>
			<td>Use Azure Managed/Workload Identity instead of a static account key or SAS token. Mutually exclusive with <code>key.<i></code> and <code>sasToken.</i></code>. When true the chart renders both <code>jclouds.identity</code> and <code>jclouds.credential</code> empty, which makes the Azure SDK fall back to <code>DefaultAzureCredential</code> (consuming the AKS workload-identity env <code>AZURE_CLIENT_ID</code>/<code>AZURE_TENANT_ID</code>/<code>AZURE_FEDERATED_TOKEN_FILE</code>). Set <code>account</code> (or <code>endpoint</code>) for the storage endpoint, annotate the ServiceAccount with <code>azure.workload.identity/client-id</code> (<code>serviceAccount.annotations</code>) and label the pod <code>azure.workload.identity/use: "true"</code> (<code>podLabels</code>).</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
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
			<td>jclouds credential placeholder. S3Proxy requires jclouds.credential in every backend properties file; the filesystem backend ignores the value. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.enabled</code></td>
			<td>Enable filesystem backend (provider <code>filesystem</code>, NIO2-backed in S3Proxy 4.x)</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.identity</code></td>
			<td>jclouds identity placeholder. S3Proxy requires jclouds.identity in every backend properties file; the filesystem backend ignores the value. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.enabled</code></td>
			<td>Enable Google Cloud Storage backend (provider <code>google-cloud-storage</code>, Google SDK)</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.endpoint</code></td>
			<td>Custom GCS endpoint (<code>jclouds.endpoint</code>), e.g. a fake-gcs-server emulator. Empty uses <code>https://storage.googleapis.com</code>. An emulator needs no <code>serviceAccountKey</code>: with no key the SDK sends unauthenticated requests.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.projectID</code></td>
			<td>GCP project ID, emitted as <code>jclouds.identity</code> (the GCS SDK store reads it as the project id). Optional: when empty the project is taken from the service-account key.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.serviceAccountKey</code></td>
			<td>Service-account key configuration. The full JSON key is passed to the GCS SDK as <code>jclouds.credential</code> (<code>ServiceAccountCredentials.fromStream</code>). NOTE: S3Proxy 4.x does NOT support keyless GCS (Workload Identity/ADC) — an empty credential selects an unauthenticated (emulator-only) client, not ADC — so a static key is required against real GCS.</td>
			<td><code>object</code></td>
			<td><code>{"existingSecret":"","secretKey":"key.json","value":""}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.serviceAccountKey.existingSecret</code></td>
			<td>Name of an existing Secret holding the service-account JSON key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.serviceAccountKey.secretKey</code></td>
			<td>Key within the Secret that holds the JSON key</td>
			<td><code>string</code></td>
			<td><code>"key.json"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.serviceAccountKey.value</code></td>
			<td>Inline service-account JSON key content, stored in the chart-owned Secret and mounted as a file the initContainer merges into the backend properties (kept out of the ConfigMap). Used only when <code>existingSecret</code> is empty.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.authURL</code></td>
			<td>Keystone authentication URL (<code>jclouds.endpoint</code>)</td>
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
			<td>Enable OpenStack Swift backend (provider <code>openstack-swift</code>, openstack4j SDK, Keystone v3)</td>
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
			<td><code>config.backends.openstackSwift.projectDomainName</code></td>
			<td>Keystone domain that owns the project (<code>openstack-swift-sdk.project-domain-name</code>)</td>
			<td><code>string</code></td>
			<td><code>"Default"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.projectName</code></td>
			<td>Keystone project (tenant) name to scope the token to (<code>openstack-swift-sdk.project-name</code>). Required: Swift is only reachable through a project-scoped token.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.region</code></td>
			<td>Region to select from the service catalog (<code>openstack-swift-sdk.region</code>); empty selects the first/default region</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.userDomainName</code></td>
			<td>Keystone domain that owns the user (<code>openstack-swift-sdk.user-domain-name</code>)</td>
			<td><code>string</code></td>
			<td><code>"Default"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.userName</code></td>
			<td>Username (<code>jclouds.identity</code>)</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.accessKeyID</code></td>
			<td>S3 Access Key ID for backend (<code>jclouds.identity</code>). Leave empty when <code>keyless: true</code>.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.bucketLocators</code></td>
			<td>Buckets routed to this backend (S3Proxy bucket-locator; glob patterns supported). Only relevant when multiple backends are enabled; a bucket matching no backend's list falls through to the first-enabled backend.</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.enabled</code></td>
			<td>Enable S3 backend (provider <code>aws-s3</code>, AWS SDK; also serves S3-compatible endpoints such as MinIO/Ceph via <code>endpoint</code>)</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.endpoint</code></td>
			<td>S3 endpoint (<code>jclouds.endpoint</code>) for an S3-compatible backend (MinIO, Ceph). Leave empty for AWS.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.keyless</code></td>
			<td>Use ambient/keyless credentials: leave <code>accessKeyID</code>/<code>secretAccessKey</code> empty and the AWS SDK default credential chain resolves IRSA / EKS Pod Identity / EC2 instance-profile creds. Mutually exclusive with <code>accessKeyID</code>/<code>secretAccessKey.*</code>.</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.region</code></td>
			<td>AWS region (<code>jclouds.region</code>). S3Proxy defaults to <code>us-east-1</code> when empty.</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.s3.secretAccessKey</code></td>
			<td>S3 Secret Access Key configuration. Leave empty when <code>keyless: true</code>.</td>
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
			<td>jclouds credential placeholder. S3Proxy requires jclouds.credential in every backend properties file; the transient backend ignores the value. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.enabled</code></td>
			<td>Enable transient (in-memory) backend (provider <code>transient</code>, NIO2-backed in S3Proxy 4.x)</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.identity</code></td>
			<td>jclouds identity placeholder. S3Proxy requires jclouds.identity in every backend properties file; the transient backend ignores the value. An empty value falls back to "local".</td>
			<td><code>string</code></td>
			<td><code>"local"</code></td>
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
			<td><code>terminationGracePeriodSeconds</code></td>
			<td>Pod termination grace period. Covers the 5s preStop sleep plus the in-flight request drain (up to 30s) that S3Proxy releases after 3.3.0 perform on SIGTERM.</td>
			<td><code>int</code></td>
			<td><code>40</code></td>
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
  backends:
    filesystem:
      enabled: false
    s3:
      enabled: true
      region: "us-west-2"
      accessKeyID: "aws-access-key-id"       # For s3proxy to connect to AWS
      secretAccessKey:
        value: "aws-secret-access-key"

persistence:
  enabled: false  # Not needed for S3 backend
```

For keyless auth on EKS (IRSA / Pod Identity) or EC2, drop the keys and set `keyless`:

```yaml
config:
  backends:
    filesystem:
      enabled: false
    s3:
      enabled: true
      region: "us-west-2"
      keyless: true
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
  backends:
    filesystem:
      enabled: false
    azureblob:
      enabled: true
      account: "mystorageaccount"
      key:
        value: "storageaccountkey"

persistence:
  enabled: false  # Not needed for Azure backend
```

Install:
```bash
helm install s3proxy-azure ./s3proxy -f values-azure.yaml
```

### Example 3b: Azure Blob with Managed / Workload Identity (no static key)

On AKS with Workload Identity, set `managedIdentity: true` instead of an account
key or SAS token. The chart then renders both `jclouds.identity` and
`jclouds.credential` empty, which makes the `azureblob-sdk` provider fall back to
Azure's `DefaultAzureCredential` — it reads the federated token AKS injects
(`AZURE_CLIENT_ID` / `AZURE_TENANT_ID` / `AZURE_FEDERATED_TOKEN_FILE`). The storage
account name goes in the endpoint, never in the identity.

```yaml
# values-azure-mi.yaml
config:
  backends:
    filesystem:
      enabled: false
    azureblob:
      enabled: true
      managedIdentity: true
      account: "mystorageaccount" # used for the endpoint; NOT emitted as jclouds.identity
      # endpoint: "https://mystorageaccount.blob.core.windows.net"  # or set explicitly

# Bind the pod to the AKS user-assigned identity:
serviceAccount:
  create: true
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"
podLabels:
  azure.workload.identity/use: "true"

persistence:
  enabled: false
```

### Example 4: Google Cloud Storage Backend

The GCS SDK reads the credential as a full service-account JSON key. A static key
is required — S3Proxy 4.x does not support keyless GCS (Workload Identity/ADC).

```yaml
# values-gcs.yaml
config:
  auth:
    type: "aws-v4"
    identity: "myaccesskey"
    secret: "mysecretkey"
  backends:
    filesystem:
      enabled: false
    googleCloudStorage:
      enabled: true
      projectID: "my-project"
      serviceAccountKey:
        # The full service-account JSON key (or use existingSecret / secretKey).
        value: |
          {
            "type": "service_account",
            "project_id": "my-project",
            "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
            "client_email": "service-account@my-project.iam.gserviceaccount.com"
          }

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
      enabled: true  # In-memory storage

persistence:
  enabled: false
```

## Client authentication credentials

`config.auth.identity` / `config.auth.secret` are the S3 Access Key ID and Secret
Access Key that *clients* present to S3Proxy.

### Option A: existing Secret (recommended)

Point `config.auth.existingSecret` at a Secret you manage yourself, so the credentials
never appear in the values file (e.g. in GitOps). It takes precedence over inline
`identity`/`secret`; both credentials are read from it:

```yaml
config:
  auth:
    type: "aws-v4"
    existingSecret: my-s3proxy-auth
    identityKey: accessKeyId        # default; key holding the Access Key ID
    secretKey: secretAccessKey      # default; key holding the Secret Access Key
```

```bash
kubectl create secret generic my-s3proxy-auth \
  --from-literal=accessKeyId='myaccesskey' \
  --from-literal=secretAccessKey='mysecretkey'
```

Rotating the Secret does not restart the pod — roll the Deployment yourself, since the
credentials are read once at startup.

### Option B: inline credentials

Set `config.auth.identity` / `config.auth.secret` directly, as in
[Example 1](#example-1-filesystem-backend-with-authentication). Convenient for
testing; both values are stored in plaintext in the chart's own Secret.

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

1. **Authentication failures**: Ensure `config.auth.identity` and `config.auth.secret` are set correctly (or, with `config.auth.existingSecret`, that the Secret exists and its `identityKey`/`secretKey` entries are present) for client authentication.

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
