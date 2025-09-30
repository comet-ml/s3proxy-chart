# s3proxy

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.7.0](https://img.shields.io/badge/AppVersion-2.7.0-informational?style=flat-square)

A Helm chart for deploying S3Proxy - Access other storage backends via the S3 API

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| CRThaze |  |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling.enabled | bool | `false` | Enable HPA |
| autoscaling.maxReplicas | int | `100` | Maximum number of replicas |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target CPU utilization percentage |
| config.authorization | string | `"aws-v4"` | Authorization type (none, aws-v2, aws-v4, aws-v2-or-v4) |
| config.backend.awsS3.accessKeyId | string | `""` | AWS Access Key ID for backend |
| config.backend.awsS3.endpoint | string | `""` | S3 endpoint |
| config.backend.awsS3.region | string | `""` | AWS region |
| config.backend.awsS3.secretAccessKey | string | `""` | AWS Secret Access Key for backend |
| config.backend.azureblob.account | string | `""` | Storage account name |
| config.backend.azureblob.endpoint | string | `""` | Azure endpoint |
| config.backend.azureblob.key | string | `""` | Storage account key |
| config.backend.azureblob.sasToken | string | `""` | SAS token |
| config.backend.b2.account | string | `""` | B2 account ID |
| config.backend.b2.applicationKey | string | `""` | B2 application key |
| config.backend.filesystem.basedir | string | `"/data/s3proxy"` | Base directory for filesystem backend |
| config.backend.googleCloudStorage.clientEmail | string | `""` | Service account email |
| config.backend.googleCloudStorage.clientId | string | `""` | Client ID |
| config.backend.googleCloudStorage.privateKey | string | `""` | Private key |
| config.backend.googleCloudStorage.privateKeyId | string | `""` | Private key ID |
| config.backend.googleCloudStorage.projectId | string | `""` | GCP project ID |
| config.backend.provider | string | `"filesystem-nio2"` | Backend provider type (filesystem, filesystem-nio2, transient, transient-nio2, aws-s3, s3, azureblob, azureblob-sdk, b2, google-cloud-storage, openstack-swift, rackspace-cloudfiles-uk, rackspace-cloudfiles-us) |
| config.backend.swift.authUrl | string | `""` | Authentication URL |
| config.backend.swift.password | string | `""` | Password |
| config.backend.swift.region | string | `""` | Region |
| config.backend.swift.tenantName | string | `""` | Tenant name |
| config.backend.swift.userName | string | `""` | Username |
| config.buckets.alias | object | `{}` | Map virtual bucket names to actual backend buckets |
| config.buckets.locator | list | `[]` | Assign specific buckets to different backends (glob patterns supported) |
| config.cors.allowCredential | bool | `false` | Allow credentials |
| config.cors.allowHeaders | list | `["Accept","Content-Type"]` | Allowed headers |
| config.cors.allowMethods | list | `["GET","PUT","POST","HEAD","DELETE"]` | Allowed methods |
| config.cors.allowOrigins | list | `[]` | Allowed origins (e.g., ["https://example.com", "https://.+\\.example\\.com"]) |
| config.cors.enabled | bool | `false` | Enable CORS support |
| config.credential | string | `""` | S3 Secret Access Key for client authentication |
| config.identity | string | `""` | S3 Access Key ID for client authentication |
| config.middlewares.eventualConsistency | bool | `false` | Enable eventual consistency modeling |
| config.middlewares.largeObjectMocking | bool | `false` | Enable large object mocking |
| config.middlewares.readOnly | bool | `false` | Make backend read-only |
| config.middlewares.shardedBackend | bool | `false` | Enable sharded backend containers |
| config.virtualHost | string | `""` | Virtual Host configuration |
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
| service.port | int | `8080` | Service port |
| service.targetPort | int | `8080` | Target port (controls both the container port and S3Proxy bind port) |
| service.type | string | `"ClusterIP"` | Kubernetes service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
