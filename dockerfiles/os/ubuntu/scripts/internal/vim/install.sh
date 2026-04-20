#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y vim

mkdir -p "$HOME/.vim"
cp vimrc "$HOME/.vim/vimrc"
