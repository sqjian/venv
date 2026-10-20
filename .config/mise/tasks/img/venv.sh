#!/usr/bin/env bash
#[MISE] dir="{{config_root}}"

docker run -it --rm \
	--network host \
	-e HTTP_PROXY=http://127.0.0.1:7890 \
	-e HTTPS_PROXY=http://127.0.0.1:7890 \
	-e NO_PROXY=localhost,127.0.0.1,iflytek.com \
	-v ${PWD}/dockerfiles/os/ubuntu/scripts:/scripts \
	artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu24.04-cuda13.0 bash -l
