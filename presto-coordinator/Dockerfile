FROM lewuathe/presto-base:latest
MAINTAINER lewuathe

COPY etc /usr/local/presto/etc
EXPOSE 8080

WORKDIR /usr/local/presto

ENTRYPOINT ["./bin/launcher", "run"]
