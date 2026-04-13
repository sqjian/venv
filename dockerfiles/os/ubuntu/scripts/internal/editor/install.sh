#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p /etc/profile.d /etc/fish/conf.d
cp editor.sh /etc/profile.d/editor.sh
cp editor.fish /etc/fish/conf.d/editor.fish
