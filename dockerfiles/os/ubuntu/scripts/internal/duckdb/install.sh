#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://install.duckdb.org | bash

mkdir -p /etc/profile.d /etc/fish/conf.d
cp duckdb.sh /etc/profile.d/duckdb.sh
cp duckdb.fish /etc/fish/conf.d/duckdb.fish
cp duckdbrc "$HOME/.duckdbrc"
