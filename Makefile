PRESTO_VERSION := 343
PRESTO_SNAPSHOT_VERSION := 344-SNAPSHOT

.PHONY: build local push run down release

build:
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-base:${PRESTO_VERSION} presto-base
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-coordinator:${PRESTO_VERSION} presto-coordinator
	docker build --build-arg VERSION=${PRESTO_VERSION} -t lewuathe/presto-worker:${PRESTO_VERSION} presto-worker

snapshot:
	docker build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -f presto-base/Dockerfile-dev -t lewuathe/presto-base:${PRESTO_SNAPSHOT_VERSION} presto-base
	docker build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -t lewuathe/presto-coordinator:${PRESTO_SNAPSHOT_VERSION} presto-coordinator
	docker build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} -t lewuathe/presto-worker:${PRESTO_SNAPSHOT_VERSION} presto-worker
	docker push lewuathe/presto-base:$(PRESTO_SNAPSHOT_VERSION)
	docker push lewuathe/presto-coordinator:$(PRESTO_SNAPSHOT_VERSION)
	docker push lewuathe/presto-worker:$(PRESTO_SNAPSHOT_VERSION)

# Experimental
arm64v8:
	docker buildx build --build-arg VERSION=${PRESTO_VERSION} --platform linux/arm64/v8 -f presto-base/Dockerfile-aarch64 -t lewuathe/presto-base:${PRESTO_VERSION}-arm64v8 presto-base
	docker buildx build --build-arg VERSION=${PRESTO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/presto-coordinator:${PRESTO_VERSION}-arm64v8 presto-coordinator
	docker buildx build --build-arg VERSION=${PRESTO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/presto-worker:${PRESTO_VERSION}-aarch64 presto-worker

push_arm64v8:
	docker buildx build --build-arg VERSION=${PRESTO_VERSION} --platform linux/arm64/v8 -f presto-base/Dockerfile-aarch64 -t lewuathe/presto-base:${PRESTO_VERSION}-arm64v8 presto-base --push
	docker buildx build --build-arg VERSION=${PRESTO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/presto-coordinator:${PRESTO_VERSION}-arm64v8 presto-coordinator --push
	docker buildx build --build-arg VERSION=${PRESTO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/presto-worker:${PRESTO_VERSION}-arm64v8 presto-worker --push

# Experimental
corretto:
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION} --platform linux/arm64 -f presto-base/Dockerfile-corrett -t lewuathe/presto-base:${PRESTO_SNAPSHOT_VERSION}-corretto presto-base --push
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION}-corretto --platform linux/arm64 -t lewuathe/presto-coordinator:${PRESTO_SNAPSHOT_VERSION}-corretto presto-coordinator --push
	docker buildx build --build-arg VERSION=${PRESTO_SNAPSHOT_VERSION}-corretto --platform linux/arm64 -t lewuathe/presto-worker:${PRESTO_SNAPSHOT_VERSION}-corretto presto-worker --push

push: build push_arm64v8
	docker push lewuathe/presto-base:$(PRESTO_VERSION)
	docker push lewuathe/presto-coordinator:$(PRESTO_VERSION)
	docker push lewuathe/presto-worker:$(PRESTO_VERSION)
	sh ./update-readme.sh

run:
	PRESTO_VERSION=$(PRESTO_VERSION) docker-compose up -d
	echo "Please check http://localhost:8080"

test: run
	./test-container.sh $(PRESTO_VERSION)

down:
	PRESTO_VERSION=$(PRESTO_VERSION) docker-compose down

release:
	git tag -a ${PRESTO_VERSION} -m "Release ${PRESTO_VERSION}"
	git push --tags
