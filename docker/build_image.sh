#!/bin/sh
set -e

if [ $# -lt 1 ]; then
  echo "Usage: $0 <cloud-platform> [image-tag] [-du|--DOCKER_USER <docker_user>]"
  echo "  <cloud-platform>: aws | azure"
  echo "  [image-tag]: Optional. Defaults to <docker_user>/spark-history-server:<cloud-platform>-latest"
  echo "  -du|--DOCKER_USER: Optional. Docker user for image name. Defaults to \$USER."
  exit 1
fi

DOCKER_USER="${USER:-sparkuser}"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -du|--DOCKER_USER)
      DOCKER_USER="$2"
      shift
      ;;
    aws|azure)
      CLOUD_PLATFORM="$1"
      ;;
    *)
      if [ -z "$IMAGE_TAG" ]; then
        IMAGE_TAG="$1"
      fi
      ;;
  esac
  shift
done

if [ -z "$CLOUD_PLATFORM" ]; then
  echo "Usage: $0 <cloud-platform> [image-tag] [-du|--DOCKER_USER <docker_user>]"
  echo "  <cloud-platform>: aws | azure"
  echo "  [image-tag]: Optional. Defaults to <docker_user>/spark-history-server:<cloud-platform>-latest"
  echo "  -du|--DOCKER_USER: Optional. Docker user for image name. Defaults to \$USER."
  exit 1
fi

if [ "$CLOUD_PLATFORM" != "aws" ] && [ "$CLOUD_PLATFORM" != "azure" ]; then
  echo "Error: CLOUD_PLATFORM must be 'aws' or 'azure'."
  exit 2
fi

if [ -z "$IMAGE_TAG" ]; then
  IMAGE_TAG="${DOCKER_USER}/spark-history-server:${CLOUD_PLATFORM}-latest"
fi

docker build --build-arg CLOUD_PLATFORM="$CLOUD_PLATFORM" -t "$IMAGE_TAG" .
echo "Docker image built and tagged as $IMAGE_TAG"
