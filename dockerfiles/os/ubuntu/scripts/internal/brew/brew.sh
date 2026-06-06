# shellcheck disable=SC2148
# shellcheck disable=SC2155

# brew
for brew_path in /home/linuxbrew/.linuxbrew/bin/brew /opt/homebrew/bin/brew /usr/local/bin/brew; do
	if [ -x "$brew_path" ]; then
		eval "$("$brew_path" shellenv)"
		export HOMEBREW_FORCE_VENDOR_RUBY=1 # 强制使用自带 Portable Ruby
		export HOMEBREW_NO_ANALYTICS=1      # 禁用分析（提前设置）
		export HOMEBREW_NO_AUTO_UPDATE=1    # 禁用自动更新（加速安装）
		export HOMEBREW_FORCE_BREWED_CURL=1
		export HOMEBREW_FORCE_BREWED_GIT=1
		export HOMEBREW_NO_REQUIRE_TAP_TRUST=1
		break
	fi
done
