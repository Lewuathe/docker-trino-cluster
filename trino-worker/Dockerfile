ARG VERSION

FROM lewuathe/trino-base:${VERSION}
LABEL maintainer="lewuathe"

COPY etc /usr/local/trino/etc
EXPOSE 8081

WORKDIR /usr/local/trino
ENTRYPOINT [ "./scripts/trino.sh" ]
