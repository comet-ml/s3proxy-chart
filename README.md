# s3proxy

![Version: 0.0.4](https://img.shields.io/badge/Version-0.0.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.7.0](https://img.shields.io/badge/AppVersion-2.7.0-informational?style=flat-square)

A Helm chart for deploying S3Proxy - Access other storage backends via the S3 API

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if using filesystem backend with persistence)

## Installation

### Add the repository (if published)

```bash
helm repo add s3proxy <REPO_URL>
helm repo update
```

### Install the chart

```bash
# Install with default values (filesystem backend)
helm install my-s3proxy ./s3proxy

# Install with custom values
helm install my-s3proxy ./s3proxy -f my-values.yaml
```

## Configuration

The following section lists the configurable parameters of the s3proxy chart and their default values.

### General Parameters

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling.enabled | bool | `false` | Enable HPA |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| config.auth.identity | string | `""` | S3 Access Key ID for client authentication |
| config.auth.secret | string | `""` | S3 Secret Access Key for client authentication |
| config.auth.type | string | `"aws-v4"` | Authorization type (none, aws-v2, aws-v4, aws-v2-or-v4) |
| config.backends.azureblob.account | string | `""` | Storage account name |
| config.backends.azureblob.enabled | bool | `false` | Enable Azure Blob Storage backend |
| config.backends.azureblob.endpoint | string | `""` | Azure endpoint |
| config.backends.azureblob.key | string | `""` | Storage account key |
| config.backends.azureblob.provider | string | `"azureblob"` | Provider type (azureblob or azureblob-sdk) |
| config.backends.azureblob.sasToken | string | `""` | SAS token |
| config.backends.b2.account | string | `""` | B2 account ID |
| config.backends.b2.applicationKey | string | `""` | B2 application key |
| config.backends.b2.enabled | bool | `false` | Enable Backblaze B2 backend |
| config.backends.filesystem.basedir | string | `"/data/s3proxy"` | Base directory for filesystem backend |
| config.backends.filesystem.enabled | bool | `true` | Enable filesystem backend |
| config.backends.filesystem.nio2 | bool | `true` | Use NIO2 implementation (filesystem-nio2) instead of standard filesystem |
| config.backends.googleCloudStorage.clientEmail | string | `""` | Service account email or user email (used with both privateKey and jsonCredentials methods) |
| config.backends.googleCloudStorage.enabled | bool | `false` | Enable Google Cloud Storage backend |
| config.backends.googleCloudStorage.jsonCredentials | object | `{"enabled":false,"existingSecret":"","jsonContent":"","secretKey":"credentials.json"}` | JSON credentials configuration |
| config.backends.googleCloudStorage.jsonCredentials.enabled | bool | `false` | Use JSON credentials file instead of privateKey |
| config.backends.googleCloudStorage.jsonCredentials.existingSecret | string | `""` | Name of existing secret containing GCP credentials JSON |
| config.backends.googleCloudStorage.jsonCredentials.jsonContent | string | `""` | JSON content for creating a new secret (takes precedence over existingSecret) |
| config.backends.googleCloudStorage.jsonCredentials.secretKey | string | `"credentials.json"` | Key in the secret containing the JSON credentials (default: credentials.json) |
| config.backends.googleCloudStorage.privateKey | string | `""` | Private key (only used when jsonCredentials.enabled is false) |
| config.backends.googleCloudStorage.projectId | string | `""` | GCP project ID |
| config.backends.openstackSwift.authUrl | string | `""` | Authentication URL |
| config.backends.openstackSwift.enabled | bool | `false` | Enable OpenStack Swift backend |
| config.backends.openstackSwift.password | string | `""` | Password |
| config.backends.openstackSwift.region | string | `""` | Region |
| config.backends.openstackSwift.tenantName | string | `""` | Tenant name |
| config.backends.openstackSwift.userName | string | `""` | Username |
| config.backends.rackspaceCloudfiles.apiKey | string | `""` | API key |
| config.backends.rackspaceCloudfiles.enabled | bool | `false` | Enable Rackspace Cloud Files backend |
| config.backends.rackspaceCloudfiles.region | string | `"us"` | Region (uk or us) |
| config.backends.rackspaceCloudfiles.userName | string | `""` | Username |
| config.backends.s3.accessKeyId | string | `""` | S3 Access Key ID for backend |
| config.backends.s3.aws | bool | `true` | Use AWS-specific S3 provider (aws-s3) instead of generic S3 provider |
| config.backends.s3.enabled | bool | `false` | Enable S3 backend |
| config.backends.s3.endpoint | string | `""` | S3 endpoint |
| config.backends.s3.region | string | `""` | AWS region |
| config.backends.s3.secretAccessKey | string | `""` | S3 Secret Access Key for backend |
| config.backends.transient.enabled | bool | `false` | Enable transient (in-memory) backend |
| config.backends.transient.nio2 | bool | `true` | Use NIO2 implementation (transient-nio2) instead of standard transient |
| config.buckets.alias | object | `{}` | Map virtual bucket names to actual backend buckets |
| config.buckets.locator | list | `[]` | Assign specific buckets to different backends (glob patterns supported) |
| config.cors.allowCredential | bool | `false` | Allow credentials |
| config.cors.allowHeaders | list | `["Accept","Content-Type"]` | Allowed headers |
| config.cors.allowMethods | list | `["GET","PUT","POST","HEAD","DELETE"]` | Allowed methods |
| config.cors.allowOrigins | list | `[]` | Allowed origins (e.g., ["https://example.com", "https://.+\\.example\\.com"]) |
| config.cors.enabled | bool | `false` | Enable CORS support |
| config.logLevel | string | `"INFO"` | Log level for S3Proxy (DEBUG, INFO, WARN, ERROR) |
| config.middlewares.eventualConsistency | bool | `false` | Enable eventual consistency modeling |
| config.middlewares.largeObjectMocking | bool | `false` | Enable large object mocking |
| config.middlewares.readOnly | bool | `false` | Make backend read-only |
| config.middlewares.shardedBackend | bool | `false` | Enable sharded backend containers |
| config.virtualHost | string | `""` | Virtual Host configuration |
| configMergeImage.pullPolicy | string | `"IfNotPresent"` | Config merge container image pull policy |
| configMergeImage.repository | string | `"busybox"` | Config merge container image repository |
| configMergeImage.tag | string | `"1.36"` | Config merge container image tag |
| extraEnvVars | list | `[]` | Additional environment variables |
| extraVolumeMounts | list | `[]` | Additional volume mounts |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | String to fully override s3proxy.fullname template |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"andrewgaul/s3proxy"` | S3Proxy image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.hosts | list | `[]` | Ingress hosts configuration |
| ingress.tls | list | `[]` | TLS configuration |
| nameOverride | string | `""` | String to partially override s3proxy.fullname template |
| nodeSelector | object | `{}` | Node selector for pod assignment |
| persistence.accessMode | string | `"ReadWriteOnce"` | PVC Access Mode |
| persistence.annotations | object | `{}` | PVC annotations |
| persistence.enabled | bool | `true` | Enable persistence using PVC |
| persistence.existingClaim | string | `""` | Use existing PVC |
| persistence.size | string | `"10Gi"` | PVC Storage Request |
| persistence.storageClass | string | `""` (uses default StorageClass) | Storage Class |
| podAnnotations | object | `{}` | Annotations to add to the pod |
| podSecurityContext | object | `{}` | Pod security context |
| replicaCount | int | `1` | Number of S3Proxy replicas |
| resources | object | `{}` | Resource limits and requests |
| securityContext | object | `{}` | Container security context |
| service.annotations | object | `{}` | Service annotations |
| service.port | int | `9000` | Service port |
| service.targetPort | int | `9000` | Target port (controls both the container port and S3Proxy bind port) |
| service.type | string | `"ClusterIP"` | Kubernetes service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

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
      accessKeyId: "aws-access-key-id"  # For s3proxy to connect to AWS
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
      projectId: "my-project"
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
