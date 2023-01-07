#!/bin/sh 
set -e

print_help(){
  # Display Help
   echo "A helper script to start/stop your local Spark History Server"
   echo
   echo "Syntax: sh launch_spark_history_server_locally.sh {start|stop|restart|status|help} {options}"
   echo
   echo "actions:"
   echo "start   start your local Spark History Server at 'localhost:18081'"
   echo "stop    stop the running Spark History Server"
   echo "restart restart the Spark History Server"
   echo "status  print the current running container details"
   echo "help    print this message"
   echo
   echo "start/restart options"
   echo "-sb or --S3_BUCKET             S3 bucket name where you have your Spark EventLogs. eg: my-bucket in 's3://my-bucket/evemts/'. REQUIRED with 'start/restart"
   echo "-sp or --S3_BUCKET_PREFIX      S3 bucket prefix where you have your Spark EventLogs. eg: 'spark/history/events' in 's3://my-bucket/spark/history/events/'. REQUIRED with 'start/restart'"
   echo "-r  or --AWS_REGION            Your AWS Region where the S3 bucket is in. Default: us-east-1"
   echo "-cn or --CONTAINER_NAME        Your Custom Container Name. Default: spark-history-server"
   echo "-du or --DOCKER_USER           The local user used to build/publish the docker image. Default: $USER, the current logged in user"
   echo "-ak or --AWS_ACCESS_KEY_ID     AWS access key id for authentication, optional: you may export ENV variables for the same"
   echo "-as or --AWS_SECRET_ACCESS_KEY AWS secret access key for authentication, optional: you may export ENV variables for the same"
   echo "-at or --AWS_SESSION_TOKEN     AWS session token for authentication, optional: you may export ENV variables for the same"
   echo
   echo "eg:"
   echo "sh launch_spark_history_server_locally.sh start -sb my-bucket -sp spark/history/events"
   echo "sh launch_spark_history_server_locally.sh stop"
   echo "sh launch_spark_history_server_locally.sh restart -sb my-bucket -sp spark/history/events"
   echo "sh launch_spark_history_server_locally.sh status"
   echo "sh launch_spark_history_server_locally.sh help"
   echo
}

do_start(){
  S3_BUCKET=$1
  S3_BUCKET_PREFIX=$2
  LOCAL_USER=$3

  LOG_DIR="s3a://$S3_BUCKET/$S3_BUCKET_PREFIX"
  DOCKER_IMAGE="$LOCAL_USER/spark-web-ui:latest"

  docker run -itd --name $CONTAINER_NAME -e SPARK_DAEMON_MEMORY="2g" -e SPARK_DAEMON_JAVA_OPTS="-XX:+UseG1GC" -e SPARK_HISTORY_OPTS="$SPARK_HISTORY_OPTS \
  -Dspark.history.fs.logDirectory=$LOG_DIR \
  -Dspark.hadoop.fs.s3a.access.key=$AWS_ACCESS_KEY_ID \
  -Dspark.hadoop.fs.s3a.secret.key=$AWS_SECRET_ACCESS_KEY \
  -Dspark.hadoop.fs.s3a.session.token=$AWS_SESSION_TOKEN \
  -Dspark.hadoop.fs.s3a.endpoint=$ENDPOINT \
  -Dspark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider" -p 18080:18080 $DOCKER_IMAGE "/opt/spark/bin/spark-class $CLASS"
  sleep 10
  echo "Spark History Server running @ http://localhost:18080 "
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

# ENTER AWS CREDENTIALS TO RUN THE DOCKER IMAGE LOCALLY
while [ $# -gt 0 ]; do
  case "$1" in
    start|stop|restart|status|help)
      ACTION="$1"
      ;;
    -sb|--S3_BUCKET)
      S3_BUCKET="$2"
      shift
      ;;
    -sp|--S3_PREFIX)
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
        do_start $S3_BUCKET $S3_BUCKET_PREFIX $DOCKER_USER
        do_status
        ;;
  stop)
        echo "Stopping  Spark History Server: "
        do_stop
        ;;
  restart)
        echo "Restarting  Spark History Server: "
        do_stop
        do_start $S3_BUCKET $S3_BUCKET_PREFIX $DOCKER_USER
        do_status
        ;;
  *)
        print_help
        exit 1
esac

exit 0