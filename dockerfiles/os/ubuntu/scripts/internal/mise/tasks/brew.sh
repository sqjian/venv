#!/usr/bin/env bash
#MISE description="Use Homebrew package manager for Linux."

export HTTP_PROXY="http://127.0.0.1:7890"
export HTTPS_PROXY="http://127.0.0.1:7890"
export ALL_PROXY="socks5://127.0.0.1:7890"

brew update

brew uninstall --cask --force claude-code
brew cleanup claude-code
brew install --cask claude-code

brew upgrade -g