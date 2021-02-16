#!/bin/bash

docker run -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME=${DOCKER_USERNAME} \
    -e DOCKERHUB_PASSWORD=${DOCKER_PASSWORD} \
    -e DOCKERHUB_REPOSITORY='lewuathe/trino-coordinator' \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:2.0.0
docker run -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME=${DOCKER_USERNAME} \
    -e DOCKERHUB_PASSWORD=${DOCKER_PASSWORD} \
    -e DOCKERHUB_REPOSITORY='lewuathe/trino-worker' \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:2.0.0