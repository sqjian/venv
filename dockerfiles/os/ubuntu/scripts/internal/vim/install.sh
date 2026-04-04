#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y vim

curl -fLo "$HOME/.vimrc" https://raw.githubusercontent.com/amix/vimrc/refs/heads/master/vimrcs/basic.vim
cat vimrc >>"$HOME/.vimrc"
mkdir -p /etc/profile.d /etc/fish/conf.d
cp vim.sh /etc/profile.d/vim.sh
cp vim.fish /etc/fish/conf.d/vim.fish
