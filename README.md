# docker-presto-cluster [![CircleCI](https://circleci.com/gh/Lewuathe/docker-presto-cluster.svg?style=svg)](https://circleci.com/gh/Lewuathe/docker-presto-cluster) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Lewuathe/docker-presto-cluster) ![GitHub](https://img.shields.io/github/license/Lewuathe/docker-presto-cluster)

docker-presto-cluster is a simple tool for launching multiple node [Presto](https://prestosql.io/) cluster on docker container.
The image is synched with the master branch of [presto repository](https://github.com/prestosql/presto). Therefore you can try the latest presto for developing purpose easily.

- [Features](#features)
- [Images](#images)
- [Usage](#usage)
  * [docker-compose.yml](#docker-composeyml)
- [Terraform](#terraform)
- [Development](#development)
  * [Build Image](#build-image)
  * [Snapshot Image](#snapshot-image)
- [LICENSE](#license)

# Features

- Multiple node cluster on docker container with docker-compose
- Distribution of pre-build Presto docker images
- Override the catalog properties with custom one
- Terraform module to launch ECS based cluster

# Images

|Role|Image|Pulls|Tags|
|:---|:---|:---:|:---:|
|coordinator|lewuathe/presto-coordinator|[![Docker Pulls](https://img.shields.io/docker/pulls/lewuathe/presto-coordinator.svg)](https://cloud.docker.com/u/lewuathe/repository/docker/lewuathe/presto-coordinator)|[tags](https://cloud.docker.com/repository/docker/lewuathe/presto-coordinator/tags)|
|worker|lewuathe/presto-worker|[![Docker Pulls](https://img.shields.io/docker/pulls/lewuathe/presto-worker.svg)](https://cloud.docker.com/u/lewuathe/repository/docker/lewuathe/presto-worker)|[tags](https://cloud.docker.com/repository/docker/lewuathe/presto-worker/tags)|

We are also providing ARM based images. Images for ARM have suffix `-arm64v8` in the tag. For instance, the image of 336 has two types of images supporting multi-architectures. Following architectures are supported for now.

- `linux/amd64`
- `linux/arm64/v8`

# Usage

Images are uploaded in [DockerHub](https://hub.docker.com/). These images are build with the corresponding version of Presto. Image tagged with 306 uses Presto 306 inside. Each docker image gets two arguments

|Index|Argument|Description|
|:---|:---|:---|
|1|discovery_uri| Required parameter to specify the URI to coordinator host|
|2|node_id|Optional parameter to specify the node identity. UUID will be generated if not given|

You can launch multi node Presto cluster in the local machine as follows.

```sh
# Create a custom network
$ docker network create presto_network

# Launch coordinator
$ docker run -p 8080:8080 -it \
    --net presto_network \
    --name coordinator \
    lewuathe/presto-coordinator:330-SNAPSHOT http://localhost:8080

# Launch two workers
$ docker run -it \
    --net presto_network \
    --name worker1 \
    lewuathe/presto-worker:330-SNAPSHOT http://coordinator:8080

$ docker run -it \
    --net presto_network \
    --name worker2 \
    lewuathe/presto-worker:330-SNAPSHOT http://coordinator:8080
```


## docker-compose.yml

[`docker-compose`](https://docs.docker.com/compose/compose-file/) enables us to coordinator multiple containers more easily. You can launch a multiple node docker presto cluster with the following yaml file. `command` is required to pass discovery URI and node id information which must be unique in a cluster. If node ID is not passed, the UUID is generated automatically at launch time.

```yaml
version: '3'

services:
  coordinator:
    image: "lewuathe/presto-coordinator:${PRESTO_VERSION}"
    ports:
      - "8080:8080"
    container_name: "coordinator"
    command: http://coordinator:8080 coordinator
  worker0:
    image: "lewuathe/presto-worker:${PRESTO_VERSION}"
    container_name: "worker0"
    ports:
      - "8081:8081"
    command: http://coordinator:8080 worker0
  worker1:
    image: "lewuathe/presto-worker:${PRESTO_VERSION}"
    container_name: "worker1"
    ports:
      - "8082:8081"
    command: http://coordinator:8080 worker1
```

The version can be specified as the environment variable.

```
$ PRESTO_VERSION=330-SNAPSHOT docker-compose up
```

# Custom Catalogs

While the image provides several default connectors (i.e. JMX, Memory, TPC-H and TPC-DS), you may want to override the catalog property with your own ones. That can be easily achieved by mounting the catalog directory onto `/usr/local/presto/etc/catalog`. Please look at [`volumes`](https://docs.docker.com/compose/compose-file/#volumes) configuration for docker-compose.

```yaml
services:
  coordinator:
    image: "lewuathe/presto-coordinator:${PRESTO_VERSION}"
    ports:
      - "8080:8080"
    container_name: "coordinator"
    command: http://coordinator:8080 coordinator
    volumes:
      - ./example/etc/catalog:/usr/local/presto/etc/catalog
```

# Terraform

You can launch Presto cluster on AWS Fargate by using [`terraform-aws-presto` module](https://github.com/Lewuathe/terraform-aws-presto). The following Terraform configuration provides a Presto cluster with 2 worker processes on Fargate.

```
module "presto" {
  source           = "github.com/Lewuathe/terraform-aws-presto"
  cluster_capacity = 2
}

output "alb_dns_name" {
  value = module.presto.alb_dns_name
}
```

Please see [here](https://github.com/Lewuathe/terraform-aws-presto) for more detail.


# Development

## Build Image

```
$ make build
```

## Snapshot Image

You may want to build the Presto with your own build package for the development of Presto itself.

```
$ cp /path/to/presto/presto-server/target/presto-server-330-SNAPSHOT.tar.gz /path/to/docker-presto-cluster/presto-base/
$ make snapshot
```

# LICENSE

[Apache v2 License](https://github.com/Lewuathe/docker-presto-cluster/blob/master/LICENSE)
