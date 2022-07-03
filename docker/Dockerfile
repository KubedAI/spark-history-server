FROM amazonlinux:2
FROM amazoncorretto:8
FROM maven:3.6-amazoncorretto-8

ARG spark_uid=1000
RUN yum install -y procps

WORKDIR /tmp/
ADD pom.xml /tmp
RUN curl -o ./spark-3.1.1-bin-without-hadoop.tgz https://archive.apache.org/dist/spark/spark-3.1.1/spark-3.1.1-bin-without-hadoop.tgz
RUN tar -xzf spark-3.1.1-bin-without-hadoop.tgz && \
    mv spark-3.1.1-bin-without-hadoop /opt/spark && \
    rm spark-3.1.1-bin-without-hadoop.tgz
RUN mvn dependency:copy-dependencies -DoutputDirectory=/opt/spark/jars/
RUN rm /opt/spark/jars/jsr305-3.0.0.jar && \
    rm /opt/spark/jars/jersey-*-1.19.jar && \
    rm /opt/spark/jars/joda-time-2.8.1.jar && \
    rm /opt/spark/jars/jmespath-java-*.jar && \
    rm /opt/spark/jars/aws-java-sdk-core-*.jar && \
    rm /opt/spark/jars/aws-java-sdk-kms-*.jar && \
    rm /opt/spark/jars/aws-java-sdk-s3-*.jar && \
    rm /opt/spark/jars/ion-java-1.0.2.jar

RUN mkdir -p /opt/spark/logs && chown -R 1000:1000 /opt/spark

RUN echo '1000:x:1000:1000:anonymous uid:/opt/spark:/bin/false' >> /etc/passwd

USER ${spark_uid}

ENTRYPOINT ["/bin/bash", "-c"]: