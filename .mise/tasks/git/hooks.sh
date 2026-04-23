#!/usr/bin/env bash
#[MISE] description="配置共享 Git 钩子，激活 .git-hooks.conf."
#[MISE] dir="{{cwd}}"

set -euo pipefail

# NO.1  检查当前目录是否为 Git 仓库
if ! git rev-parse --git-dir &>/dev/null; then
  echo "❌ not a git repository." >&2
  exit 1
fi

# NO.2  配置共享钩子
if [[ -f .git-hooks.conf ]]; then
  git config --local include.path "../.git-hooks.conf"
  echo "✅ 钩子已激活 (.git-hooks.conf)"
else
  echo "⚠️  未检测到 .git-hooks.conf，跳过"
fi
