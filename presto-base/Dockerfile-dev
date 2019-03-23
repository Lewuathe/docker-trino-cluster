#
# This docker image is for launching test purpose presto cluster.
#

FROM openjdk:8-slim
MAINTAINER lewuathe

ARG VERSION
ENV PRESTO_VERSION=${VERSION}
ENV PRESTO_HOME=/usr/local/presto
ENV BASE_URL=https://repo1.maven.org/maven2

# install dev tools
RUN apt-get update
RUN apt-get install -y curl tar sudo rsync python wget python-pip python-dev build-essential
RUN pip install jinja2

ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

WORKDIR /usr/local
ADD presto-server-${PRESTO_VERSION}.tar.gz /usr/local
#RUN tar xvzf presto-server-${PRESTO_VERSION}.tar.gz -C /usr/local/
RUN ln -s /usr/local/presto-server-${PRESTO_VERSION} $PRESTO_HOME

ADD scripts ${PRESTO_HOME}/scripts

# Create data dir
RUN mkdir -p $PRESTO_HOME/data
VOLUME ["$PRESTO_HOME/data"]
