#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

# 只安装 pnpm，shell 配置由 chezmoi 管理。
curl -fsSL https://get.pnpm.io/install.sh | env PNPM_NO_MODIFY_PATH=1 sh
