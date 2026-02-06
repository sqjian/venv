#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

curl https://install.duckdb.org | sh

cp duckdb.sh /etc/profile.d/duckdb.sh
cp duckdbrc /root/.duckdbrc