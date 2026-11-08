#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_brew() {
	export DEBIAN_FRONTEND=noninteractive
	export NONINTERACTIVE=1
	export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
	export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
	export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）
	export HOMEBREW_FORCE_BREWED_CURL=1
	export HOMEBREW_FORCE_BREWED_GIT=1

	touch /.dockerenv
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

config_brew() {
	mkdir -p "$HOME/.config/fish"

	if ! grep -qxF '# -------------------- Brew 配置开始 --------------------' "$HOME/.bashrc" 2>/dev/null; then
		cat >>"$HOME/.bashrc" <<'EOF'

# -------------------- Brew 配置开始 --------------------
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
	if [ -x "$brew_path" ]; then
		eval "$("$brew_path" shellenv)"
		export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
		export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
		export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）
		export HOMEBREW_FORCE_BREWED_CURL=1
		export HOMEBREW_FORCE_BREWED_GIT=1
		break
	fi
done
# -------------------- Brew 配置结束 --------------------

EOF
	fi

	if ! grep -qxF '# -------------------- Brew 配置开始 --------------------' "$HOME/.config/fish/config.fish" 2>/dev/null; then
		cat >>"$HOME/.config/fish/config.fish" <<'EOF'

# -------------------- Brew 配置开始 --------------------
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew
    if test -x $brew_path
        eval ($brew_path shellenv)
        set -gx HOMEBREW_FORCE_VENDOR_RUBY 1
        set -gx HOMEBREW_NO_ANALYTICS 1
        set -gx HOMEBREW_NO_AUTO_UPDATE 1
        set -gx HOMEBREW_FORCE_BREWED_CURL 1
        set -gx HOMEBREW_FORCE_BREWED_GIT 1
        break
    end
end
# -------------------- Brew 配置结束 --------------------

EOF
	fi
}

function main() {
	install_brew
	config_brew
}

main
