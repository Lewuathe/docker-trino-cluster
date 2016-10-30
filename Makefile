all:
	docker build -t lewuathe/presto-base:latest presto-base
	docker-compose build

.PHONY: test clean

run:
	docker-compose up -d
	echo "Please check http://localhost:8080"

down:
	docker-compose down
