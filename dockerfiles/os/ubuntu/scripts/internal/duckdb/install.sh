#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl https://install.duckdb.org | sh

mkdir -p /etc/profile.d /etc/fish/conf.d
cp duckdb.sh /etc/profile.d/duckdb.sh
cp duckdb.fish /etc/fish/conf.d/duckdb.fish
cp duckdbrc /root/.duckdbrc
