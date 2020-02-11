# docker-presto-cluster [![CircleCI](https://circleci.com/gh/Lewuathe/docker-presto-cluster.svg?style=svg)](https://circleci.com/gh/Lewuathe/docker-presto-cluster) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/Lewuathe/docker-presto-cluster) ![GitHub](https://img.shields.io/github/license/Lewuathe/docker-presto-cluster)

docker-presto-cluster is a simple tool for launching multiple node [Presto](https://prestosql.io/) cluster on docker container.
The image is synched with the master branch of [presto repository](https://github.com/prestosql/presto). Therefore you can try the latest presto for developing purpose easily.

# Images

|Role|Image|Pulls|Tags|
|:---|:---|:---:|:---:|
|coordinator|lewuathe/presto-coordinator|[![Docker Pulls](https://img.shields.io/docker/pulls/lewuathe/presto-coordinator.svg)](https://cloud.docker.com/u/lewuathe/repository/docker/lewuathe/presto-coordinator)|[tags](https://cloud.docker.com/repository/docker/lewuathe/presto-coordinator/tags)|
|worker|lewuathe/presto-worker|[![Docker Pulls](https://img.shields.io/docker/pulls/lewuathe/presto-worker.svg)](https://cloud.docker.com/u/lewuathe/repository/docker/lewuathe/presto-worker)|[tags](https://cloud.docker.com/repository/docker/lewuathe/presto-worker/tags)|

# Build Image

```
$ make build
```

# Local Image

You may want to build the Presto with your own build package for the development of Presto itself.

```
$ make local
```

# Launch presto

Presto cluster can be launched by using docker-compose. Images built previously is used for the cluster.

```
$ make run
```

## docker-compose.yml

Images are uploaded in [DockerHub](https://hub.docker.com/). These images are build with the corresponding version of Presto. Image tagged with 306 uses Presto 306. You can launch multiple node docker presto cluster with below yaml file. `command` is required to pass discovery URI and node id information which must be unique in a cluster. If node ID is not passed, the UUID is generated automatically at launch time.

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

Run

```
$ docker-compose up -d
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

# LICENSE

[Apache v2 License](https://github.com/Lewuathe/docker-presto-cluster/blob/master/LICENSE)
