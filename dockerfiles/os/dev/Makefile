IMG:=dev

all: venv

build:
	docker buildx build -f dev.dockerfile -t sqjian/venv:dev .

venv:
	docker rm -f ${IMG} || true
	docker run -it \
				--name ${IMG} \
				--net=host \
				-w /scripts \
				--privileged \
				-v ${PWD}/scripts:/scripts \
				ubuntu:22.04 bash