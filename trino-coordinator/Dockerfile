ARG VERSION

FROM satyakommula/trino-base:${VERSION}

ADD etc /usr/local/trino/etc

EXPOSE 8080

WORKDIR /usr/local/trino
ENTRYPOINT ["./scripts/trino.sh"]
