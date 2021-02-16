ARG VERSION

FROM lewuathe/trino-base:${VERSION}
LABEL maintainer="lewuathe"

ADD etc /usr/local/trino/etc

EXPOSE 8080

WORKDIR /usr/local/trino
ENTRYPOINT ["./scripts/trino.sh"]
