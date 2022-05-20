#!/bin/bash

discovery_uri=$1
if [[ -n "$2" ]]; then
  node_id=$2
else
  node_id=$(uuidgen)
fi
python3 /usr/local/trino/scripts/render.py \
  --node-id $node_id \
  --discovery-uri $discovery_uri \
  etc/node.properties.template \
  etc/config.properties.template

/usr/local/trino/bin/launcher run




