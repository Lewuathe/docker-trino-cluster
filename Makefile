PRESTO_VERSION := 326
PRESTO_SNAPSHOT_VERSION := 327-SNAPSHOT

.PHONY: build local push run down release

build:
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-base:${PRESTO_VERSION} presto-base
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-coordinator:${PRESTO_VERSION} presto-coordinator
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-worker:${PRESTO_VERSION} presto-worker
	PRESTO_VERSION=$(PRESTO_VERSION) docker-compose build

local:
	# docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} --platform linux/amd64 -f presto-base/Dockerfile-dev -t lewuathe/presto-base:${PRESTO_SNAPSHOT_VERSION} presto-base --push
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} --platform linux/arm64 -f presto-base/Dockerfile-aarch64 -t lewuathe/presto-base:${PRESTO_SNAPSHOT_VERSION} presto-base --push
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} --platform linux/arm64 -t lewuathe/presto-coordinator:${PRESTO_SNAPSHOT_VERSION} presto-coordinator --push
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} --platform linux/arm64 -t lewuathe/presto-worker:${PRESTO_SNAPSHOT_VERSION} presto-worker --push

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
