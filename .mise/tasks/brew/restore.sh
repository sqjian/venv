#!/usr/bin/env bash
#[MISE] description="restore packages installed by Homebrew package manager for Linux."
#[MISE] dir="{{config_root}}/config"
#[MISE] depends=["brew:pre"]
#[MISE] depends_post = ["brew:post"]

brew bundle install
