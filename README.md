# 💥 Spark History Server (Spark Web UI) 💥

Spark History Server is a Web user interface to monitor the metrics and performance of
the [Apache Spark](https://spark.apache.org/) jobs.

## 🚀 Features

- Helm Chart bootstraps Spark History Server
  in [Amazon EKS](https://aws.amazon.com/eks/),  [Azure AKS](https://azure.microsoft.com/pl-pl/products/kubernetes-service)
  or any [Kubernetes](https://kubernetes.io/) cluster
- Configured to
  read [Spark Event Logs](https://spark.apache.org/docs/latest/monitoring.html#applying-compaction-on-rolling-event-log-files)
  from [Amazon S3](https://aws.amazon.com/s3/) buckets
  or [Azure Data Lake Storage Gen2](https://learn.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-introduction)
  containers
-
Uses [IRSA (IAM Roles for Service Accounts)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
for secure S3 access
- Multi-architecture support (amd64, arm64)
- Supports both versioned and latest tags
- [Local Docker](https://github.com/kubedai/spark-history-server/tree/main/docker) deployment option available

## 📋 Prerequisites

- :white_check_mark: Kubernetes 1.19+
- :white_check_mark: [Helm 3+](https://helm.sh/docs/intro/install/)
- :white_check_mark: [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- :white_check_mark: [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) (for EKS clusters)

## 🔧 Installation

### AWS

### 1. Create IRSA (IAM Role for Service Account)

Run the following command to create AWS IRSA:

```bash
eksctl create iamserviceaccount \
  --cluster=<eks-cluster-name> \
  --name=spark-history-server \
  --namespace=spark-history-server \
  --attach-policy-arn=<policyARN>
```

**Example:**

```bash
eksctl create iamserviceaccount \
  --cluster=eks-demo-cluster \
  --name=spark-history-server \
  --namespace=spark-history-server \
  --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

### 2. Configure values.yaml

Update the following in your `values.yaml`:

```yaml
serviceAccount:
  create: false
  annotations:
    eks.amazonaws.com/role-arn: "<ENTER_IRSA_IAM_ROLE_ARN_HERE>"
  name: "spark-history-server"

logStore:
  type: s3
  s3:
    bucket: <ENTER_S3_BUCKET_NAME>
    eventLogsPath: <ENTER_PREFIX_FOR_SPARK_EVENT_LOGS>
```

### Azure

### 1. Create Azure Service Principal

Follow the procedure described
here [Azure Service Principal](https://learn.microsoft.com/en-us/azure/databricks/connect/storage/azure-storage#connect-to-azure-data-lake-storage-or-blob-storage-using-azure-credentials).

### 2. Configure values.yaml

Update the following in your `values.yaml`:

```yaml
logStore:
  type: abfs
  abfs:
    container: <ENTER_ABFS_CONTAINER_NAME>
    storageAccount: <ENTER_STORAGE_ACCOUNT_NAME>
    clientId: <ENTER_CLIENT_ID>
    clientSecret: <ENTER_CLIENT_SECRET>
    tenantId: <ENTER_TENANT_ID>
    eventLogsPath: <ENTER_PREFIX_FOR_SPARK_EVENT_LOGS>
```

### 3. Set up the image pull secret

The project publishes the Docker image to GitHub Container Registry (ghcr.io). You need to create a Kubernetes secret to
let the Kubernetes know how to access the registry. You can create the secret manually or create the secret using the
helm chart.

#### Use the secret you created manually

update the following in your `values.yaml`:

```yaml
image:
  pullSecrets:
    - name: <PULL_SECRET_NAME>
```

#### Use the secret created by the Helm chart

If you prefer to let the Helm chart create the image pull secret, you can set the following in your `values.yaml`:

```yaml
image:
  pullCredentials:
    secretName: <ANY_NAME_THAT_DOESNT_COLLIDE_WITH_EXISTING_SECRET>
    registry: ghcr.io
    username: <GITHUB_USERNAME>
    password: <GITHUB_PERSONAL_ACCESS_TOKEN>
    email: <YOUR_EMAIL>
```

### 4. Install the Chart

```bash
# Add the Helm repository
helm repo add kubedai https://kubedai.github.io/spark-history-server
helm repo update

# Install the chart
helm install spark-history-server kubedai/spark-history-server \
  --namespace spark-history-server \
  --create-namespace
```

## 🔍 Accessing Spark WebUI

### Option 1: Using Port Forward

```bash
kubectl port-forward services/spark-history-server 18085:80 -n spark-history-server
```

Then access the UI at `http://localhost:18085/`

### Option 2: Using Ingress (if enabled)

Configure ingress in `values.yaml`:

```yaml
ingress:
  enabled: true
  ingressClassName: nginx  # or your preferred ingress class
  hosts:
    - host: spark-history.example.com
      paths:
        - path: /
```

## 📸 UI Screenshots

### Home Page

<p align="center">
  <img src="https://github.com/kubedai/spark-history-server/blob/main/images/spark-webui-home.png" alt="Spark Web UI Homepage" width="100%">
</p>

### Executors Page

<p align="center">
  <img src="https://github.com/kubedai/spark-history-server/blob/main/images/spark-webui-executors.png" alt="Spark Web UI Executors page" width="100%">
</p>

## 🔄 Upgrading

```bash
helm upgrade spark-history-server kubedai/spark-history-server \
  --namespace spark-history-server
```

## 🗑️ Uninstalling

```bash
helm uninstall spark-history-server --namespace spark-history-server
```

## 🧱 Contributing

To update the Docker image version published to **GitHub Container Registry (GHCR)**:

1. **Fork this repository**
2. **Bump the `appVersion:`** field in `stable/spark-history-server/Chart.yaml`
3. **Raise a Pull Request (PR)** targeting the `main` branch

Once merged, GitHub Actions will automatically:

- Build multi-architecture Docker image (`linux/amd64`, `linux/arm64`)
- Push to GHCR: [
  `ghcr.io/kubedai/spark-history-server`](https://github.com/kubedai/spark-history-server/pkgs/container/spark-history-server)
- Tag with both version and `latest`

You can also manually trigger the workflow from GitHub Actions with an optional version override.

## ⚙️ Configuration

Key configuration options in `values.yaml`:

| Parameter               | Description                  | Default                                |
|-------------------------|------------------------------|----------------------------------------|
| `image.repository`      | Image repository             | `ghcr.io/kubedai/spark-history-server` |
| `image.tag`             | Image tag                    | `latest`                               |
| `serviceAccount.create` | Create service account       | `true`                                 |
| `sparkHistoryOpts`      | Spark history server options | `""`                                   |
| `resources`             | Pod resource requests/limits | See values.yaml                        |

## 🤝 Community

Give us a star ⭐️ if you find this project useful!

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
