#!/usr/bin/env bash
#[MISE] description="Replicate model files to all hybrid storage upstreams"
#[MISE] dir="{{config_root}}"

set -euo pipefail

readonly SRC="data/iflytek/csn/"
readonly DST="s3:/maas-jjfa-dx/projects/csn"

readonly -a ARGS=(
        --config ".config/rclone.conf" # 指定 rclone 配置文件
        --progress                     # 实时显示传输进度
        --transfers 16                  # 并行传输的文件数
        --checkers 8                   # 并行检查文件的任务数
        --sftp-chunk-size 64Ki         # 使用源 SFTP 支持的最大数据包
        --buffer-size 128M              # 每个传输任务的内存读取缓冲区大小
        --max-buffer-memory 1G         # 所有传输缓冲区可分配的内存上限
        --use-mmap                     # 使用 mmap 分配传输缓冲区
        --retries 3                    # 失败操作的整体重试次数
        --low-level-retries 10         # 底层请求失败后的重试次数
        --retries-sleep 10s            # 操作重试前的等待时间
        --contimeout 30s               # 建立连接的超时时间
        --timeout 5m                   # I/O 空闲超时时间
        --stats 1s                     # 输出传输统计信息的间隔
        --stats-log-level NOTICE       # 传输统计信息的日志级别
)

rclone copy "${ARGS[@]}" "${SRC}" "${DST}"