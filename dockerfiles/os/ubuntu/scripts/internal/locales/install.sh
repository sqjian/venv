#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y locales
locale-gen en_US.UTF-8

config_locales() {
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Locales 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Locales 配置开始 --------------------
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# -------------------- Locales 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Locales 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Locales 配置开始 --------------------
set -gx LC_ALL en_US.UTF-8
set -gx LANG en_US.UTF-8
# -------------------- Locales 配置结束 --------------------

EOF
	fi
}

config_locales
