build:
	docker build -t ghcr.io/shangxianapp/nginx:latest-alpine .

test:
	cd ./test && docker-compose up

.PHONY: build test