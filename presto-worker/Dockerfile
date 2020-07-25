ARG VERSION

FROM lewuathe/presto-base:${VERSION}
LABEL maintainer="lewuathe"

COPY etc /usr/local/presto/etc
EXPOSE 8081

WORKDIR /usr/local/presto
ENTRYPOINT [ "./scripts/presto.sh" ]
