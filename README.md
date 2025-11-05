# s3proxy

![Version: 0.0.5](https://img.shields.io/badge/Version-0.0.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.7.0](https://img.shields.io/badge/AppVersion-2.7.0-informational?style=flat-square)

A Helm chart for deploying S3Proxy - Access other storage backends via the S3 API

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if using filesystem backend with persistence)

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
			<td><code>config.backends.azureblob.enabled</code></td>
			<td>Enable Azure Blob Storage backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.endpoint</code></td>
			<td>Azure endpoint</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.key</code></td>
			<td>Storage account key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.provider</code></td>
			<td>Provider type (azureblob or azureblob-sdk)</td>
			<td><code>string</code></td>
			<td><code>"azureblob"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.azureblob.sasToken</code></td>
			<td>SAS token</td>
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
			<td>B2 application key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
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
			<td><code>config.backends.filesystem.enabled</code></td>
			<td>Enable filesystem backend</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.backends.filesystem.nio2</code></td>
			<td>Use NIO2 implementation (filesystem-nio2) instead of standard filesystem</td>
			<td><code>bool</code></td>
			<td><code>true</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.clientEmail</code></td>
			<td>Service account email or user email (used with both privateKey and jsonCredentials methods)</td>
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
			<td><code>config.backends.googleCloudStorage.jsonCredentials</code></td>
			<td>JSON credentials configuration</td>
			<td><code>object</code></td>
			<td><code>{"enabled":false,"existingSecret":"","jsonContent":"","secretKey":"credentials.json"}</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.jsonCredentials.enabled</code></td>
			<td>Use JSON credentials file instead of privateKey</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.jsonCredentials.existingSecret</code></td>
			<td>Name of existing secret containing GCP credentials JSON</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.jsonCredentials.jsonContent</code></td>
			<td>JSON content for creating a new secret (takes precedence over existingSecret)</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.jsonCredentials.secretKey</code></td>
			<td>Key in the secret containing the JSON credentials (default: credentials.json)</td>
			<td><code>string</code></td>
			<td><code>"credentials.json"</code></td>
		</tr>
		<tr>
			<td><code>config.backends.googleCloudStorage.privateKey</code></td>
			<td>Private key (only used when jsonCredentials.enabled is false)</td>
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
			<td><code>config.backends.openstackSwift.enabled</code></td>
			<td>Enable OpenStack Swift backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
		</tr>
		<tr>
			<td><code>config.backends.openstackSwift.password</code></td>
			<td>Password</td>
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
			<td>API key</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
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
			<td>S3 Secret Access Key for backend</td>
			<td><code>string</code></td>
			<td><code>""</code></td>
		</tr>
		<tr>
			<td><code>config.backends.transient.enabled</code></td>
			<td>Enable transient (in-memory) backend</td>
			<td><code>bool</code></td>
			<td><code>false</code></td>
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
			<td><code>config.buckets.locator</code></td>
			<td>Assign specific buckets to different backends (glob patterns supported)</td>
			<td><code>list</code></td>
			<td><code>[]</code></td>
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

### Bucket Locator

Assign specific buckets to different backends:

```yaml
config:
  buckets:
    locator:
      - "bucket1"
      - "bucket2"
      - "*.test"  # Glob patterns supported
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
