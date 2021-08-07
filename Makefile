build:
	docker build -t shangxian/nginx:2.0-alpine3.9 .

test:
	cd ./test && docker-compose up

.PHONY: build test