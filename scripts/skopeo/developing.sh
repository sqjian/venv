#!/bin/bash

export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890

skopeo copy \
    "docker://datajuicer/data-juicer:v1.3.2" \
    "docker-archive:data-juicer.tar"
