#!/usr/bin/env bash
#MISE description="cancel all workflows."
#MISE dir="{{config_root}}"

export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890

gh run ls -s in_progress --json databaseId -q .[].databaseId | xargs -n1 gh run cancel
