#!/usr/bin/env bash
#[MISE] description="backup data."

set -euo pipefail

readonly SRC="/sqjian"
readonly DST="/sqjian1"
readonly EXCLUDES=(--exclude='.venv' --exclude='models')

du -sh "${EXCLUDES[@]}" "$SRC"
rsync -av --delete --progress "${EXCLUDES[@]}" "$SRC/" "$DST/"
