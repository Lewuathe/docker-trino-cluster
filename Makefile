all:
	git submodule init
	git submodule update
	cd presto && ./mvnw clean install -DskipTests  && cd -
	cp presto/presto-server/target/presto-server-*.tar.gz presto-base/ && cp presto/presto-cli/target/presto-*-executable.jar presto-base/presto
	docker build -t lewuathe/presto-base:latest presto-base
	docker build -t lewuathe/presto-coordinator:latest presto-coordinator
	docker build -t lewuathe/presto-worker:latest presto-worker
	docker-compose build

.PHONY: test clean

run:
	docker-compose up -d
	@echo "Please check http://localhost:8080"

down:
	docker-compose down

cli:
	docker exec -it coordinator /usr/bin/presto

clean:
	rm -rf presto-base/presto*
