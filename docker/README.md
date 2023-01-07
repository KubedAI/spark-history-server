# Spark UI

## Creating Docker image for Spark History Server

### Pre-requisites

- Install git
- Install Docker client locally

### Build Docker Image

#### Step1: Docker Build

The following step builds a docker image(`spark/spark-web-ui:latest`) using `Dockerfile` and `pom.xml` file. 

```shell
git clone https://github.com/Hyper-Mesh/spark-history-server.git
cd spark-history-server/docker
docker build -t $USER/spark-web-ui:latest . 
```

Please note the user used for building the image, if you are using a different user other than the current user, you will have to pass that information.

#### Step2: Docker Push (optional)

The step is optional to push the Docker Image to your repository, you may skip this if you are running locally.

```shell 
docker push [OPTIONS] NAME[:TAG]
```

### Run Spark History Server as a local docker container

Run "sh [launch_spark_history_server_locally.sh](launch_spark_history_server_locally.sh) help" to read how to use the helper script. 
