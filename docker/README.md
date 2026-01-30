# 🐳 Spark History Server Docker Image

This guide explains how to build and run the Spark History Server using Docker.

## 📋 Prerequisites

- Git
- Docker client
- AWS credentials configured (if using S3)
- Azure Service Principal configured (if using ABFS - Azure Data Lake Storage Gen2)

## 🔧 Building the Docker Image

### 1. Clone the Repository

```bash
git clone https://github.com/kubedai/spark-history-server.git
cd spark-history-server/docker
```

### 2. Build the Image

**Use the provided build script to build the Docker image. You must specify the cloud platform (`aws` or `azure`):**

```bash
./build_image.sh <cloud-platform> -sv <spark-version> [image-tag] [-du|--DOCKER_USER <docker_user>]
# Example:
./build_image.sh aws
./build_image.sh azure my-custom-image:latest
./build_image.sh aws -du myuser
```

- `<cloud-platform>`: Required. Must be either `aws` or `azure`.
- `[image-tag]`: Optional. Defaults to `<docker_user>/spark-history-server:<cloud-platform>-latest`.
- `-du|--DOCKER_USER <docker_user>`: Optional. Docker user for image name. Defaults to your current user.

Alternatively, you can build manually:

```bash
docker build --build-arg SPARK_VERSION=<spark-version> --build-arg CLOUD_PLATFORM=<aws|azure> -t spark-history-server:latest-<aws|azure>-<spark-version> .
```

> Note: You can replace `spark-history-server:<aws|azure>-latest` with your preferred image name and tag.

### 3. Push to Registry (Optional)

If you want to push the image to a container registry:

```bash
# Tag the image for your registry
docker tag spark-history-server:<cloud-platform>-latest <your-registry>/spark-history-server:<cloud-platform>-latest

# Push to registry
docker push <your-registry>/spark-history-server:<cloud-platform>-latest
```

## 🚀 Running Locally

### Using the Helper Script

The repository includes a helper script to run the Spark History Server locally.  
**The script auto-detects the cloud platform (AWS or Azure) based on your environment variables and uses the correct Docker image tag.**

```bash
# Show help
./history_server.sh help

# Run with default settings (auto-detects AWS if S3_BUCKET is set, Azure if AZURE_CONTAINER is set)
./history_server.sh

# Run on a custom port (e.g., 19080)
./history_server.sh start -p 19080
```

### Manual Run

You can also run the container manually:

```bash
docker run -d \
  --name spark-history-server \
  -p 18080:18080 \
  -e SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=s3a://your-bucket/your-prefix/ -Dspark.history.ui.port=18080" \
  spark-history-server:<cloud-platform>-latest
```

To use a custom port (e.g., 19080):

```bash
docker run -d \
  --name spark-history-server \
  -p 19080:19080 \
  -e SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=s3a://your-bucket/your-prefix/ -Dspark.history.ui.port=19080" \
  spark-history-server:<cloud-platform>-latest
```

## 🔍 Accessing the UI

Once running, access the Spark History Server UI at:
- http://localhost:18080 (or your chosen port)

## ⚙️ Configuration

Key environment variables:
- `SPARK_HISTORY_OPTS`: Spark History Server configuration options
- `SPARK_CONF`: Additional Spark configuration properties

Example with custom configuration:

```bash
docker run -d \
  --name spark-history-server \
  -p 18080:18080 \
  -e SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=s3a://your-bucket/your-prefix/" \
  -e SPARK_CONF="spark.history.ui.port=18080" \
  spark-history-server:<cloud-platform>-latest
```

## 🔄 Updating the Image

To update to a newer version:

```bash
# Pull the latest changes
git pull

# Rebuild the image
./build_image.sh <cloud-platform>
```

## 🧹 Cleanup

To remove the container and image:

```bash
# Stop and remove container
docker stop spark-history-server
docker rm spark-history-server

# Remove image
docker rmi spark-history-server:<cloud-platform>-latest
```

If you don't want to pass the configurations in the command line, rename one of the .env example files to .env and edit the values in it.
The script will read and use the values from the .env file.
