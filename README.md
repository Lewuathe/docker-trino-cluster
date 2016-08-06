# docker-presto-cluster

docker-presto-cluster is a timple tool for launching multiple node [Presto](https://prestodb.io/) cluster on docker container.

## Build image

```
$ cd presto-base
$ docker built -t lewuathe/presto-base:latest .
```

## Launch presto

Presto cluster can be launched by using docker-compose.

```
$ cd docker-presto-cluster
# Build images
$ docker-compose build
# Launch docker containers
$ docker-compose up -d
```

# LICENSE

[MIT License](https://github.com/Lewuathe/docker-presto-cluster/blob/master/LICENSE)
