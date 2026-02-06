#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl -LsSf https://astral.sh/uv/install.sh | sh
/root/.local/bin/uv tool update-shell