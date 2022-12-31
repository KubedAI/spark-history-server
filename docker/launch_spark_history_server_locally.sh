#!/bin/sh 
set -e
# ENTER AWS CREDENTIALS TO RUN THE DOCKER IMAGE LOCALLY

CLASS="org.apache.spark.deploy.history.HistoryServer"
AWS_REGION="${4:-us-east-1}"
ENDPOINT="s3.$AWS_REGION.amazonaws.com"
CONTAINER_NAME="${5:-spark-history-server}"
do_start(){
	S3_BUCKET=$1
	S3_BUCKET_PREFIX=$2
	LOG_DIR="s3a://$S3_BUCKET/$S3_BUCKET_PREFIX"
	DOCKER_IMAGE="$USER/spark-web-ui:latest"

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

print_help(){
	# Display Help
   echo "A helper script to start/stop your local Spark History Server"
   echo
   echo "Prerequisites:"
   echo "export AWS CREDENTIALS: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY & AWS_SESSION_TOKEN before using this script"
   echo
   echo "Syntax: sh launch_spark_history_server_locally.sh {start|stop|restart|status|help} {S3_BUCKET} {S3_BUCKET_PREFIX} {AWS_REGION} {CONTAINER_NAME}"
   echo
   echo "options:"
   echo "start   start your local Spark History Server at 'localhost:18081'"
   echo "stop    stop the running Spark History Server"
   echo "restart restart the Spark History Server"
   echo "status  print the current running container details"
   echo "help    print this message"
   echo
   echo "start/restart options"
   echo "S3_BUCKET          S3 bucket name where you have your Spark EventLogs. eg: my-bucket in 's3://my-bucket/evemts/'. REQUIRED with 'start'"
   echo "S3_BUCKET_PREFIX   S3 bucket prefix where you have your Spark EventLogs. eg: 'spark/history/events' in 's3://my-bucket/spark/history/events/'. REQUIRED with 'start'"
   echo "AWS_REGION         Your AWS Region where the S3 bucket is in. Default: us-east-1"
   echo "CONTAINER_NAME     Your Custom Container Name. Default: spark-history-server"
   echo
   echo "eg:"
   echo "sh launch_spark_history_server_locally.sh start my-bucket spark/history/events"
   echo "sh launch_spark_history_server_locally.sh stop"
   echo "sh launch_spark_history_server_locally.sh restart my-bucket spark/history/events"
   echo "sh launch_spark_history_server_locally.sh status"
   echo "sh launch_spark_history_server_locally.sh help"
   echo
}

case "$1" in
  status)
        do_status
        ;;
  start)
        echo "Starting Spark History Server: "$NAME
        do_start $2 $3
        ;;
  stop)
        echo "Stopping  Spark History Server: "$NAME
        do_stop
        ;;
  restart)
        echo "Restarting  Spark History Server: "$NAME
        do_stop
        do_start $2 $3
        ;;
  *)
        print_help
        exit 1
esac

exit 0