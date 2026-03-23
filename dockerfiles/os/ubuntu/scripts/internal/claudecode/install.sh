#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://claude.ai/install.sh | bash

mkdir -p /etc/profile.d /etc/fish/conf.d
cp claudecode.sh /etc/profile.d/claudecode.sh
cp claudecode.fish /etc/fish/conf.d/claudecode.fish
