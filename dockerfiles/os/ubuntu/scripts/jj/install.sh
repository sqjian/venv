#!/usr/bin/env bash

set -eo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

install_jj() {
  export DEBIAN_FRONTEND=noninteractive

  apt-get install -y --no-install-recommends jq curl ca-certificates

  # 架构检测
  ARCH=$(dpkg --print-architecture)
  case ${ARCH} in
    amd64)
      ARCH_NAME="x86_64-unknown-linux-musl"
      ;;
    arm64)
      ARCH_NAME="aarch64-unknown-linux-musl"
      ;;
    *)
      echo "Unsupported architecture: ${ARCH}"
      exit 1
      ;;
  esac

  token=${GH_TOKEN:-}
  if [[ -r /run/secrets/gh_token ]]; then
    token=$(</run/secrets/gh_token)
  fi
  auth=()
  if [[ -n $token ]]; then
    auth=(-H "Authorization: Bearer $token")
  fi

  # 获取最新版本号
  VERSION=$(curl -q -fsSL "${auth[@]}" "https://api.github.com/repos/jj-vcs/jj/releases/latest" | jq -r '.tag_name')

  # 下载并安装
  TEMP_DIR=$(mktemp -d)
  curl -fsSL "https://github.com/jj-vcs/jj/releases/download/${VERSION}/jj-${VERSION}-${ARCH_NAME}.tar.gz" -o "${TEMP_DIR}/jj.tar.gz"
  tar -xzf "${TEMP_DIR}/jj.tar.gz" -C "${TEMP_DIR}"
  install -m 755 "${TEMP_DIR}/jj" /usr/local/bin/jj
  rm -rf "${TEMP_DIR}"
}

config_jj() {
  install -D -m 0644 ./config.toml "${XDG_CONFIG_HOME:-$HOME/.config}/jj/config.toml"
}

function main() {
  install_jj
  config_jj
  jj --version
}

main
