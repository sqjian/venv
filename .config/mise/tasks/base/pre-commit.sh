#!/usr/bin/env bash
#[MISE] description="pre-commit setup"
#[MISE] alias="pre-commit"
#[MISE] dir="{{config_root}}"

set -euo pipefail

# 1. 检查并安装 pre-commit
if ! command -v pre-commit &>/dev/null; then
	echo "pre-commit not found, installing via brew..."
	brew install pre-commit
fi

# 2. 解除 core.hooksPath，避免 Git 忽略 .git/hooks 下的 hook
if [[ -n "$(git config --get core.hooksPath)" ]]; then
	echo "Unsetting core.hooksPath..."
	git config --unset-all core.hooksPath
fi

# 3. 创建默认配置（如果不存在）
readonly CONFIG_FILE=".pre-commit-config.yaml"
if [[ ! -f "$CONFIG_FILE" ]]; then
	echo "Creating default $CONFIG_FILE..."
	cat >"$CONFIG_FILE" <<-'EOF'
		exclude: ^(vendor|\.venv)/

		default_install_hook_types: [pre-commit, commit-msg]

		repos:
		  - repo: https://github.com/pre-commit/pre-commit-hooks
		    rev: v6.0.0
		    hooks:
		      - id: check-yaml
		        args: [--allow-multiple-documents]
		      - id: check-added-large-files
		      - id: check-merge-conflict

		  - repo: local
		    hooks:
		      - id: signoff
		        name: add Signed-off-by trailer
		        entry: .githooks/commit-msg
		        language: script
		        stages: [commit-msg]
		        always_run: true
	EOF
	echo "Updating hooks to latest versions..."
	pre-commit autoupdate
fi

# 4. 安装 hook（类型由 default_install_hook_types 声明）
echo "Installing pre-commit hooks..."
pre-commit install --overwrite

# 5. 预下载依赖
echo "Pre-downloading hook dependencies..."
pre-commit install-hooks

echo "pre-commit setup complete."
