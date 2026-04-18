# shellcheck disable=SC2148
# shellcheck disable=SC2155

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
	export PATH="$FNM_PATH:$PATH"
	eval "$(fnm env --corepack-enabled --shell bash)"
fi

# pnpm
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
