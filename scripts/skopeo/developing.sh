#!/bin/bash

export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export NO_PROXY=localhost,127.0.0.1,artifacts.iflytek.com

# unset HTTP_PROXY
# unset HTTPS_PROXY
# unset NO_PROXY

skopeo copy \
    "docker://datajuicer/data-juicer:v1.3.2" \
    "docker-archive:data-juicer.tar"
