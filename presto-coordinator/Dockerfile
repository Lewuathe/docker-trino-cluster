ARG VERSION

FROM lewuathe/presto-base:${VERSION}
LABEL maintainer="lewuathe"

ADD etc /usr/local/presto/etc

EXPOSE 8080

WORKDIR /usr/local/presto
ENTRYPOINT ["./scripts/presto.sh"]
