#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y locales
locale-gen zh_CN.UTF-8

cp lang.sh /etc/profile.d/lang.sh
