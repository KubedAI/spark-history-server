# Apache Spark History Server Helm Chart

<div align="center">

[![Helm Chart Version](https://img.shields.io/badge/helm-v1.5.0-blue.svg)](https://github.com/kubedai/spark-history-server)
[![Apache Spark](https://img.shields.io/badge/Apache%20Spark-3.5+-orange.svg)](https://spark.apache.org/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.19+-blue.svg)](https://kubernetes.io/)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://opensource.org/licenses/Apache-2.0)
[![Multi-Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-success.svg)](https://github.com/kubedai/spark-history-server/pkgs/container/spark-history-server)

**Production-ready Apache Spark History Server for Kubernetes**

</div>

[Apache Spark History Server](https://spark.apache.org/docs/latest/monitoring.html#spark-history-server) provides a web UI to monitor and analyze Spark applications by reconstructing the Spark UI from event logs. This Helm chart deploys a production-ready History Server on Kubernetes with enterprise-grade features including multi-cloud storage support, advanced RocksDB caching, and performance optimizations for high-scale deployments.

**Key capabilities:**
- Web UI to view completed and running Spark applications
- Replay and display application event logs with detailed metrics
- List application attempts with configurable retention policies
- Event log compaction to reduce storage requirements
- Support for AWS S3, Azure ADLS Gen2, and local storage backends

## ✨ Features

### 🏗️ **Production-Ready Architecture**
- **High Performance**: Optimized JVM settings with G1GC and configurable memory allocation
- **Advanced Caching**: Hybrid storage with RocksDB for massive scale deployments
- **Resource Optimization**: CPU bursting support and intelligent memory management
- **Security First**: Read-only filesystem, non-root execution, and secure credential management

### 🔌 **Multi-Cloud Storage Support**
- **Amazon S3**: Native S3A connector with optimized connection pooling
- **Azure ADLS Gen2**: OAuth2 authentication with Azure Blob File System (ABFS)
- **Local Storage**: Persistent volume support for air-gapped environments
- **Hybrid Store**: In-memory + disk caching for optimal performance

### ⚡ **Performance Optimizations**
- **Configurable Thread Pool**: Optimized replay threads for faster log processing
- **Connection Pooling**: S3/ABFS connection optimization for high-throughput scenarios
- **Memory Management**: Configurable daemon memory with RocksDB awareness
- **Efficient Parsing**: Multi-threaded event log processing

### 🚀 **Enterprise Features**
- **Multi-Architecture**: Support for AMD64 and ARM64 architectures
- **IRSA Integration**: AWS IAM Roles for Service Accounts for secure S3 access
- **Observability**: Built-in health checks and monitoring endpoints
- **Scalability**: Optimized for handling hundreds of concurrent Spark applications

## 📋 Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Kubernetes** | 1.19+ | Tested on EKS, AKS, and vanilla K8s |
| **Helm** | 3.0+ | Package manager for Kubernetes |
| **Storage Access** | - | S3, ADLS Gen2, or Persistent Volume |

### Platform-Specific Requirements

**AWS EKS:**
- AWS CLI configured with appropriate permissions
- eksctl (optional, for IRSA setup)

**Azure AKS:**
- Azure CLI with service principal credentials
- Storage account with Data Lake Storage Gen2 enabled

## 🚀 Quick Start

### 1. Add Helm Repository

```bash
helm repo add kubedai https://kubedai.github.io/spark-history-server
helm repo update
```

### 2. Install with Default Configuration

```bash
# Create namespace
kubectl create namespace spark-history-server

# Install chart
helm install spark-history-server kubedai/spark-history-server \
  --namespace spark-history-server \
  --set logStore.type=s3 \
  --set logStore.s3.bucket=your-s3-bucket \
  --set logStore.s3.eventLogsPath=spark-events/
```

### 3. Access the Web UI

```bash
# Port forward to access locally
kubectl port-forward services/spark-history-server 18080:80 -n spark-history-server
```

Open your browser to `http://localhost:18080`

## ⚙️ Configuration

### Storage Backend Configuration

<details>
<summary><b>🪣 Amazon S3 (Recommended for AWS)</b></summary>

#### Using IRSA (Recommended)

```yaml
# values.yaml
serviceAccount:
  create: false
  name: spark-history-server
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/spark-history-server-role"

logStore:
  type: s3
  s3:
    bucket: your-spark-logs-bucket
    eventLogsPath: spark-events/
    irsaRoleArn: "arn:aws:iam::ACCOUNT:role/spark-history-server-role"
```

#### Setup IRSA Role

```bash
eksctl create iamserviceaccount \
  --cluster=your-eks-cluster \
  --name=spark-history-server \
  --namespace=spark-history-server \
  --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
  --approve
```

</details>

<details>
<summary><b>☁️ Azure Data Lake Storage Gen2</b></summary>

```yaml
# values.yaml
logStore:
  type: abfs
  abfs:
    container: spark-logs
    storageAccount: yourstorageaccount
    clientId: "your-client-id"
    clientSecret: "your-client-secret"
    tenantId: "your-tenant-id"
    eventLogsPath: spark-events
```

</details>

<details>
<summary><b>💾 Local Storage (Air-gapped/On-premises)</b></summary>

```yaml
# values.yaml
logStore:
  type: local
  local:
    directory: "/spark-logs"

# Enable persistence for event logs
persistence:
  enabled: true
  size: 100Gi
  storageClass: fast-ssd
```

</details>

### Performance Tuning

<details>
<summary><b>⚡ High-Performance Configuration</b></summary>

```yaml
# values.yaml - Optimized for large-scale deployments
sparkDaemon:
  memory: "8g"  # Adjust based on workload
  javaOpts: >-
    -XX:+UseG1GC
    -XX:MaxGCPauseMillis=200
    -XX:G1HeapRegionSize=32m
    -XX:+UseStringDeduplication

historyServer:
  retainedApplications: 100  # Number of apps to cache
  fs:
    numReplayThreads: 8      # Parallel log processing
    update:
      interval: 5s           # Faster refresh rate

# Enable hybrid storage for massive scale
historyServer:
  store:
    hybridStore:
      enabled: true
      maxMemoryUsage: 6g     # Must be < sparkDaemon.memory
      diskBackend: ROCKSDB

persistence:
  enabled: true
  size: 50Gi                # Adjust based on log volume

resources:
  requests:
    cpu: 1000m
    memory: 8Gi
  limits:
    memory: 12Gi            # No CPU limit for bursting
```

</details>

<details>
<summary><b>🔧 Resource Optimization</b></summary>

```yaml
# values.yaml - Balanced configuration
resources:
  requests:
    cpu: 500m               # Baseline CPU allocation
    memory: 4Gi            # Supports sparkDaemon.memory: 4g
  limits:
    # cpu: removed          # Allow CPU bursting for better performance
    memory: 6Gi            # Hard memory limit

# Health check optimization
livenessProbe:
  initialDelaySeconds: 60   # SHS startup can be slow
  timeoutSeconds: 10
  failureThreshold: 5       # Tolerant of temporary issues

readinessProbe:
  initialDelaySeconds: 30
  periodSeconds: 15         # Faster recovery detection
```

</details>

### Advanced Features

<details>
<summary><b>🔐 Security Configuration</b></summary>

```yaml
# values.yaml
podSecurityContext:
  runAsUser: 1000
  runAsGroup: 1000
  fsGroup: 1000

securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  allowPrivilegeEscalation: false

# Image pull secrets for private registries
image:
  pullCredentials:
    enabled: true
    secretName: ghcr-pull-secret
    registry: ghcr.io
    username: your-github-username
    password: your-github-token
```

</details>

<details>
<summary><b>🌐 Ingress Configuration</b></summary>

```yaml
# values.yaml
ingress:
  enabled: true
  ingressClassName: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: spark-history.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: spark-history-tls
      hosts:
        - spark-history.yourdomain.com
```

</details>

## 📊 Monitoring & Observability

### Health Checks

The chart includes comprehensive health checks:

- **Liveness Probe**: HTTP check on port 18080 with tolerant failure thresholds
- **Readiness Probe**: Fast recovery detection for load balancer integration
- **Startup Probe**: Accommodates slow initialization with large event logs

### Metrics & Logging

```yaml
# Enable structured logging
log4jConfig: |-
  rootLogger.level = INFO
  # Custom log4j2 configuration
  logger.history.name = org.apache.spark.deploy.history.FsHistoryProvider
  logger.history.level = DEBUG  # For troubleshooting
```

## 🛠️ Development & Testing

### Local Development with Kind

```bash
# Install Task runner (if not installed)
brew install go-task  # macOS
# See https://taskfile.dev/installation/ for other platforms

# Create local cluster
task create-cluster

# Run tests
task unittest
task lint

# Install chart locally
task install-chart

# Clean up
task clean
```

### Testing Different Configurations

```bash
# Test S3 configuration
helm template spark-history-server ./stable/spark-history-server \
  --set logStore.type=s3 \
  --set logStore.s3.bucket=test-bucket

# Test with hybrid store enabled
helm template spark-history-server ./stable/spark-history-server \
  --set historyServer.store.hybridStore.enabled=true \
  --set sparkDaemon.memory=8g
```

## 📈 Performance Tuning Guide

### Memory Configuration

| Workload Size | Apps Retained | sparkDaemon.memory | hybridStore.maxMemoryUsage | PVC Size |
|---------------|---------------|--------------------|-----------------------------|----------|
| **Small** | 25 | 2g | - | - |
| **Medium** | 50 | 4g | 2g | 30Gi |
| **Large** | 100 | 8g | 6g | 100Gi |
| **Enterprise** | 200+ | 16g+ | 12g+ | 500Gi+ |

### Thread Configuration

```yaml
historyServer:
  fs:
    numReplayThreads: 4    # Start with 4, increase for high log volume
                          # Rule of thumb: 1 thread per 2 CPU cores
```

### Storage Optimizations

```yaml
# S3 optimization for high-throughput scenarios
sparkConf: |-
  spark.hadoop.fs.s3a.connection.maximum=200
  spark.hadoop.fs.s3a.threads.max=50
  spark.hadoop.fs.s3a.max.total.tasks=100
  spark.hadoop.fs.s3a.connection.establish.timeout=10000
  spark.hadoop.fs.s3a.connection.timeout=20000
```


## 📚 Configuration Reference

For complete configuration options and examples, see:

- **[values.yaml](stable/spark-history-server/values.yaml)** - Complete configuration reference with comments
- **[Chart.yaml](stable/spark-history-server/Chart.yaml)** - Chart metadata and version information

To see all available configuration options:
```bash
helm show values kubedai/spark-history-server
```

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Test** your changes (`task unittest && task lint`)
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Development Workflow

```bash
# Setup development environment
git clone https://github.com/kubedai/spark-history-server.git
cd spark-history-server

# Install dependencies
task install-tools

# Make changes and test
task unittest
task lint
task create-cluster
task install-chart

# Clean up
task clean
```

## 📚 Documentation

- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Changelog](CHANGELOG.md)** - Release notes and version history
- **Performance Tuning** - Advanced optimization guide *(coming soon)*
- **Security Best Practices** - Production security recommendations *(coming soon)*

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apache Spark community for the excellent History Server
- Kubernetes community for the robust platform
- All contributors who have helped improve this project

---

<div align="center">

**⭐ Star this repository if it helped you! ⭐**

[Report Bug](https://github.com/kubedai/spark-history-server/issues) · [Request Feature](https://github.com/kubedai/spark-history-server/issues) · [Troubleshooting](docs/TROUBLESHOOTING.md) · [Changelog](CHANGELOG.md)

</div>