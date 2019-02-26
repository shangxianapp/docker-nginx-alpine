build:
	docker build -t shangxian/nginx:alpine .

test:
	cd ./test && docker-compose up

.PHONY: build test