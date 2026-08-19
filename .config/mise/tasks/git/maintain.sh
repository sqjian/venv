#!/usr/bin/env bash
#[MISE] description="执行 Git 仓库维护：几何重整、对象清理、索引优化."
#[MISE] dir="{{cwd}}"

set -euo pipefail

readonly REQUIRED_GIT_VERSION="2.54"

version_ge() {
	printf '%s\n%s' "$2" "$1" | sort -C -V
}

# NO.1  版本检查
git_version=$(git --version | awk '{print $3}')
if ! version_ge "$git_version" "$REQUIRED_GIT_VERSION"; then
	echo "❌ git $git_version < $REQUIRED_GIT_VERSION，请升级" >&2
	exit 1
fi

# NO.2  检查当前目录是否为 Git 仓库
if ! git rev-parse --git-dir &>/dev/null; then
	echo "❌ not a git repository." >&2
	exit 1
fi

echo "🚀 开始仓库维护 (git $git_version)"

# NO.3  几何重整 - 优化 pack 文件结构
echo "[1/5] Geometric repack..."
git repack -d -l --geometric=2

# NO.4  清理冗余对象
echo "[2/5] Pruning old objects..."
git prune --expire=2.weeks.ago

# NO.5  垃圾回收
echo "[3/5] Garbage collection..."
git gc --auto

# NO.6  写入提交图 - 加速提交历史遍历和路径查询
echo "[4/5] Writing commit-graph..."
git commit-graph write --reachable --changed-paths

# NO.7  写入多包索引 - 优化多个 pack 文件的对象查找
echo "[5/5] Writing multi-pack-index..."
git multi-pack-index write --incremental

# NO.8  显示仓库状态
echo ""
git count-objects -vH

echo "✅ 仓库维护完成"
