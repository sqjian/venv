#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

function install_pkg() {
    _install_step1() {
        local Directory=$(mktemp -d /tmp/pkg.step1.XXXXXX)
        pushd "${Directory}"
        echo "pkg.step1."
        popd
        rm -rf "${Directory}"
    }

    _install_step2() {
        local Directory=$(mktemp -d /tmp/pkg.step2.XXXXXX)
        pushd "${Directory}"
        echo "pkg.stdp2."
        popd
        rm -rf "${Directory}"
    }

    _install_step1
    _install_step2
}
