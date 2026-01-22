all: pull build push

build:
	docker buildx build \
	--network host \
	--no-cache \
	--build-arg HTTP_PROXY=http://127.0.0.1:7890 \
	--build-arg HTTPS_PROXY=http://127.0.0.1:7890 \
	--build-arg NO_PROXY=localhost,127.0.0.1,iflytek.com \
	--build-arg BASE_IMAGE=artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9 \
	--progress=plain \
	-t artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9-extra \
	-f dockerfiles/os/ubuntu/22.04/extra-cuda12.9.dockerfile dockerfiles/os/ubuntu

pull:
	docker pull artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9

push:
	docker push artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9-extra