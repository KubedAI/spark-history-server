# Spark History Server
Helm Chart bootstraps Spark History Server in [Amazon EKS](https://aws.amazon.com/eks/) Cluster using Helm package manager.

[Spark History Server](https://spark.apache.org/docs/latest/monitoring.html#spark-history-server-configuration-options) 
configured to read [Spark Event Logs](https://spark.apache.org/docs/latest/monitoring.html#applying-compaction-on-rolling-event-log-files) from [AWS S3 buckets](https://aws.amazon.com/s3/) with this Helm chart.

## Prerequisites
- Kubernetes 1.21+
- [Helm](https://helm.sh/docs/intro/install/) 3+
- Ensure IAM policy created to access S3 bucket where Spark Event logs stored.
- Ensure [IRSA role](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) created to add as an annotation for service account in `values.yaml`
- [Install eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) and run the following command to create AWS IRSA. Or use any other IaC tool to create IRSA. 

```
eksctl create iamserviceaccount --cluster=<eks-cluster-name> --name=<serviceAccountName> --namespace=<serviceAccountNamespace> --attach-policy-arn=<policyARN>
```

Example: If the namespace doesn't exist already, it will be created

```
eksctl create iamserviceaccount --cluster=eks-demo-cluster --name=spark-history-server --namespace=spark-history-server --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

- Update `values.yaml` with `annotations`, service account `name` and the s3 bucket name and prefix


```
serviceAccount:
  create: false
  annotations:
    eks.amazonaws.com/role-arn: "<ENTER_IRSA_IAM_ROLE_ARN_HERE>"
  name: "<SERVICE_ACCOUNT_NAME>"

sparkHistoryOpts: "-Dspark.history.fs.logDirectory=s3a://<ENTER_S3_BUCKET_NAME>/<PREFIX_FOR_SPARK_EVENT_LOGS>/"
```

## Get Repo Info
    helm repo add hyper-mesh https://hyper-mesh.github.io/helm-charts
    helm repo update

## Install Chart
    helm install spark-history-server hyper-mesh/spark-history-server --namespace spark-history-server

## Uninstall Chart
    helm uninstall spark-history-server --namespace spark-history-server

## Upgrading Chart
    helm upgrade spark-history-server --namespace spark-history-server
