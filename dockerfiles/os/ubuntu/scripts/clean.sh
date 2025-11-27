#!/usr/bin/env bash

set -exo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "autoremoving packages and cleaning apt data"
apt-get -y autoremove
apt-get -y clean

echo "remove /var/lib/apt/lists/"
rm -rf /var/lib/apt/lists/*

echo "remove /tmp/"
rm -rf /tmp/*

echo "remove ~/.cache/"
rm -rf ~/.cache/*

echo "disk usage after cleanup:"
df -h