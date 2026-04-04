#!/usr/bin/env bash
#MISE description="Use Homebrew package manager for Linux."
#MISE dir="{{config_root}}/config"
#MISE depends=["brew:pre"]
#MISE depends_post = ["brew:post"]

brew update
brew upgrade -g

brew autoremove
brew cleanup --prune=all
