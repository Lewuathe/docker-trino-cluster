PRESTO_VERSION := 326
PRESTO_SNAPSHOT_VERSION := 327-SNAPSHOT

.PHONY: build local push run down release

build:
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-base:${PRESTO_VERSION} presto-base
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-coordinator:${PRESTO_VERSION} presto-coordinator
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-worker:${PRESTO_VERSION} presto-worker
	PRESTO_VERSION=$(PRESTO_VERSION) docker-compose build

local:
	docker build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -f presto-base/Dockerfile-dev -t lewuathe/presto-base:${PRESTO_SNAPSHOT_VERSION} presto-base
	docker build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -t lewuathe/presto-coordinator:${PRESTO_SNAPSHOT_VERSION} presto-coordinator
	docker build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -t lewuathe/presto-worker:${PRESTO_SNAPSHOT_VERSION} presto-worker

aarch64:
	docker buildx build --platform linux/arm64 --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -f presto-base/Dockerfile-aarch64 -t lewuathe/presto-base:${PRESTO_SNAPSHOT_VERSION}-aarch64 presto-base
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -t lewuathe/presto-coordinator:${PRESTO_SNAPSHOT_VERSION}-aarch64 presto-coordinator
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -t lewuathe/presto-worker:${PRESTO_SNAPSHOT_VERSION}-aarch64 presto-worker
	docker push lewuathe/presto-base:$(PRESTO_SNAPSHOT_VERSION)-aarch64
	docker push lewuathe/presto-coordinator:$(PRESTO_SNAPSHOT_VERSION)-aarch64
	docker push lewuathe/presto-worker:$(PRESTO_SNAPSHOT_VERSION)-aarch64

push: build
	docker push lewuathe/presto-base:$(PRESTO_VERSION)
	docker push lewuathe/presto-coordinator:$(PRESTO_VERSION)
	docker push lewuathe/presto-worker:$(PRESTO_VERSION)
	sh ./update-readme.sh

run:
	PRESTO_VERSION=$(PRESTO_VERSION) docker-compose up -d
	echo "Please check http://localhost:8080"

down:
	PRESTO_VERSION=$(PRESTO_VERSION) docker-compose down

release:
	git tag -a ${PRESTO_VERSION} -m "Release ${PRESTO_VERSION}"
	git push --tags
