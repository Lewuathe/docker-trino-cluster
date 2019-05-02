#
# This docker image is for launching test purpose presto cluster.
#

FROM openjdk:8-slim
LABEL maintainer="lewuathe"

ARG VERSION
ENV PRESTO_VERSION=${VERSION}
ENV PRESTO_HOME=/usr/local/presto
ENV BASE_URL=https://repo1.maven.org/maven2

# install dev tools
RUN apt-get update
RUN apt-get install -y curl tar sudo rsync python wget python-pip python-dev build-essential
RUN pip install jinja2

# java
# RUN mkdir -p /usr/java/default && \
#      curl -Ls 'http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz' -H 'Cookie: oraclelicense=accept-securebackup-cookie' | \
#      tar --strip-components=1 -xz -C /usr/java/default/

# ADD jdk-8u112-linux-x64.tar.gz /usr/java
# RUN sudo ln -s /usr/java/jdk1.8.0_112/ /usr/java/default

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

WORKDIR /usr/local
# ADD presto-server-${PRESTO_VERSION}.tar.gz /usr/local
RUN wget -q ${BASE_URL}/io/prestosql/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz
RUN tar xvzf presto-server-${PRESTO_VERSION}.tar.gz -C /usr/local/
RUN ln -s /usr/local/presto-server-${PRESTO_VERSION} $PRESTO_HOME

ADD scripts ${PRESTO_HOME}/scripts

# Create data dir
RUN mkdir -p $PRESTO_HOME/data
VOLUME ["$PRESTO_HOME/data"]
