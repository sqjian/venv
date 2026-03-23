#!/bin/bash

export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export NO_PROXY=localhost,127.0.0.1,artifacts.iflytek.com

# unset HTTP_PROXY
# unset HTTPS_PROXY
# unset NO_PROXY

declare -A IMAGE_MAP=(
	["nginx:latest"]="your-registry.example.com/your-project/nginx:latest"
	["alpine:3.18"]="your-registry.example.com/your-project/alpine:3.18"
	["redis:7.0"]="your-registry.example.com/your-project/redis:7.0"
	["plantuml/plantuml-server:jetty-v1.2026.2"]="your-registry.example.com/your-project/plantuml-server:jetty-v1.2026.2"
)

DEST_CREDS="username:password"

declare -A SRC_CREDS_MAP=(
	["docker.io"]="username:password"
	["quay.io"]="username:password"
)

command -v skopeo >/dev/null || {
	echo "错误：skopeo未安装"
	exit 1
}

get_registry() {
	local image="$1"
	if [[ "$image" == *.*/* ]]; then
		echo "${image%%/*}"
	else
		echo "docker.io"
	fi
}

for source in "${!IMAGE_MAP[@]}"; do
	dest="${IMAGE_MAP[$source]}"
	registry=$(get_registry "$source")
	src_creds_arg=()
	if [[ -n "${SRC_CREDS_MAP[$registry]}" ]]; then
		src_creds_arg=(--src-creds "${SRC_CREDS_MAP[$registry]}")
	fi
	echo "搬运: $source → $dest"
	skopeo copy "${src_creds_arg[@]}" --dest-creds="$DEST_CREDS" "docker://$source" "docker://$dest" || {
		echo "搬运失败: $source"
		exit 1
	}
done

echo "搬运完成"
