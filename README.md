# docker-presto-cluster [![CircleCI](https://circleci.com/gh/Lewuathe/docker-presto-cluster.svg?style=svg)](https://circleci.com/gh/Lewuathe/docker-presto-cluster)

docker-presto-cluster is a simple tool for launching multiple node [Presto](https://prestosql.io/) cluster on docker container.
The image is synched with the master branch of [presto repository](https://github.com/prestosql/presto). Therefore you can try the latest presto for developing purpose easily.

## Build image

```
$ make
```

## Launch presto

Presto cluster can be launched by using docker-compose.

```
$ make run
```

## docker-compose.yml

Images are uploaded in [DockerHub](https://hub.docker.com/). These images are build with the corresponding version of Presto. Image tagged with 306 uses Presto 306. You can launch multiple node docker presto cluster with below yaml file. `command` is required to pass node id information which must be unique in a cluster.

```
version: '3'

services:
  coordinator:
    image: lewuathe/presto-coordinator:307-SNAPSHOT
    ports:
      - "8080:8080"
    container_name: "coordinator"
    command: coordinator
  worker0:
    image: lewuathe/presto-worker:307-SNAPSHOT
    container_name: "worker0"
    ports:
      - "8081:8081"
    command: worker0
  worker1:
    image: lewuathe/presto-worker:307-SNAPSHOT
    container_name: "worker1"
    ports:
      - "8082:8081"
    command: worker1
```

Run

```
$ docker-compose up -d
```

# LICENSE

[Apache v2 License](https://github.com/Lewuathe/docker-presto-cluster/blob/master/LICENSE)
