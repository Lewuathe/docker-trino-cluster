ARG VERSION

FROM lewuathe/presto-base:${VERSION}
MAINTAINER lewuathe

ADD etc /usr/local/presto/etc

EXPOSE 8080

WORKDIR /usr/local/presto
ENTRYPOINT ["./scripts/presto.sh"]
