TRINO_VERSION := 381
TRINO_SNAPSHOT_VERSION := 381-SNAPSHOT

.PHONY: build local push run down release
uname_m := $(shell uname -m)

build:
ifeq ($(uname_m),x86_64)
	@echo "x86 build"
	docker build --build-arg VERSION=${TRINO_VERSION} -t satyakommula/trino-base:${TRINO_VERSION} trino-base
	docker build --build-arg VERSION=${TRINO_VERSION} -t satyakommula/trino-coordinator:${TRINO_VERSION} trino-coordinator
	docker build --build-arg VERSION=${TRINO_VERSION} -t satyakommula/trino-worker:${TRINO_VERSION} trino-worker
endif

ifeq ($(uname_m),armv71)
	@echo "armv71 build"
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx build --build-arg VERSION=${TRINO_VERSION} --platform linux/arm64/v7 -f trino-base/Dockerfile-aarch64 -t satyakommula/trino-base:${TRINO_VERSION}-arm64v7 trino-base --load
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v7 --platform linux/arm64/v7 -t satyakommula/trino-coordinator:${TRINO_VERSION}-arm64v7 trino-coordinator --load
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v7 --platform linux/arm64/v7 -t satyakommula/trino-worker:${TRINO_VERSION}-aarch64 trino-worker --load
endif

snapshot:
	docker build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} -f trino-base/Dockerfile-dev -t satyakommula/trino-base:${TRINO_SNAPSHOT_VERSION} trino-base
	docker build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} -t satyakommula/trino-coordinator:${TRINO_SNAPSHOT_VERSION} trino-coordinator
	docker build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} -t satyakommula/trino-worker:${TRINO_SNAPSHOT_VERSION} trino-worker
	docker push satyakommula/trino-base:${TRINO_SNAPSHOT_VERSION}
	docker push satyakommula/trino-coordinator:${TRINO_SNAPSHOT_VERSION}
	docker push satyakommula/trino-worker:${TRINO_SNAPSHOT_VERSION}
	
push_arm64v7:
	docker buildx build --build-arg VERSION=${TRINO_VERSION} --platform linux/arm64/v8 -f trino-base/Dockerfile-aarch64 -t satyakommula/trino-base:${TRINO_VERSION}-arm64v7 trino-base --push
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v7 --platform linux/arm64/v8 -t satyakommula/trino-coordinator:${TRINO_VERSION}-arm64v7 trino-coordinator --push
	docker buildx build --build-arg VERSION=${TRINO_VERSION}-arm64v7 --platform linux/arm64/v8 -t satyakommula/trino-worker:${TRINO_VERSION}-arm64v7 trino-worker --push

# Experimental
corretto:
	docker buildx build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION} --platform linux/arm64 -f trino-base/Dockerfile-corrett -t satyakommula/trino-base:${TRINO_SNAPSHOT_VERSION}-corretto trino-base --push
	docker buildx build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION}-corretto --platform linux/arm64 -t satyakommula/trino-coordinator:${TRINO_SNAPSHOT_VERSION}-corretto trino-coordinator --push
	docker buildx build --build-arg VERSION=${TRINO_SNAPSHOT_VERSION}-corretto --platform linux/arm64 -t satyakommula/trino-worker:${TRINO_SNAPSHOT_VERSION}-corretto trino-worker --push
# push: build push_arm64v7
push: build
	docker push satyakommula/trino-base:${TRINO_VERSION}
	docker push satyakommula/trino-coordinator:${TRINO_VERSION}
	docker push satyakommula/trino-worker:${TRINO_VERSION}
# sh ./update-readme.sh

run: build
	TRINO_VERSION=${TRINO_VERSION} docker-compose up -d
	echo "Please check http://localhost:8080"

test: build
	./test-container.sh ${TRINO_VERSION}

down:
	TRINO_VERSION=${TRINO_VERSION} docker-compose down

release:
	git tag -a ${TRINO_VERSION} -m "Release ${TRINO_VERSION}"
	git push --tags
