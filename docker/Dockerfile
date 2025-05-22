# Base image with Maven and Amazon Corretto 8 (Java 8)
# This is suitable for building Spark-compatible Java applications and resolving Maven dependencies
FROM maven:3.6-amazoncorretto-8

# Define a UID for the non-root user to run Spark History Server securely
ARG spark_uid=1000

# Set working directory for the build phase
WORKDIR /tmp/

# Install essential utilities:
# - procps: for basic process inspection (e.g., `ps`)
# - curl: for downloading Spark binaries
# - tar: for unpacking Spark archive
RUN yum install -y procps curl tar && yum clean all

# Copy the Maven POM file into the image
# This is used to resolve all Hadoop, AWS SDK, and other dependencies
COPY pom.xml /tmp

# Download the Apache Spark binary (without Hadoop) to allow for custom Hadoop integrations
# Unpack Spark into /opt/spark, which is the conventional install path
RUN curl -o ./spark-3.5.1-bin-without-hadoop.tgz https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-without-hadoop.tgz && \
    tar -xzf spark-3.5.1-bin-without-hadoop.tgz && \
    mv spark-3.5.1-bin-without-hadoop /opt/spark && \
    rm spark-3.5.1-bin-without-hadoop.tgz

# Use Maven to resolve and copy all runtime dependencies from the pom.xml
# into Spark's JAR directory. This ensures S3/Hadoop/AWS SDK integration.
# Then remove conflicting or outdated jars to prevent runtime classloader issues.
RUN mvn dependency:copy-dependencies -DoutputDirectory=/opt/spark/jars/ && \
    rm -f /opt/spark/jars/jsr305-3.0.0.jar && \
    rm -f /opt/spark/jars/jersey-*-1.19.jar && \
    rm -f /opt/spark/jars/joda-time-2.8.1.jar && \
    rm -f /opt/spark/jars/jmespath-java-*.jar && \
    rm -f /opt/spark/jars/aws-java-sdk-core-*.jar && \
    rm -f /opt/spark/jars/aws-java-sdk-kms-*.jar && \
    rm -f /opt/spark/jars/aws-java-sdk-s3-*.jar && \
    rm -f /opt/spark/jars/ion-java-1.0.2.jar

# Create Spark logs directory and assign ownership to the non-root user
# Also inject the user into /etc/passwd (required by some JVM tools and shells)
RUN mkdir -p /opt/spark/logs && \
    chown -R ${spark_uid}:${spark_uid} /opt/spark && \
    echo "${spark_uid}:x:${spark_uid}:${spark_uid}:anonymous uid:/opt/spark:/bin/false" >> /etc/passwd

# Switch to non-root user for security best practices
USER ${spark_uid}

# Set working directory to Spark home
WORKDIR /opt/spark

# Use bash as the entrypoint to allow Helm, K8s, or CI to pass runtime commands via CMD
# For example: 
# CMD ["/opt/spark/bin/spark-class", "org.apache.spark.deploy.history.HistoryServer"]
ENTRYPOINT ["/bin/bash", "-c"]