# 🐳 Spark History Server Docker Image

This guide explains how to build and run the Spark History Server using Docker.

## 📋 Prerequisites

- Git
- Docker client
- AWS credentials configured (if using S3)

## 🔧 Building the Docker Image

### 1. Clone the Repository

```bash
git clone https://github.com/kubedai/spark-history-server.git
cd spark-history-server/docker
```

### 2. Build the Image

Build the Docker image using the provided Dockerfile:

```bash
docker build -t spark-history-server:latest .
```

> Note: You can replace `spark-history-server:latest` with your preferred image name and tag.

### 3. Push to Registry (Optional)

If you want to push the image to a container registry:

```bash
# Tag the image for your registry
docker tag spark-history-server:latest <your-registry>/spark-history-server:latest

# Push to registry
docker push <your-registry>/spark-history-server:latest
```

## 🚀 Running Locally

### Using the Helper Script

The repository includes a helper script to run the Spark History Server locally:

```bash
# Show help
./launch_spark_history_server_locally.sh help

# Run with default settings
./launch_spark_history_server_locally.sh
```

### Manual Run

You can also run the container manually:

```bash
docker run -d \
  --name spark-history-server \
  -p 18080:18080 \
  -e SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=s3a://your-bucket/your-prefix/" \
  spark-history-server:latest
```

## 🔍 Accessing the UI

Once running, access the Spark History Server UI at:
- http://localhost:18080

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
  spark-history-server:latest
```

## 🔄 Updating the Image

To update to a newer version:

```bash
# Pull the latest changes
git pull

# Rebuild the image
docker build -t spark-history-server:latest .
```

## 🧹 Cleanup

To remove the container and image:

```bash
# Stop and remove container
docker stop spark-history-server
docker rm spark-history-server

# Remove image
docker rmi spark-history-server:latest
```
