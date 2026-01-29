IMG:=testcase

all: venv

build:
	docker buildx build \
				--progress plain \
				-f testcase.dockerfile \
				-t sqjian/venv:testcase .

venv:
	docker rm -f ${IMG} || true
	docker run -it \
				--name ${IMG} \
				--net=host \
				-w /scripts \
				--privileged \
				-v ${HOST_PROJECT_PATH}/dockerfiles/os/testcase/scripts:/scripts \
				artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu22.04-cuda12.9-extra bash