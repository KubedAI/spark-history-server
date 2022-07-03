# Spark UI

## Creating Docker image for Spark History Server

### Pre-requisites

- Install Docker client locally

### Build Docker Image

#### Step1: Docker Build

The following step builds a docker image(`spark/spark-web-ui:latest`) using `Dockerfile` and `pom.xml` file. 

```shell
cd spark-history-server/docker
docker build -t varabonthu/spark-web-ui:latest . 
```

#### Step2: Docker Push

```shell script
docker push [OPTIONS] NAME[:TAG]
```
