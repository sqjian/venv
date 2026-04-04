# shellcheck disable=SC2148
# shellcheck disable=SC2155

# mise
if command -v mise >/dev/null 2>&1; then
	eval "$(mise activate bash)"
fi
