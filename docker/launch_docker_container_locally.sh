#!/bin/sh
# ENTER AWS CREDENTIALS TO RUN THE DOCKER IMAGE LOCALLY

DOCKER_IMAGE="varabonthu/spark-web-ui:1.0.5"
LOG_DIR="s3a://<bucket_name>/<spark-event-logs-prefix>/"
ENDPOINT="s3.<region>.amazonaws.com"

AWS_ACCESS_KEY_ID=""
AWS_SECRET_ACCESS_KEY=""
AWS_SESSION_TOKEN=""


docker run -itd -e SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
-Dspark.history.fs.logDirectory=$LOG_DIR \
-Dspark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID \
-Dspark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY \
-Dspark.hadoop.fs.s3a.session.token=$AWS_SESSION_TOKEN \
-Dspark.hadoop.fs.s3a.endpoint=$ENDPOINT \
-Dspark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider" -p 18081:18080 $DOCKER_IMAGE "/opt/spark/bin/spark-class org.apache.spark.deploy.history.HistoryServer"

