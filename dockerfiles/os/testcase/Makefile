IMG:=testcase

all: build

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
				-v ${PWD}/scripts:/scripts \
				ubuntu:24.04 bash