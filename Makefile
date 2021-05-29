TRINO_VERSION := 353
TRINO_SNAPSHOT_VERSION := 354-SNAPSHOT

.PHONY: build local push run down release

build:
	docker build --build-arg VERSION=${TRINO_VERSION} -t lewuathe/trino-base:${TRINO_VERSION} trino-base
	docker build --build-arg VERSION=${TRINO_VERSION} -t lewuathe/trino-coordinator:${TRINO_VERSION} trino-coordinator
	docker build --build-arg VERSION=${TRINO_VERSION} -t lewuathe/trino-worker:${TRINO_VERSION} trino-worker

snapshot:
	docker build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} -f trino-base/Dockerfile-dev -t lewuathe/trino-base:${TRINO_SNAPSHOT_VERSION} trino-base
	docker build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} -t lewuathe/trino-coordinator:${TRINO_SNAPSHOT_VERSION} trino-coordinator
	docker build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} -t lewuathe/trino-worker:${TRINO_SNAPSHOT_VERSION} trino-worker
	docker push lewuathe/trino-base:$(TRINO_SNAPSHOT_VERSION)
	docker push lewuathe/trino-coordinator:$(TRINO_SNAPSHOT_VERSION)
	docker push lewuathe/trino-worker:$(TRINO_SNAPSHOT_VERSION)

# Experimental
arm64v8:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx build --build-arg VERSION=${TRINO_VERSION} --platform linux/arm64/v8 -f trino-base/Dockerfile-aarch64 -t lewuathe/trino-base:${TRINO_VERSION}-arm64v8 trino-base
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/trino-coordinator:${TRINO_VERSION}-arm64v8 trino-coordinator
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/trino-worker:${TRINO_VERSION}-aarch64 trino-worker

push_arm64v8:
	docker buildx build --build-arg VERSION=${TRINO_VERSION} --platform linux/arm64/v8 -f trino-base/Dockerfile-aarch64 -t lewuathe/trino-base:${TRINO_VERSION}-arm64v8 trino-base --push
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/trino-coordinator:${TRINO_VERSION}-arm64v8 trino-coordinator --push
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v8 --platform linux/arm64/v8 -t lewuathe/trino-worker:${TRINO_VERSION}-arm64v8 trino-worker --push

# Experimental
corretto:
	docker buildx build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} --platform linux/arm64 -f trino-base/Dockerfile-corrett -t lewuathe/trino-base:${TRINO_SNAPSHOT_VERSION}-corretto trino-base --push
	docker buildx build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION}-corretto --platform linux/arm64 -t lewuathe/trino-coordinator:${TRINO_SNAPSHOT_VERSION}-corretto trino-coordinator --push
	docker buildx build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION}-corretto --platform linux/arm64 -t lewuathe/trino-worker:${TRINO_SNAPSHOT_VERSION}-corretto trino-worker --push

push: build push_arm64v8
	docker push lewuathe/trino-base:$(TRINO_VERSION)
	docker push lewuathe/trino-coordinator:$(TRINO_VERSION)
	docker push lewuathe/trino-worker:$(TRINO_VERSION)
	sh ./update-readme.sh

run: build
	TRINO_VERSION=$(TRINO_VERSION) docker-compose up -d
	echo "Please check http://localhost:8080"

test: build
	./test-container.sh $(TRINO_VERSION)

down:
	TRINO_VERSION=$(TRINO_VERSION) docker-compose down

release:
	git tag -a ${TRINO_VERSION} -m "Release ${TRINO_VERSION}"
	git push --tags
