#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://claude.ai/install.sh | bash

[ -d /etc/profile.d ] && cp claudecode.sh /etc/profile.d/claudecode.sh
[ -d /etc/fish/conf.d ] && cp claudecode.fish /etc/fish/conf.d/claudecode.fish