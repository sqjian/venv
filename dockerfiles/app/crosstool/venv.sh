#!/usr/bin/env bash

set -eux

docker run --rm -it \
	-v $(pwd)/generated/toolchain:/home/builder/build/toolchain \
	-v $(pwd)/config/x86_64-gcc-8.5.0-glibc-2.28.config:/home/builder/build/.config \
	-w /home/builder/build \
	sqjian/venv:crosstool bash