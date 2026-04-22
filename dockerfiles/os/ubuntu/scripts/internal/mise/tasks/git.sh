#!/usr/bin/env bash
#[MISE] description="仓库高效管理：几何重整、配置共享、历史清理."

set -euo pipefail

readonly REQUIRED_GIT_VERSION="2.54"

log() { echo "[$1] $2"; }
ok() { echo "✅ $1"; }
fail() {
	echo "❌ $1" >&2
	exit 1
}

version_ge() {
	printf '%s\n%s' "$2" "$1" | sort -C -V
}

git_version=$(git --version | awk '{print $3}')
version_ge "$git_version" "$REQUIRED_GIT_VERSION" ||
	fail "git $git_version < $REQUIRED_GIT_VERSION，请升级"

echo "🚀 开始仓库管理 (git $git_version)"

log 1 "几何重整"
git repack -d -l --geometric=2
ok "重整完成"

log 2 "清理冗余对象"
git prune --expire=2.weeks.ago
ok "清理完成"

log 3 "配置共享钩子"
if [[ -f .git-hooks.conf ]]; then
	git config --local include.path "../.git-hooks.conf"
	ok "钩子已激活"
else
	echo "⚠️  未检测到 .git-hooks.conf，跳过"
fi

log 4 "仓库状态"
git count-objects -vH

ok "仓库优化完成"
