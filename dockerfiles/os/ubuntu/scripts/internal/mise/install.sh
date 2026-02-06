#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl https://mise.run | sh

if [ ! -d /root/.config/mise ]; then
    mkdir -p /root/.config/mise
fi
cp config.toml /root/.config/mise/config.toml
cp -r tasks /root/.config/mise
chmod +x -R /root/.config/mise/tasks
cp mise.sh /etc/profile.d/mise.sh
