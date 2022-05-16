#!/bin/bash

docker run -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME=${DOCKER_USERNAME} \
    -e DOCKERHUB_PASSWORD=${DOCKER_PASSWORD} \
    -e DOCKERHUB_REPOSITORY='satyakommula/trino-coordinator' \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:2.0.0
docker run -v $PWD:/workspace \
    -e DOCKERHUB_USERNAME=${DOCKER_USERNAME} \
    -e DOCKERHUB_PASSWORD=${DOCKER_PASSWORD} \
    -e DOCKERHUB_REPOSITORY='satyakommula/trino-worker' \
    -e README_FILEPATH='/workspace/README.md' \
    peterevans/dockerhub-description:2.0.0