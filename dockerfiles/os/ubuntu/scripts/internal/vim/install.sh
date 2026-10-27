#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y vim

VIM_CONFIG_DIR="${XDG_CONFIG_HOME}/vim"
mkdir -p "$VIM_CONFIG_DIR"
cp vimrc "$VIM_CONFIG_DIR/vimrc"

# Ubuntu 24.04 的 Vim 尚不支持 XDG vimrc，保留已有用户配置。
if [[ ! -e "$HOME/.vimrc" && ! -L "$HOME/.vimrc" ]]; then
	ln -s "$VIM_CONFIG_DIR/vimrc" "$HOME/.vimrc"
fi

mkdir -p /etc/profile.d /etc/fish/conf.d
echo 'export EDITOR=vim' >/etc/profile.d/editor.sh
echo 'set -gx EDITOR vim' >/etc/fish/conf.d/editor.fish
