#!/usr/bin/env bash
#[MISE] description="将 Git 引用存储迁移到 reftable 格式，提升大型仓库的引用操作性能."
#[MISE] dir="{{cwd}}"

set -e

# NO.1  检查当前目录是否为 Git 仓库
if ! git rev-parse --git-dir &>/dev/null; then
	echo "Error: not a git repository."
	exit 1
fi

# NO.2  检查是否已使用 reftable 格式，避免重复迁移
if [ "$(git config --get extensions.refStorage)" = "reftable" ]; then
	echo "Already using reftable format, skipping migration."
	exit 0
fi

# NO.3  执行迁移：从传统松散文件/packed-refs 格式转换为 reftable
echo "Migrating to reftable format..."
git refs migrate --ref-format=reftable --reflog

# NO.4  验证迁移后的引用完整性
echo "Verifying refs..."
git refs verify --strict --verbose

# NO.5  优化 reftable 文件，合并小表以提升性能
echo "Optimizing reftable..."
git refs optimize --auto

echo "Done."
