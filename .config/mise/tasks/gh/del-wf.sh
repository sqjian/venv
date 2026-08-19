#!/usr/bin/env bash
#[MISE] description="del all workflows."
#[MISE] dir="{{config_root}}"

export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890

gh run list --limit 1000 --json databaseId -q '.[].databaseId' | xargs -I{} gh run delete {} 2>&1 | nl
