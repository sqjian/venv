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
    apt-get install -y curl unzip
}

function install_code_assistant() {
    _setup_fnm_env() {
        export FNM_PATH="/root/.local/share/fnm"
        export PATH="$FNM_PATH:$PATH"
        # Explicitly specify bash shell for fnm env in containerized environments
        eval "$(fnm env --shell bash)"
    }

    _install_node() {
        check_command curl
        check_command unzip
        curl -o- https://fnm.vercel.app/install | bash

        # Source the fnm installation
        source /root/.bashrc

        _setup_fnm_env

        # Verify fnm is available
        if ! command -v fnm >/dev/null 2>&1; then
            echo "Error: fnm installation failed"
            exit 1
        fi

        fnm install 22
        fnm use 22
        
        # Verify node installation
        if ! command -v node >/dev/null 2>&1; then
            echo "Error: node installation failed"
            exit 1
        fi
        
        node -v
        npm -v
    }

    _install_code_assistant() {
        _setup_fnm_env

        npm install -g @anthropic-ai/claude-code
        npm install -g @musistudio/claude-code-router
        npm install -g @dashscope-js/claude-code-config
    }

    _install_node
    _install_code_assistant
}

deps
install_code_assistant
