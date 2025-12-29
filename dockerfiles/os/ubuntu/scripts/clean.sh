#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "autoremoving packages and cleaning apt data"
apt-fast -y autoremove
apt-fast -y clean

echo "remove /var/lib/apt/lists/"
rm -rf /var/lib/apt/lists/*

echo "remove /tmp/"
rm -rf /tmp/*