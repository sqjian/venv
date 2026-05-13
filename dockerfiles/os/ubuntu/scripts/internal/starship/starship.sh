# shellcheck disable=SC2148
# shellcheck disable=SC2155

if [[ "$TERM" != "dumb" ]]; then
	eval "$(starship init bash)"
fi
