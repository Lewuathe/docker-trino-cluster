ARG VERSION

FROM lewuathe/presto-base:${VERSION}
MAINTAINER lewuathe

COPY etc /usr/local/presto/etc
EXPOSE 8081

WORKDIR /usr/local/presto
ARG node_id
RUN python scripts/render.py --node-id $node_id etc/node.properties.template

CMD ["./bin/launcher", "run"]
