#!/usr/bin/env bash
set -eo pipefail

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
        local temp_dir
        temp_dir=$(mktemp -d /tmp/pkg.step1.XXXXXX)
        pushd "${temp_dir}" || exit 1
        echo "pkg.step1."
        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_step2() {
        local temp_dir
        temp_dir=$(mktemp -d /tmp/pkg.step2.XXXXXX)
        pushd "${temp_dir}" || exit 1
        echo "pkg.stdp2."
        popd || exit 1
        rm -rf "${temp_dir}"
    }

    _install_step1
    _install_step2
}

function install_apt_fast() {
    echo "Installing apt-fast..."
    apt-get update
    apt-get install -y software-properties-common aria2

    add-apt-repository -y ppa:apt-fast/stable
    apt-get update
    apt-get install -y apt-fast

    echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
    echo debconf apt-fast/dlflag boolean true | debconf-set-selections
    echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
}

install_apt_fast
