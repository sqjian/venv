#!/bin/bash

export HTTP_PROXY=http://127.0.0.1:7890
export HTTPS_PROXY=http://127.0.0.1:7890
export NO_PROXY=localhost,127.0.0.1,artifacts.iflytek.com

# unset HTTP_PROXY
# unset HTTPS_PROXY
# unset NO_PROXY

# 定义镜像映射关系（源镜像 → 目标镜像）
declare -A IMAGE_MAP=(
  ["dnginx:latest"]="your-registry.example.com/your-project/nginx:latest"
  ["alpine:3.18"]="your-registry.example.com/your-project/alpine:3.18"
  ["redis:7.0"]="your-registry.example.com/your-project/redis:7.0"
)

# 定义目标仓库认证信息（用户名:密码）
DEST_CREDS="username:password"

# 检查skopeo是否安装
if ! command -v skopeo &>/dev/null; then
  echo "错误：skopeo未安装，请先安装skopeo"
  exit 1
fi

# 遍历镜像映射并执行搬运
for SOURCE_IMAGE in "${!IMAGE_MAP[@]}"; do
  DEST_IMAGE="${IMAGE_MAP[$SOURCE_IMAGE]}"

  echo "开始搬运: $SOURCE_IMAGE → $DEST_IMAGE"

  if skopeo copy \
    --dest-creds="${DEST_CREDS}" \
    "docker://${SOURCE_IMAGE}" \
    "docker://${DEST_IMAGE}"; then
    echo "搬运成功: $SOURCE_IMAGE"
  else
    echo "错误：搬运失败: $SOURCE_IMAGE"
    exit 1
  fi
done

echo "所有镜像搬运完成"
