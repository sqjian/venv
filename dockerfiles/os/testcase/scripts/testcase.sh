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
    _install_config() {
        tee /root/.duckdbrc <<EOF
-- 会话和性能配置
SET enable_progress_bar = true;
SET preserve_insertion_order = false;

-- 数据处理和排序配置
SET default_null_order = 'nulls_last';
SET enable_object_cache = true;
SET checkpoint_threshold = '1GB';

-- 用户体验优化
.nullvalue 'NULL'

-- 输出显示配置
.changes on
.columns
.mode duckbox
.timer on
.header on
EOF
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
    _install_config
    _update_alternatives
}

deps
install_duckdb
