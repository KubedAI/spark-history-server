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

# Cloud platform for storage integration (aws|azure|gcp)
ARG CLOUD_PLATFORM

# Spark version to install (must match a profile in pom.xml)
ARG SPARK_VERSION

# --- Argument Validation ---
RUN if [ "$CLOUD_PLATFORM" != "aws" ] && [ "$CLOUD_PLATFORM" != "azure" ] && [ "$CLOUD_PLATFORM" != "gcp" ]; then \
      >&2 echo 'CLOUD_PLATFORM build argument is required and must be "aws", "azure", or "gcp". Add --build-arg CLOUD_PLATFORM="<aws|azure|gcp>" to your "docker build" command.' \
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
RUN GROUP_IDS="org.apache.hadoop,software.amazon.awssdk,com.amazonaws" && \
    if [ "$CLOUD_PLATFORM" = "gcp" ]; then GROUP_IDS="$GROUP_IDS,com.google.cloud.bigdataoss"; fi && \
    mvn -P${CLOUD_PLATFORM}-spark${SPARK_VERSION} dependency:copy-dependencies -DincludeGroupIds="$GROUP_IDS" -DoutputDirectory=/opt/spark/jars/

# --- Add Iceberg Dependencies ---
# Required for the History Server to deserialize custom Iceberg metrics from event logs.
# Determines Scala binary version based on Spark version (3.x uses 2.12, 4.x uses 2.13)
# Note: Iceberg does not yet publish a 4.1 runtime; Spark 4.1 uses the 4.0 artifact.
ARG ICEBERG_VERSION=1.10.1
RUN case "$SPARK_VERSION" in \
      3.*) SCALA_BINARY=2.12; SPARK_MAJOR=3.5 ;; \
      4.0.*) SCALA_BINARY=2.13; SPARK_MAJOR=4.0 ;; \
      4.1.*) SCALA_BINARY=2.13; SPARK_MAJOR=4.0 ;; \
    esac && \
    curl -fsSL -o /opt/spark/jars/iceberg-spark-runtime-${SPARK_MAJOR}_${SCALA_BINARY}-${ICEBERG_VERSION}.jar \
      https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-${SPARK_MAJOR}_${SCALA_BINARY}/${ICEBERG_VERSION}/iceberg-spark-runtime-${SPARK_MAJOR}_${SCALA_BINARY}-${ICEBERG_VERSION}.jar

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