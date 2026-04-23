#!/usr/bin/env bash
#[MISE] description="default git task."
#[MISE] dir="{{cwd}}"

set -euo pipefail

# NO.1  迁移到 reftable 格式
mise r git:reftable

# NO.2  执行仓库维护
mise r git:maintain

# NO.3  配置共享钩子
mise r git:hooks
