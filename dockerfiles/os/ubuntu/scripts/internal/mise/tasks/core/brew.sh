#!/usr/bin/env bash
#[MISE] description="Use Homebrew package manager for Linux."
#[MISE] alias="brew"

brew update
brew upgrade -g

brew autoremove
brew cleanup --prune=all
