#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Skip if CUDA is not available
if [[ -z "${CUDA_VERSION:-}" ]] && ! command -v nvidia-smi &>/dev/null; then
	echo "CUDA not detected, skipping CUDA-specific packages"
	exit 0
fi

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends \
	libibverbs-dev ibverbs-utils
