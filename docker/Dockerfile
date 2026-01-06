# =============================================================================
# Spark History Server Docker Image
# =============================================================================
# This Dockerfile builds a Spark History Server image with cloud storage support
# (AWS S3 or Azure Data Lake Storage Gen2).
#
# Build arguments:
#   CLOUD_PLATFORM - Required. Values: "aws" or "azure"
#   SPARK_VERSION  - Required. Values: 3.5.7, 4.0.1, 4.1.0
#
# Example:
#   docker build --build-arg CLOUD_PLATFORM=aws --build-arg SPARK_VERSION=3.5.7 .
# =============================================================================

# --- Base Image ---
FROM maven:3.9-amazoncorretto-21-debian

# --- Build Arguments ---
# UID for the non-root user running the Spark History Server
ARG spark_uid=1000

# Cloud platform for storage integration (aws|azure)
ARG CLOUD_PLATFORM

# Spark version to install (must match a profile in pom.xml)
ARG SPARK_VERSION

# --- Argument Validation ---
RUN if [ "$CLOUD_PLATFORM" != "aws" ] && [ "$CLOUD_PLATFORM" != "azure" ]; then \
      >&2 echo 'CLOUD_PLATFORM build argument is required and must be "aws" or "azure". Add --build-arg CLOUD_PLATFORM="<aws|azure>" to your "docker build" command.' \
      && exit 1; \
    fi

RUN if [ -z "$SPARK_VERSION" ]; then \
      >&2 echo 'SPARK_VERSION build argument is required. Add --build-arg SPARK_VERSION="<version>" to your "docker build" command.' && exit 1; \
    fi && \
    case "$SPARK_VERSION" in \
      3.5.7|4.0.1|4.1.0) ;; \
      *) >&2 echo 'Invalid SPARK_VERSION. Allowed: 3.5.7, 4.0.1, 4.1.0.' && exit 1;; \
    esac

# --- Install Dependencies ---
RUN apt update && apt install -y curl

# Download official Spark distribution with Hadoop support
RUN curl -o ./spark-${SPARK_VERSION}-bin-hadoop3.tgz https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# --- Add Cloud Storage Dependencies ---
# Download cloud-specific Hadoop filesystem plugins via Maven.
# Note: If adding new dependencies to pom.xml, update includeGroupIds accordingly.
WORKDIR /tmp/
COPY pom.xml /tmp
RUN mvn -P${CLOUD_PLATFORM}-spark${SPARK_VERSION} dependency:copy-dependencies -DincludeGroupIds=org.apache.hadoop,software.amazon.awssdk,com.amazonaws -DoutputDirectory=/opt/spark/jars/

# --- Configure Non-Root User ---
# Create logs directory and register user in /etc/passwd (required by JVM tools)
RUN mkdir -p /opt/spark/logs && \
    chown -R ${spark_uid}:${spark_uid} /opt/spark && \
    echo "${spark_uid}:x:${spark_uid}:${spark_uid}:anonymous uid:/opt/spark:/bin/false" >> /etc/passwd

USER ${spark_uid}

WORKDIR /opt/spark

# --- Entrypoint ---
# Use bash to allow runtime command injection via CMD
# Example: CMD ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.history.HistoryServer"]
ENTRYPOINT ["/bin/bash", "-c"]