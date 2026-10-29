#!/usr/bin/env bash
#[MISE] description="pre-commit setup"
#[MISE] alias="pre-commit"
#[MISE] dir="{{config_root}}"

set -euo pipefail

readonly CONFIG_FILE=".pre-commit-config.yaml"

# 1. 检查并安装 pre-commit
if ! command -v pre-commit &>/dev/null; then
	echo "pre-commit not found, installing via brew..."
	brew install pre-commit
	command -v pre-commit &>/dev/null || {
		echo "pre-commit is still not on PATH; add Homebrew's bin directory to PATH and rerun." >&2
		exit 1
	}
fi

# 2. 解除本仓库的 core.hooksPath，避免 Git 忽略 .git/hooks 下的 hook
if git config --local --get core.hooksPath &>/dev/null; then
	echo "Unsetting local core.hooksPath..."
	git config --local --unset-all core.hooksPath
fi
if git config --get core.hooksPath &>/dev/null; then
	echo "error: core.hooksPath is set outside this repository, so pre-commit will not install hooks:" >&2
	git config --show-origin --get core.hooksPath >&2
	echo "Unset it (for example 'git config --global --unset-all core.hooksPath') and rerun." >&2
	exit 1
fi

# 3. 创建默认配置（如果不存在）
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
	if ! pre-commit autoupdate; then
		echo "autoupdate failed; removing generated $CONFIG_FILE so the task can be retried." >&2
		rm -f "$CONFIG_FILE"
		exit 1
	fi
fi

# 4. 安装 hook（类型由 default_install_hook_types 声明）
echo "Installing pre-commit hooks..."
pre-commit install --overwrite

# 5. 预下载依赖
echo "Pre-downloading hook dependencies..."
pre-commit install-hooks

echo "pre-commit setup complete."
