#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

export DEBIAN_FRONTEND=noninteractive

apt-get install -y --no-install-recommends jq curl ca-certificates

curl -sS https://starship.rs/install.sh | sh -s -- -y

config_starship() {
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Starship 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Starship 配置开始 --------------------
if [[ "$TERM" != "dumb" ]]; then
	eval "$(starship init bash)"
fi
# -------------------- Starship 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Starship 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Starship 配置开始 --------------------
# 过滤掉 dumb 终端
if test "$TERM" != "dumb"
    starship init fish | source
end
# -------------------- Starship 配置结束 --------------------

EOF
	fi
}

config_starship
cp starship.toml "$HOME/.config/starship.toml"
