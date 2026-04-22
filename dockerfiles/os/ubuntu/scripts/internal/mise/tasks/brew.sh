#!/usr/bin/env bash
#[MISE] description="Use Homebrew package manager for Linux."

brew update
brew upgrade -g

brew autoremove
brew cleanup --prune=all
