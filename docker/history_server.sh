#!/bin/sh
set -e

DEFAULT_SPARK_VERSION="4.1.0"

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  source .env
fi

print_help(){
  # Display Help
   echo "A helper script to start/stop your local Spark History Server"
   echo
   echo "Syntax: sh history_server.sh {start|stop|restart|status|help} {options}"
   echo
   echo "actions:"
   echo "start   start your local Spark History Server at 'localhost:18081'"
   echo "stop    stop the running Spark History Server"
   echo "restart restart the Spark History Server"
   echo "status  print the current running container details"
   echo "help    print this message"
   echo
   echo "start/restart options:"
   echo "For AWS:"
   echo "-sb or --S3_BUCKET             S3 bucket name where you have your Spark EventLogs. eg: my-bucket in 's3://my-bucket/evemts/'. REQUIRED (for AWS) with 'start/restart"
   echo "-sp or --S3_BUCKET_PREFIX      S3 bucket prefix where you have your Spark EventLogs. eg: 'spark/history/events' in 's3://my-bucket/spark/history/events/'. REQUIRED (for AWS) with 'start/restart'"
   echo "-r  or --AWS_REGION            Your AWS Region where the S3 bucket is in. Default: us-east-1"
   echo "-cn or --CONTAINER_NAME        Your Custom Container Name. Default: spark-history-server"
   echo "-du or --DOCKER_USER           The local user used to build/publish the docker image. Default: $USER, the current logged in user"
   echo "-sv or --SPARK_VERSION         Spark version to use. Default: $DEFAULT_SPARK_VERSION"
   echo "-ak or --AWS_ACCESS_KEY_ID     AWS access key id for authentication, optional: you may export ENV variables for the same"
   echo "-as or --AWS_SECRET_ACCESS_KEY AWS secret access key for authentication, optional: you may export ENV variables for the same"
   echo "-at or --AWS_SESSION_TOKEN     AWS session token for authentication, optional: you may export ENV variables for the same"
   echo "-p  or --PORT                  Port to expose Spark History Server UI. Default: 18080"
   echo
   echo "For Azure:"
   echo "--azure-storage-account or --AZURE_STORAGE_ACCOUNT  Azure Storage Account name where you have your Spark EventLogs. REQUIRED (for Azure)"
   echo "--azure-container or --AZURE_CONTAINER              Azure Storage Account container name where you have your Spark EventLogs. REQUIRED (for Azure)"
   echo "--azure-tenant-id or --AZURE_TENANT_ID              Azure Storage Account key for authentication, REQUIRED (for Azure). You may export ENV variables for the same"
   echo "--azure-client-id or --AZURE_CLIENT_ID              The application (client) ID of the Azure Storage Account, REQUIRED (for Azure). You may export ENV variables for the same"
   echo "--azure-client-secret or --AZURE_CLIENT_SECRET      The client secret of the Azure Storage Account, REQUIRED (for Azure). You may export ENV variables for the same"
   echo "--azure-event-logs-path or --AZURE_EVENT_LOGS_PATH  The path to the Spark EventLogs in the Azure Storage Account. eg: 'spark/history/events'. REQUIRED (for Azure)"
   echo
   echo "eg:"
   echo "sh history_server.sh start -sb my-bucket -sp spark/history/events"
   echo "sh history_server.sh stop"
   echo "sh history_server.sh restart -sb my-bucket -sp spark/history/events"
   echo "sh history_server.sh status"
   echo "sh history_server.sh help"
   echo
}

do_start(){
  # Detect cloud platform and set docker image accordingly
  if [ -n "$S3_BUCKET" ]; then
    CLOUD_PLATFORM="aws"
    LOG_DIR="s3a://$S3_BUCKET/$S3_BUCKET_PREFIX"
  elif [ -n "$AZURE_CONTAINER" ]; then
    CLOUD_PLATFORM="azure"
    LOG_DIR="abfss://$AZURE_CONTAINER@$AZURE_STORAGE_ACCOUNT.dfs.core.windows.net/$AZURE_EVENT_LOGS_PATH"
  else
    echo "Error: Either S3_BUCKET or AZURE_CONTAINER must be set."
    exit 1
  fi

  # Set docker image name with platform and version
  DOCKER_IMAGE="${DOCKER_USER:-$USER}/spark-history-server:latest-${CLOUD_PLATFORM}-${SPARK_VERSION}"

  # Set default port if not set
  if [ -z "$PORT" ]; then PORT=18080 ; fi

  # Both AWS S3 and Azure Hadoop File System settings are included below.
  # Only the settings relevant to the chosen log directory (spark.history.fs.logDirectory) will be used by Spark History Server.
  docker run -itd --name $CONTAINER_NAME -e SPARK_DAEMON_MEMORY="2g" -e SPARK_DAEMON_JAVA_OPTS="-XX:+UseG1GC" -e SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
  -Dspark.history.fs.logDirectory=$LOG_DIR \
  -Dspark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID \
  -Dspark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY \
  -Dspark.hadoop.fs.s3a.session.token=$AWS_SESSION_TOKEN \
  -Dspark.hadoop.fs.s3a.endpoint=$ENDPOINT \
  -Dspark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider \
  -Dspark.hadoop.fs.azure.account.auth.type.$AZURE_STORAGE_ACCOUNT.dfs.core.windows.net=OAuth \
  -Dspark.hadoop.fs.azure.account.oauth.provider.type.$AZURE_STORAGE_ACCOUNT.dfs.core.windows.net=org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider \
  -Dspark.hadoop.fs.azure.account.oauth2.client.id.$AZURE_STORAGE_ACCOUNT.dfs.core.windows.net=$AZURE_CLIENT_ID \
  -Dspark.hadoop.fs.azure.account.oauth2.client.secret.$AZURE_STORAGE_ACCOUNT.dfs.core.windows.net=$AZURE_CLIENT_SECRET \
  -Dspark.hadoop.fs.azure.account.oauth2.client.endpoint.$AZURE_STORAGE_ACCOUNT.dfs.core.windows.net=https://login.microsoftonline.com/$AZURE_TENANT_ID/oauth2/token \
  -Dspark.history.ui.port=$PORT" \
  -p $PORT:$PORT $DOCKER_IMAGE "/opt/spark/bin/spark-class $CLASS"
  sleep 10
  echo "Spark History Server running @ http://localhost:$PORT "
  echo
}

do_stop(){
  set +e
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  set -e
  sleep 10
}

do_status(){
  docker ps --filter "name=$CONTAINER_NAME"
}

# ENTER AWS OR AZURE CREDENTIALS TO RUN THE DOCKER IMAGE LOCALLY
while [ $# -gt 0 ]; do
  case "$1" in
    start|stop|restart|status|help)
      ACTION="$1"
      ;;
    -sb|--S3_BUCKET)
      S3_BUCKET="$2"
      shift
      ;;
    -sp|--S3_BUCKET_PREFIX)
      S3_BUCKET_PREFIX="$2"
      shift
      ;;
    -r|--AWS_REGION)
      AWS_REGION="$2"
      shift
      ;;
    -cn|--CONTAINER_NAME)
      CONTAINER_NAME="$2"
      shift
      ;;
    -du|--DOCKER_USER)
      DOCKER_USER="$2"
      shift
      ;;
    -sv|--SPARK_VERSION)
      SPARK_VERSION="$2"
      shift
      ;;
    -ak|--AWS_ACCESS_KEY_ID)
      AWS_ACCESS_KEY_ID="$2"
      shift
      ;;
    -as|--AWS_SECRET_ACCESS_KEY)
      AWS_SECRET_ACCESS_KEY="$2"
      shift
      ;;
    -at|--AWS_SESSION_TOKEN)
      AWS_SESSION_TOKEN="$2"
      shift
      ;;
    -p|--PORT)
      PORT="$2"
      shift
      ;;
    --azure-storage-account|--AZURE_STORAGE_ACCOUNT)
      AZURE_STORAGE_ACCOUNT="$2"
      shift
      ;;
    --azure-container|--AZURE_CONTAINER)
      AZURE_CONTAINER="$2"
      shift
      ;;
    --azure-tenant-id|--AZURE_TENANT_ID)
      AZURE_TENANT_ID="$2"
      shift
      ;;
    --azure-client-id|--AZURE_CLIENT_ID)
      AZURE_CLIENT_ID="$2"
      shift
      ;;
    --azure-client-secret|--AZURE_CLIENT_SECRET)
      AZURE_CLIENT_SECRET="$2"
      shift
      ;;
    --azure-event-logs-path|--AZURE_EVENT_LOGS_PATH)
      AZURE_EVENT_LOGS_PATH="$2"
      shift
      ;;
    *)
      printf "* Error: Invalid argument.*\n"
      print_help
      exit 1
  esac
  shift
done

if [ -z "$AWS_REGION" ]; then AWS_REGION="us-east-1" ; fi
if [ -z "$CONTAINER_NAME" ]; then CONTAINER_NAME="spark-history-server" ; fi
if [ -z "$DOCKER_USER" ]; then DOCKER_USER="$USER" ; fi
if [ -z "$SPARK_VERSION" ]; then SPARK_VERSION=$DEFAULT_SPARK_VERSION ; fi

CLASS="org.apache.spark.deploy.history.HistoryServer"
ENDPOINT="s3.$AWS_REGION.amazonaws.com"

if [ -n "$AWS_ACCESS_KEY_ID" ]; then export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" ; fi
if [ -n "$AWS_SECRET_ACCESS_KEY" ]; then export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" ; fi
if [ -n "$AWS_SESSION_TOKEN" ]; then export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" ; fi

#echo "Submitted args: $NAME $ACTION $S3_BUCKET $S3_BUCKET_PREFIX $AWS_REGION $CONTAINER_NAME $DOCKER_USER $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $AWS_SESSION_TOKEN"

case $ACTION in
  status)
        echo "Print status: "
        do_status
        ;;
  start)
        echo "Starting Spark History Server: "
        do_start
        do_status
        ;;
  stop)
        echo "Stopping Spark History Server: "
        do_stop
        ;;
  restart)
        echo "Restarting Spark History Server: "
        do_stop
        do_start
        do_status
        ;;
  *)
        print_help
        exit 1
esac

exit 0
