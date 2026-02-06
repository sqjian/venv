#!/usr/bin/env bash
set -eo pipefail

export DEBIAN_FRONTEND=noninteractive

# shellcheck disable=SC2155

function install_pkg() {
    local temp_dir
    temp_dir=$(mktemp -d /tmp/pkg.step1.XXXXXX)
    pushd "${temp_dir}" || exit 1
    echo "install testcase pkg"
    popd || exit 1
    rm -rf "${temp_dir}"
}

install_pkg
