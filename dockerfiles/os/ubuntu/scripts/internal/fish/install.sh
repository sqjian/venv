#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y \
	software-properties-common \
	apt-transport-https \
	ca-certificates \
	gnupg-agent

add-apt-repository -y ppa:fish-shell/release-4
apt-get update -y
apt-get install -y fish
