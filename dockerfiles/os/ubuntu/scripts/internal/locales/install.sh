#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y locales
locale-gen zh_CN.UTF-8

[ -d /etc/profile.d ] && cp lang.sh /etc/profile.d/lang.sh
[ -d /etc/fish/conf.d ] && cp lang.fish /etc/fish/conf.d/lang.fish
