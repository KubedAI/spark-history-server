# Spark History Server (Spark Web UI)
Spark History Server is a Web user interface to monitor the metrics and performance of the spark jobs from [Apache Spark](https://spark.apache.org/).

- Helm Chart bootstraps Spark History Server in [Amazon EKS](https://aws.amazon.com/eks/) Cluster or any [Kubernetes](https://kubernetes.io/) Cluster which uses [Amazon S3](https://aws.amazon.com/s3/) as a Spark event log data source using [Helm](https://helm.sh/) package manager.

- [Spark History Server](https://spark.apache.org/docs/latest/monitoring.html#spark-history-server-configuration-options) 
configured to read [Spark Event Logs](https://spark.apache.org/docs/latest/monitoring.html#applying-compaction-on-rolling-event-log-files) from [Amazon S3](https://aws.amazon.com/s3/) buckets with this Helm chart using IRSA.

- Check out the [instructions](https://github.com/Hyper-Mesh/spark-history-server/tree/main/docker) to run Spark WebUI using a local [Docker](https://www.docker.com/) container. 

## Prerequisites
:white_check_mark: Kubernetes 1.19+

:white_check_mark: [Helm 3+](https://helm.sh/docs/intro/install/)

:white_check_mark: Ensure [IRSA role](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) created to add as an annotation for service account in `values.yaml`.

:white_check_mark: [Install eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) and run the following command to create AWS IRSA. Or use any other IaC tool to create IRSA. 

```
eksctl create iamserviceaccount --cluster=<eks-cluster-name> --name=<serviceAccountName> --namespace=<serviceAccountNamespace> --attach-policy-arn=<policyARN>
```

**Example:**

*Note: If the namespace doesn't exist already, it will be created*

```
eksctl create iamserviceaccount --cluster=eks-demo-cluster --name=spark-history-server --namespace=spark-history-server --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

Update `values.yaml` with `annotations`, serviceAccount `name` and the s3 bucket `name` and `prefix`

```
serviceAccount:
  create: false
  annotations:
    eks.amazonaws.com/role-arn: "<ENTER_IRSA_IAM_ROLE_ARN_HERE>"
  name: "<SERVICE_ACCOUNT_NAME>"

sparkHistoryOpts: "-Dspark.history.fs.logDirectory=s3a://<ENTER_S3_BUCKET_NAME>/<PREFIX_FOR_SPARK_EVENT_LOGS>/"
```

## Get Repo Info
    helm repo add hyper-mesh https://hyper-mesh.github.io/spark-history-server
    helm repo update

## Install Chart
    helm install spark-history-server hyper-mesh/spark-history-server --namespace spark-history-server

## Uninstall Chart
    helm uninstall spark-history-server --namespace spark-history-server

## Upgrading Chart
    helm upgrade spark-history-server --namespace spark-history-server

## How to access Spark WebUI

Spark WebUI can be accessed via ALB with Ingress or using port-forward once the Helm chart deployed to Amazon EKS or Kubernetes cluster. 

### Access Spark Web UI using port-forward

Step1: 
```sh
kubectl port-forward services/spark-history-server 18085:80 -n spark-history-server
```

Step2: 

Open any browser with and enter `http://localhost:18085/` to access Spark Web UI

You should see the following home page

<p align="center">
  <img src="https://raw.githubusercontent.com/hyper-mesh/spark-history-server/main/images/spark-webui-home.png" alt="example of Spark Web UI Homepage" width="100%">
</p>

Spark Web UI Executors page

<p align="center">
  <img src="https://raw.githubusercontent.com/hyper-mesh/spark-history-server/main/images/spark-webui-executors.png" alt="example of Spark Web UI Executors page" width="100%">
</p>

## Community
Give us a star ⭐️ - If you are using Spark History Server, we would love a star ❤️