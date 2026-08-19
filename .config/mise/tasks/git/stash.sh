#!/usr/bin/env bash
#[MISE] description="通过远程 stash/* 分支在多台机器间同步 git stash."
#[MISE] dir="{{cwd}}"

set -e

REMOTE="${1:-origin}"

# NO.1  检查当前目录是否为 Git 仓库
git rev-parse --git-dir &>/dev/null || {
	echo "Not a git repo."
	exit 1
}

# NO.2  推送：导出本地 stash 为分支并推送
echo "Pushing local stashes..."
git stash list --format='%gd' | while read -r s; do
	git stash export "$s" --to-ref "refs/heads/stash/${s//[^0-9]/}" 2>/dev/null || true
done
git push "$REMOTE" 'refs/heads/stash/*' --force 2>/dev/null || true

# NO.3  拉取：获取远程 stash 分支并导入
echo "Pulling remote stashes..."
git fetch "$REMOTE" '+refs/heads/stash/*:refs/heads/stash/*' 2>/dev/null || true
git for-each-ref --format='%(refname)' refs/heads/stash/ | while read -r ref; do
	git stash import "$ref" 2>/dev/null || true
done

echo "Done."
git stash list
