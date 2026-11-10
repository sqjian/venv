#!/usr/bin/env bash
#[MISE] description="Build the CUDA Ubuntu image."
#[MISE] dir="{{config_root}}"

set -euo pipefail

docker buildx build \
	--network host \
	--no-cache \
	--build-arg HTTP_PROXY=http://127.0.0.1:7890 \
	--build-arg HTTPS_PROXY=http://127.0.0.1:7890 \
	--build-arg NO_PROXY=localhost,127.0.0.1,iflytek.com \
	--progress=plain \
	-t artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu24.04-cuda13.0-build \
	-f dockerfiles/os/ubuntu/ubuntu24.04-cuda13.0.dockerfile dockerfiles/os/ubuntu
