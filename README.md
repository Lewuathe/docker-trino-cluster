# ![GitHub branch checks state](https://img.shields.io/github/checks-status/satyakommula96/docker-trino-cluster/main) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/satyakommula96/docker-trino-cluster)

docker-trino-cluster is a simple tool for launching multiple node [trino](https://trinosql.io/) cluster on docker container.
The image is synched with the master branch of [trino repository](https://github.com/trinosql/trino). Therefore you can try the latest trino for developing purpose easily.

- [Features](#features)
- [Images](#images)
- [Usage](#usage)
  - [docker-compose.yml](#docker-composeyml)
- [Terraform](#terraform)
- [Development](#development)
  - [Build Image](#build-image)
  - [Snapshot Image](#snapshot-image)
- [LICENSE](#license)

## Features

- Multiple node cluster on docker container with docker-compose
- Distribution of pre-build trino docker images
- Override the catalog properties with custom one
- Terraform module to launch ECS based cluster

## Images

|Role|Image|Pulls|Tags|
|:---|:---|:---:|:---:|
|coordinator|satyakommula/trino-coordinator|[![Docker Pulls](https://img.shields.io/docker/pulls/satyakommula/trino-coordinator.svg)](https://cloud.docker.com/u/satyakommula/repository/docker/satyakommula/trino-coordinator)|[tags](https://cloud.docker.com/repository/docker/satyakommula/trino-coordinator/tags)|
|worker|satyakommula/trino-worker|[![Docker Pulls](https://img.shields.io/docker/pulls/satyakommula/trino-worker.svg)](https://cloud.docker.com/u/satyakommula/repository/docker/satyakommula/trino-worker)|[tags](https://cloud.docker.com/repository/docker/satyakommula/trino-worker/tags)|

We are also providing ARM based images. Images for ARM have suffix `-arm64v8` in the tag. For instance, the image of 336 has two types of images supporting multi-architectures. Following architectures are supported for now.

- `linux/amd64`
- `linux/arm64/v8`

## Usage

Images are uploaded in [DockerHub](https://hub.docker.com/). These images are build with the corresponding version of trino. Image tagged with 381 uses trino 381 inside. Each docker image gets two arguments

|Index|Argument|Description|
|:---|:---|:---|
|1|discovery_uri| Required parameter to specify the URI to coordinator host|
|2|node_id|Optional parameter to specify the node identity. UUID will be generated if not given|

You can launch multi node trino cluster in the local machine as follows.

```bash
# Create a custom network
$ docker network create trino_network

# Launch coordinator
$ docker run -p 8080:8080 -it \
    --net trino_network \
    --name coordinator \
    satyakommula/trino-coordinator:381-SNAPSHOT http://localhost:8080

# Launch two workers
$ docker run -it \
    --net trino_network \
    --name worker1 \
    satyakommula/trino-worker:381-SNAPSHOT http://coordinator:8080

$ docker run -it \
    --net trino_network \
    --name worker2 \
    satyakommula/trino-worker:381-SNAPSHOT http://coordinator:8080
```

## docker-compose.yml

[`docker-compose`](https://docs.docker.com/compose/compose-file/) enables us to coordinator multiple containers more easily. You can launch a multiple node docker trino cluster with the following yaml file. `command` is required to pass discovery URI and node id information which must be unique in a cluster. If node ID is not passed, the UUID is generated automatically at launch time.

```yaml
version: '3'

services:
  coordinator:
    image: "satyakommula/trino-coordinator:${trino_VERSION}"
    ports:
      - "8080:8080"
    container_name: "coordinator"
    command: http://coordinator:8080 coordinator
  worker0:
    image: "satyakommula/trino-worker:${trino_VERSION}"
    container_name: "worker0"
    ports:
      - "8081:8081"
    command: http://coordinator:8080 worker0
  worker1:
    image: "satyakommula/trino-worker:${trino_VERSION}"
    container_name: "worker1"
    ports:
      - "8082:8081"
    command: http://coordinator:8080 worker1
```

The version can be specified as the environment variable.

```bash
trino_VERSION=381-SNAPSHOT docker-compose up
```

## Custom Catalogs

While the image provides several default connectors (i.e. JMX, Memory, TPC-H and TPC-DS), you may want to override the catalog property with your own ones. That can be easily achieved by mounting the catalog directory onto `/usr/local/trino/etc/catalog`. Please look at [`volumes`](https://docs.docker.com/compose/compose-file/#volumes) configuration for docker-compose.

```yaml
services:
  coordinator:
    image: "satyakommula/trino-coordinator:${trino_VERSION}"
    ports:
      - "8080:8080"
    container_name: "coordinator"
    command: http://coordinator:8080 coordinator
    volumes:
      - ./example/etc/catalog:/usr/local/trino/etc/catalog
```

## Terraform

You can launch trino cluster on AWS Fargate by using [`terraform-aws-trino` module](https://github.com/satyakommula/terraform-aws-trino). The following Terraform configuration provides a trino cluster with 2 worker processes on Fargate.

```Terraform
module "trino" {
  source           = "github.com/satyakommula/terraform-aws-trino"
  cluster_capacity = 2
}

output "alb_dns_name" {
  value = module.trino.alb_dns_name
}
```

Please see [here](https://github.com/satyakommula96/terraform-aws-trino) for more detail.

## Development

## Build Image

```bash
make build
```

## Snapshot Image

You may want to build the trino with your own build package for the development of trino itself.

```bash
cp /path/to/trino/trino-server/target/trino-server-381-SNAPSHOT.tar.gz /path/to/docker-trino-cluster/trino-base/
make snapshot
```
