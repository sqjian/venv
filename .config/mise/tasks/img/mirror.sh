#!/usr/bin/env bash
#[MISE] description="mirror images."
#[MISE] dir="{{config_root}}"

set -euo pipefail

mise r img:skopeo "sqjian/venv:ubuntu24.04-cuda13.0" "artifacts.iflytek.com/docker-private/aiaas/venv:ubuntu24.04-cuda13.0"
