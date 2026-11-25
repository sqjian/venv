#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_fnm() {
	# 设置非交互模式，避免 apt 安装时弹出交互式提示
	export DEBIAN_FRONTEND=noninteractive

	apt-get update -y
	apt-get install -y unzip curl

	# 安装器默认使用 XDG_DATA_HOME，shell 配置由 config_fnm 写入。
	curl -o- https://fnm.vercel.app/install | bash -s -- --skip-shell

	# 在当前 shell 中启用 fnm，供后续安装 Node.js 使用。
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/fnm:$PATH"
	eval "$(fnm env --shell bash)"
}

install_node() {
	# 下载并安装 Node.js LTS 版本
	fnm install --lts
	node -v
}

verify_fnm() {
	# 验证 fnm 安装
	fnm --version
}

config_fnm() {
	local bashrc="$HOME/.bashrc"
	local fish_config="$HOME/.config/fish/config.fish"

	mkdir -p "$(dirname "$fish_config")"
	touch "$bashrc" "$fish_config"

	if ! grep -Fxq "# Fnm" "$bashrc"; then
		cat >>"$bashrc" <<'BASHRC'

# Fnm
FNM_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"
if [ -x "$FNM_PATH/fnm" ]; then
	case ":$PATH:" in
	*:"$FNM_PATH":*) ;;
	*) export PATH="$FNM_PATH:$PATH" ;;
	esac
	eval "$(fnm env --shell bash)"
fi
BASHRC
	fi

	if ! grep -Fxq "# Fnm" "$fish_config"; then
		cat >>"$fish_config" <<'FISH'

# Fnm
set -l FNM_PATH "$HOME/.local/share/fnm"
if test -n "$XDG_DATA_HOME"
    set FNM_PATH "$XDG_DATA_HOME/fnm"
end
if test -x "$FNM_PATH/fnm"
    fish_add_path --path "$FNM_PATH"
    fnm env --shell fish | source
end
FISH
	fi
}

function main() {
	install_fnm
	install_node
	verify_fnm
	config_fnm
}

main
