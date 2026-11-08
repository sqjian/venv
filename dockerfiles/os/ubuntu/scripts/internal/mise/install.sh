#!/usr/bin/env bash

set -exo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_mise() {
	export DEBIAN_FRONTEND=noninteractive

	curl https://mise.run | sh
}

config_mise() {
	local mise_config_dir="${XDG_CONFIG_HOME}/mise"
	mkdir -p "$mise_config_dir"
	cp config.toml "$mise_config_dir/config.toml"
	cp -r tasks "$mise_config_dir"
	chmod +x -R "$mise_config_dir/tasks"
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Mise 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Mise 配置开始 --------------------
if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate bash)"
fi
# -------------------- Mise 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Mise 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Mise 配置开始 --------------------
if command -q mise
    mise activate fish | source
end
# -------------------- Mise 配置结束 --------------------

EOF
	fi
}

function main() {
	install_mise
	config_mise
}

main
