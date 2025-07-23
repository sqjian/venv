#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# shellcheck disable=SC2155

function check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 not found"
        exit 1
    else
        echo "$1 found"
    fi
}

function install_pkg() {
    _install_step1() {
        local temp_dir=$(mktemp -d /tmp/pkg.step1.XXXXXX)
        pushd "${temp_dir}" || exit 1
        echo "pkg.step1."
        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_step2() {
        local temp_dir=$(mktemp -d /tmp/pkg.step2.XXXXXX)
        pushd "${temp_dir}" || exit 1
        echo "pkg.stdp2."
        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_step1
    _install_step2
}

function deps() {
    apt-get update -y
    apt-get install -y curl
}

function install_duckdb() {
    _install_duckdb() {
        check_command curl
        curl https://install.duckdb.org | sh
    }

    _update_alternatives() {
        update-alternatives --remove-all duckdb || true
        update-alternatives --install /usr/local/bin/duckdb duckdb "/root/.duckdb/cli/latest/duckdb" 1 || (echo "set duckdb alternatives failed" && exit 1)
        update-alternatives --auto duckdb
        update-alternatives --display duckdb
        duckdb --version
        which duckdb
    }

    _install_duckdb
    _update_alternatives
}

deps
install_duckdb
