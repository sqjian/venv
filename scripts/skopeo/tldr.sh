#!/usr/bin/env bash
# skopeo 常见用法速查
# skopeo 是一个用于操作容器镜像和镜像仓库的命令行工具

set -euo pipefail

# ============================================================
# 1. 查看远程镜像信息 (inspect)
# ============================================================

# 查看 Docker Hub 上的镜像信息
skopeo inspect docker://docker.io/library/nginx:latest

# 查看镜像的原始 manifest
skopeo inspect --raw docker://docker.io/library/nginx:latest

# 查看特定平台的镜像信息（--override-os/--override-arch 是全局选项，须放在子命令前）
skopeo --override-os linux --override-arch arm64 inspect \
	docker://docker.io/library/nginx:latest

# 查看私有仓库镜像（带认证）
skopeo inspect --creds user:password docker://registry.example.com/myimage:latest

# ============================================================
# 2. 复制镜像 (copy)
# ============================================================

# 在不同仓库之间复制镜像
skopeo copy \
	docker://docker.io/library/nginx:latest \
	docker://registry.example.com/nginx:latest

# 从 Docker Hub 复制到本地目录 (dir 格式)
skopeo copy \
	docker://docker.io/library/alpine:latest \
	dir:/tmp/alpine-image

# 从 Docker Hub 复制为 OCI 布局
skopeo copy \
	docker://docker.io/library/alpine:latest \
	oci:/tmp/alpine-oci:latest

# 复制为 docker-archive (tar 文件，可被 docker load 加载)
skopeo copy \
	docker://docker.io/library/alpine:latest \
	docker-archive:/tmp/alpine.tar:alpine:latest

# 复制多架构镜像（保留所有平台）
skopeo copy --all \
	docker://docker.io/library/nginx:latest \
	docker://registry.example.com/nginx:latest

# 仅复制特定平台的镜像（--override-os/--override-arch 是全局选项，须放在子命令前）
skopeo --override-os linux --override-arch amd64 copy \
	docker://docker.io/library/nginx:latest \
	docker://registry.example.com/nginx:amd64

# 使用认证文件复制
skopeo copy \
	--authfile /path/to/auth.json \
	docker://source-registry.com/image:tag \
	docker://dest-registry.com/image:tag

# 跳过源/目标 TLS 验证（适用于自签名证书的私有仓库）
skopeo copy \
	--src-tls-verify=false \
	--dest-tls-verify=false \
	docker://insecure-registry:5000/image:tag \
	docker://another-registry:5000/image:tag

# 分别指定源和目标的认证凭据（适用于跨仓库搬运）
skopeo copy \
	--src-creds user:password \
	--dest-creds user:password \
	docker://source-registry.com/image:tag \
	docker://dest-registry.com/image:tag

# 通过代理搬运镜像（在命令前设置代理环境变量）
HTTP_PROXY=http://127.0.0.1:7890 \
	HTTPS_PROXY=http://127.0.0.1:7890 \
	NO_PROXY=localhost,127.0.0.1,dest-registry.com \
	skopeo copy \
	docker://docker.io/library/nginx:latest \
	docker://dest-registry.com/nginx:latest

# ============================================================
# 3. 删除镜像 (delete)
# ============================================================

# 删除远程仓库中的镜像
skopeo delete docker://registry.example.com/myimage:old-tag

# ============================================================
# 4. 登录/登出仓库 (login/logout)
# ============================================================

# 登录到仓库
skopeo login registry.example.com

# 使用用户名密码登录
skopeo login -u user -p password registry.example.com

# 登出仓库
skopeo logout registry.example.com

# 登出所有仓库
skopeo logout --all

# ============================================================
# 5. 列出仓库中的标签 (list-tags)
# ============================================================

# 列出镜像的所有标签
skopeo list-tags docker://docker.io/library/nginx

# 列出私有仓库镜像的所有标签
skopeo list-tags --creds user:password docker://registry.example.com/myimage

# ============================================================
# 6. 同步镜像 (sync)
# ============================================================

# 从远程仓库同步到本地目录
skopeo sync --src docker --dest dir \
	registry.example.com/myimage /tmp/sync-output

# 从本地目录同步到远程仓库
skopeo sync --src dir --dest docker \
	/tmp/sync-output registry.example.com/

# 从一个仓库同步到另一个仓库
skopeo sync --src docker --dest docker \
	source-registry.com/image dest-registry.com/

# 从远程仓库同步到本地目录，并指定 OCI 格式
# 不指定 tag 则同步该仓库下所有 tag；指定 tag 则只同步该 tag
skopeo sync --src docker --dest dir --format oci \
	registry.example.com/myimage \
	./local-dir

# 使用 YAML 配置文件批量同步
skopeo sync --src yaml --dest docker \
	sync-config.yaml dest-registry.com/

# ============================================================
# 7. 实用技巧
# ============================================================

# 查看镜像摘要 (digest)
skopeo inspect --format '{{.Digest}}' docker://docker.io/library/nginx:latest

# 查看镜像大小
skopeo inspect --format '{{.LayersData}}' docker://docker.io/library/alpine:latest

# 从本地 dir 格式镜像加载到 docker daemon
skopeo copy \
	"dir:./local-dir/myimage:tag" \
	docker-daemon:registry.example.com/myimage:tag

# 使用 docker daemon 中的镜像作为源
skopeo copy \
	docker-daemon:myimage:latest \
	docker://registry.example.com/myimage:latest

# 对比两个镜像的 digest 是否一致
diff <(skopeo inspect --format '{{.Digest}}' docker://registry-a.com/image:tag) \
	<(skopeo inspect --format '{{.Digest}}' docker://registry-b.com/image:tag)
