#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

# Download and install fnm
curl -o- https://fnm.vercel.app/install | bash

# Configure fnm for the current shell session
export PATH="/root/.local/share/fnm:$PATH"
eval "$(fnm env)"

# Download and install Node.js
fnm install 24
node -v

# Download and install pnpm
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export PNPM_HOME="/root/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
export SHELL="/bin/bash"
corepack enable pnpm
pnpm setup
pnpm -v

# Configure pnpm: allow build scripts and enable parallel builds
pnpm config set dangerouslyAllowAllBuilds true --global
pnpm config set childConcurrency 10 --global

# Install promptfoo globally using pnpm
pnpm install -g promptfoo

# Verify promptfoo installation
promptfoo --version

# Set up promptfoo shell integration
cp promptfoo.sh /etc/profile.d/promptfoo.sh