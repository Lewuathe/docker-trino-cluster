#
# This docker image is for launching test purpose trino cluster.
#

FROM openjdk:11-slim
LABEL maintainer="lewuathe"

ARG VERSION=355
ARG BASE_URL=https://repo1.maven.org/maven2
ENV TRINO_VERSION=${VERSION}
ENV TRINO_HOME=/usr/local/trino
ENV BASE_URL=${BASE_URL}

# install dev tools
RUN apt-get update && \
    apt-get install -y \
    curl \
    tar \
    sudo \
    rsync \
    python \
    wget \
    python3-pip \
    python-dev \
    build-essential \
    uuid-runtime \
    less && \
    pip install jinja2 && \
    apt-get purge -y

# java
# RUN mkdir -p /usr/java/default && \
#      curl -Ls 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie' | \
#      tar --strip-components=1 -xz -C /usr/java/default/

# ADD jdk-8u112-linux-x64.tar.gz /usr/java
# RUN sudo ln -s /usr/java/jdk1.8.0_112/ /usr/java/default

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin


WORKDIR /usr/local
RUN \
    wget -q -O bin/trino-cli ${BASE_URL}/io/trino/trino-cli/${TRINO_VERSION}/trino-cli-${TRINO_VERSION}-executable.jar && \
    chmod +x bin/trino-cli && \
    wget -q ${BASE_URL}/io/trino/trino-server/${TRINO_VERSION}/trino-server-${TRINO_VERSION}.tar.gz && \
    tar -xvzf trino-server-${TRINO_VERSION}.tar.gz -C /usr/local/ && \
    ln -s /usr/local/trino-server-${TRINO_VERSION} $TRINO_HOME && \
    mkdir -p $TRINO_HOME/data && \
    rm -f trino-server-${TRINO_VERSION}.tar.gz

ADD scripts ${TRINO_HOME}/scripts

VOLUME ["$TRINO_HOME/data"]
