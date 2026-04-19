# shellcheck disable=SC2148
# shellcheck disable=SC2155

# bun
export BUN_INSTALL="$HOME/.bun"
if [ -d "$BUN_INSTALL" ]; then
	export PATH="$BUN_INSTALL/bin:$PATH"
fi
