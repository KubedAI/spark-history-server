# Spark UI

## Creating Docker image for Spark History Server

### Pre-requisites

- Install maven
- Install git
- Install Docker client locally

### Build Docker Image

#### Step1: Docker Build

The following step builds a docker image(`spark/spark-web-ui:latest`) using `Dockerfile` and `pom.xml` file. 

```shell
git clone https://github.com/krishnadasmallya/spark-history-server.git
cd spark-history-server/docker
docker build -t $USER/spark-web-ui:latest . 
```

#### Step2: Docker Push (optional)

The step is optional to push the Docker Image to your repository, you may skip this if you are running locally.

```shell 
docker push [OPTIONS] NAME[:TAG]
```

### Run Spark History Server as a local docker container

Checkout the instructions on this [shell script](docker/launch_spark_history_server_locally.sh) 
