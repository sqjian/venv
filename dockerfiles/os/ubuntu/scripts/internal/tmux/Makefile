# Makefile for testing tmux.conf

CONF := $(CURDIR)/tmux.conf
SESSION := test-tmux

.PHONY: run

run:
	@tmux kill-session -t $(SESSION) 2>/dev/null || true
	@tmux -f $(CONF) new-session -s $(SESSION)
