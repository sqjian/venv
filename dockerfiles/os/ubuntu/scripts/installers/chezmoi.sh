#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

# Install only the binary; do not initialize or apply dotfiles.
curl -fsSL https://get.chezmoi.io | sh -s -- -b /usr/local/bin
