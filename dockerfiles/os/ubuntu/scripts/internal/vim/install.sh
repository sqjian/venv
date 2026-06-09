#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y vim

mkdir -p "$HOME/.vim"
cp vimrc "$HOME/.vim/vimrc"

mkdir -p /etc/profile.d /etc/fish/conf.d
echo 'export EDITOR=vim' >/etc/profile.d/editor.sh
echo 'set -gx EDITOR vim' >/etc/fish/conf.d/editor.fish
