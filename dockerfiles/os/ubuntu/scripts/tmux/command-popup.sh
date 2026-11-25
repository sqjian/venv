#!/usr/bin/env bash

set -o pipefail

popup_client=${TMUX_COMMAND_POPUP_CLIENT-}

# 正常结束前让 tmux 在脚本退出时关闭原始 client 的弹窗。
# Esc 和 Ctrl+C 则由未启用 -E 的 popup 原生处理。
arm_auto_close() {
	if [[ -n $popup_client ]]; then
		tmux display-popup -c "$popup_client" -E \
			-T ' tmux 命令 ' /bin/true >/dev/null 2>&1 || true
	fi
}

command=
if ! IFS= read -e -r -p 'tmux> ' command; then
	arm_auto_close
	exit 0
fi

# 空命令直接关闭弹窗。
if [[ -z ${command//[[:space:]]/} ]]; then
	arm_auto_close
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

arm_auto_close
exit "$status"
