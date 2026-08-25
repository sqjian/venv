#!/usr/bin/env bash

set -o pipefail

command=
if ! IFS= read -e -r -p 'tmux> ' command; then
	exit 0
fi

# 空命令直接关闭弹窗。
if [[ -z ${command//[[:space:]]/} ]]; then
	exit 0
fi

output=$(printf '%s\n' "$command" | tmux source-file - 2>&1)
status=$?

# 成功且无输出时立即关闭；否则留下结果便于查看。
if ((status != 0)) || [[ -n $output ]]; then
	printf '\n%s\n' "$output"
	printf '\n按 Enter 关闭…'
	IFS= read -r
fi

exit "$status"
