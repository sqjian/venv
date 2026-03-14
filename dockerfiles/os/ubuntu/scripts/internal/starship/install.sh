#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends jq curl ca-certificates

curl -sS https://starship.rs/install.sh | sh -s -- -y

mkdir -p /etc/profile.d /etc/fish/conf.d /root/.config
cp starship.sh /etc/profile.d/starship.sh
cp starship.fish /etc/fish/conf.d/starship.fish
cp starship.toml /root/.config/starship.toml