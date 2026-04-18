#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y unzip curl

# Download and install fnm
curl -o- https://fnm.vercel.app/install | bash

# Configure fnm for the current shell session
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env)"

# Download and install Node.js
fnm install --lts
node -v

# Download and install pnpm
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
export SHELL="/bin/bash"
corepack enable pnpm
pnpm setup
pnpm -v

# Configure pnpm: allow build scripts and enable parallel builds
pnpm config set dangerouslyAllowAllBuilds true --global
pnpm config set childConcurrency 10 --global

# Verify fnm installation
fnm --version

# Set up fnm shell integration
mkdir -p /etc/profile.d /etc/fish/conf.d
cp fnm.sh /etc/profile.d/fnm.sh
cp fnm.fish /etc/fish/conf.d/fnm.fish
