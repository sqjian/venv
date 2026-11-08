#!/usr/bin/env bash

set -euxo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_fnm() {
	# 设置非交互模式，避免 apt 安装时弹出交互式提示
	export DEBIAN_FRONTEND=noninteractive

	apt-get update -y
	apt-get install -y unzip curl

	# 安装器默认使用 XDG_DATA_HOME，由本仓库维护 shell 配置。
	curl -o- https://fnm.vercel.app/install | bash -s -- --skip-shell

	# 在当前 shell 中启用 fnm，供后续安装 Node.js 使用。
	export PATH="${XDG_DATA_HOME}/fnm:$PATH"
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
	# 配置 fnm shell 集成（支持 bash 和 fish）
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Fnm 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Fnm 配置开始 --------------------
FNM_PATH="${XDG_DATA_HOME}/fnm"
if [ -d "$FNM_PATH" ]; then
	export PATH="$FNM_PATH:$PATH"
	eval "$(fnm env --shell bash)"
fi
# -------------------- Fnm 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Fnm 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Fnm 配置开始 --------------------
set -l FNM_PATH "$XDG_DATA_HOME/fnm"
if test -d "$FNM_PATH"
    fish_add_path --path "$FNM_PATH"
    fnm env --shell fish | source
end
# -------------------- Fnm 配置结束 --------------------

EOF
	fi
}

function main() {
	install_fnm
	install_node
	verify_fnm
	config_fnm
}

main
