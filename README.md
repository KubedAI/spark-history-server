# Spark History Server
Helm Chart bootstraps Spark History Server in Kubernetes Cluster using Helm package manager.

[Spark History Server](https://spark.apache.org/docs/latest/monitoring.html#spark-history-server-configuration-options) configured to read [Spark event logs]([Spark History Server](https://spark.apache.org/docs/latest/monitoring.html#spark-history-server-configuration-options) 
configured to read [Spark event logs](https://spark.apache.org/docs/latest/monitoring.html#applying-compaction-on-rolling-event-log-files) from AWS S3 buckets.


## Prerequisites
- Kubernetes 1.21+
- Helm 3+
- Ensure IAM policy created to access S3 bucket where Spark Event logs stored.
- Ensure [IRSA role](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) created to add as an annotation for service account in `values.yaml`
- Install eksctl and run the following command to create AWS IRSA
```shell script
eksctl create iamserviceaccount --cluster=<eks-cluster-name> --name=<serviceAccountName> --namespace=<serviceAccountNamespace> --attach-policy-arn=<policyARN>

# Example: If the namespace doesn't exist already, it will be created
eksctl create iamserviceaccount --cluster=eks-demo-cluster --name=spark-history-server --namespace=spark-history-server --attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```
- Update `values.yml` with `annotations`, service account `name` and the s3 bucket name and prefix

```yaml
serviceAccount:
  create: false
  annotations:
    eks.amazonaws.com/role-arn: "<ENTER_IRSA_IAM_ROLE_ARN_HERE>"
  name: "spark-history-server"

sparkHistoryOpts: "-Dspark.history.fs.logDirectory=s3a://<ENTER_S3_BUCKET_NAME>/<PREFIX_FOR_SPARK_EVENT_LOGS>/"
```

## Get Repo Info
    helm repo add hyper-mesh https://hyper-mesh.github.io/helm-charts
    helm repo update

## Install Chart
    helm install spark-history-server hyper-mesh/spark-history-server --namespace spark-history-server --create-namespace --wait

## Uninstall Chart
    helm uninstall spark-history-server -n <namespace>

## Upgrading Chart
    helm upgrade spark-history-server . --namespace <namespace>