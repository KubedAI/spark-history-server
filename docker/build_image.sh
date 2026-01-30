#!/bin/sh
set -e

DEFAULT_SPARK_VERSION="4.1.0"
ALLOWED_SPARK_VERSIONS="3.5.7 4.0.1 4.1.0"

usage() {
  echo "Usage: $0 <cloud-platform> [image-tag] [-du|--DOCKER_USER <docker_user>] [-sv|--SPARK_VERSION <spark_version>]"
  echo "  <cloud-platform>: aws | azure"
  echo "  [image-tag]: Optional. Defaults to <docker_user>/spark-history-server:latest-<cloud-platform>-<spark_version>"
  echo "  -du|--DOCKER_USER: Optional. Docker user for image name. Defaults to \$USER."
  echo "  -sv|--SPARK_VERSION: Optional. Spark version to use. Defaults to $DEFAULT_SPARK_VERSION"
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

DOCKER_USER="${USER:-sparkuser}"
SPARK_VERSION=$DEFAULT_SPARK_VERSION

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -du|--DOCKER_USER)
      DOCKER_USER="$2"
      shift
      ;;
    -sv|--SPARK_VERSION)
      SPARK_VERSION="$2"
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
  usage
  exit 1
fi

if [ "$CLOUD_PLATFORM" != "aws" ] && [ "$CLOUD_PLATFORM" != "azure" ]; then
  echo "Error: CLOUD_PLATFORM must be 'aws' or 'azure'."
  exit 2
fi

if ! echo "$ALLOWED_SPARK_VERSIONS" | tr ' ' '\n' | grep -Fxq "$SPARK_VERSION"; then
  >&2 echo "Invalid SPARK_VERSION $SPARK_VERSION. Allowed: $ALLOWED_SPARK_VERSIONS."
  exit 1
fi

if [ -z "$IMAGE_TAG" ]; then
  IMAGE_TAG="${DOCKER_USER}/spark-history-server:latest-${CLOUD_PLATFORM}-${SPARK_VERSION}"
fi

docker build --build-arg CLOUD_PLATFORM="$CLOUD_PLATFORM" --build-arg SPARK_VERSION="$SPARK_VERSION" -t "$IMAGE_TAG" --progress plain .
echo "Docker image built and tagged as $IMAGE_TAG"
