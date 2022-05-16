ARG VERSION

FROM satyakommula/trino-base:${VERSION}

COPY etc /usr/local/trino/etc
EXPOSE 8081

WORKDIR /usr/local/trino
ENTRYPOINT [ "./scripts/trino.sh" ]
