#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y locales
locale-gen en_US.UTF-8

mkdir -p /etc/profile.d /etc/fish/conf.d
cp lang.sh /etc/profile.d/lang.sh
cp lang.fish /etc/fish/conf.d/lang.fish
