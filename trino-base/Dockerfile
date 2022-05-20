#
# This docker image is for launching test purpose trino cluster.
#

FROM openjdk:11-slim

ARG VERSION
ENV TRINO_VERSION=${VERSION}
ENV TRINO_HOME=/usr/local/trino
ENV BASE_URL=https://repo1.maven.org/maven2

# install dev tools
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
    curl \
    tar \
    sudo \
    rsync \
    python3 \
    wget \
    python3-pip \
    build-essential \
    uuid-runtime \
    less

RUN pip3 install jinja2
RUN ln -sf $(which python3) /usr/bin/python

# java
# RUN mkdir -p /usr/java/default && \
#      curl -Ls 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie' | \
#      tar --strip-components=1 -xz -C /usr/java/default/

# ADD jdk-8u112-linux-x64.tar.gz /usr/java
# RUN sudo ln -s /usr/java/jdk1.8.0_112/ /usr/java/default

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Add trino-cli
WORKDIR /usr/local/bin
RUN wget -q ${BASE_URL}/io/trino/trino-cli/${TRINO_VERSION}/trino-cli-${TRINO_VERSION}-executable.jar
RUN chmod +x trino-cli-${TRINO_VERSION}-executable.jar
RUN mv trino-cli-${TRINO_VERSION}-executable.jar trino-cli

WORKDIR /usr/local
# ADD trino-server-${TRINO_VERSION}.tar.gz /usr/local
RUN wget -q ${BASE_URL}/io/trino/trino-server/${TRINO_VERSION}/trino-server-${TRINO_VERSION}.tar.gz
RUN tar xvzf trino-server-${TRINO_VERSION}.tar.gz -C /usr/local/
RUN ln -s /usr/local/trino-server-${TRINO_VERSION} $TRINO_HOME

ADD scripts ${TRINO_HOME}/scripts

# Create data dir
RUN mkdir -p $TRINO_HOME/data
VOLUME ["$TRINO_HOME/data"]
