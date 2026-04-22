#!/usr/bin/env bash
#[MISE] description="install Homebrew package manager for Linux."
#[MISE] dir="{{config_root}}/dockerfiles/os/ubuntu/scripts/internal/brew"
#[MISE] depends=["brew:pre"]
#[MISE] depends_post = ["brew:post"]

./install.sh
