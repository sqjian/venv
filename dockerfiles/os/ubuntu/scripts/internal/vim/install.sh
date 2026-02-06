#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y vim

curl -fLo /root/.vimrc https://raw.githubusercontent.com/amix/vimrc/refs/heads/master/vimrcs/basic.vim
cat vimrc >>/root/.vimrc
cp vim.sh /etc/profile.d/vim.sh
