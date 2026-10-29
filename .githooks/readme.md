# Git Hooks

本目录的 hook 由 pre-commit 框架托管，不要设置 `core.hooksPath`（二者互斥，会让 pre-commit 的检查全部失效）。

## Install

```bash
mise r base:pre-commit
```

该任务会安装 pre-commit、清除 `core.hooksPath`、创建缺失的 `.pre-commit-config.yaml`，并按其中的 `default_install_hook_types` 安装 `pre-commit` 与 `commit-msg` hook。

## Notes

`commit-msg` 负责补 `Signed-off-by` trailer。它挂在 `commit-msg` 而非 `prepare-commit-msg` 阶段：后者在编辑器打开前运行，此时正文为空，`git interpret-trailers` 会把 trailer 插到第 1 行之后，导致用户输入 subject 后两者之间缺少空行。
