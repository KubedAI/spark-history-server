# Spark UI

## Creating Docker image for Spark History Server

### Pre-requisites

- Install Docker client locally

### Build Docker Image

#### Step1: Docker Build

The following step builds a docker image(`spark/spark-web-ui:latest`) using `Dockerfile` and `pom.xml` file. 

```shell
git clone https://github.com/Hyper-Mesh/spark-history-server.git
cd docker
docker build -t <docker-user-id>/spark-web-ui:latest . 
```

#### Step2: Docker Push

```shell script
docker push [OPTIONS] NAME[:TAG]
```

### Run Spark History Server as a local docker contianer

Checkout the instructions on this [shell script](https://github.com/Hyper-Mesh/spark-history-server/blob/main/docker/launch_spark_history_server_locally.sh) 
