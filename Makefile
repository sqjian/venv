all: build-extra-cuda12.9

build-core-cuda12.9:
	docker buildx build \
	--network host \
	--no-cache \
	--build-arg HTTP_PROXY=http://127.0.0.1:7890 \
	--build-arg HTTPS_PROXY=http://127.0.0.1:7890 \
	--build-arg BASE_IMAGE=artifacts.iflytek.com/docker-private/aiaas/nvidia/cuda:12.9.1-cudnn-devel-ubuntu22.04 \
	--progress=plain \
	-t artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9 \
	-f dockerfiles/os/ubuntu/22.04/core-cuda12.9.dockerfile dockerfiles/os/ubuntu

build-extra-cuda12.9:
	docker buildx build \
	--network host \
	--no-cache \
	--build-arg HTTP_PROXY=http://127.0.0.1:7890 \
	--build-arg HTTPS_PROXY=http://127.0.0.1:7890 \
	--build-arg BASE_IMAGE=artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9 \
	--progress=plain \
	-t artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9-extra \
	-f dockerfiles/os/ubuntu/22.04/extra-cuda12.9.dockerfile dockerfiles/os/ubuntu