all: build

build:
	docker buildx build \
	--network host \
	--build-arg HTTP_PROXY=http://127.0.0.1:7890 \
	--build-arg HTTPS_PROXY=http://127.0.0.1:7890 \
	--progress=plain \
	-t sqjian/venv:ubuntu22.04-cuda12.8-amd64 \
	-f dockerfiles/os/ubuntu/22.04/ubuntu22.04-cuda12.8.dockerfile dockerfiles/os/ubuntu