#!/bin/bash

docker run -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME=$1 \
    -e DOCKERHUB_PASSWORD=$2 \
    -e DOCKERHUB_REPOSITORY='satyakommula/trino-coordinator' \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:latest
docker run -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME=$1 \
    -e DOCKERHUB_PASSWORD=$2 \
    -e DOCKERHUB_REPOSITORY='satyakommula/trino-worker' \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:latest