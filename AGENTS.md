# AGENTS.md

## 包管理器

- Python → **uv**（非 pip/poetry）
- TypeScript → **bun**（非 npm/yarn/pnpm）

## 任务运行

```bash
mise t ls          # 查看全部任务
mise r task-name   # 执行任务
```

## tmux 约定

`tmux <session>:<window>.<pane>` — 例如 `tmux foo:2.3` 指 `foo` session 的第 2 窗口第 3 面板

## 编码原则

- **Think Before Coding** — 阻止错误的假设和遗漏的权衡
- **Simplicity First** — 阻止过度设计和臃肿的抽象
- **Surgical Changes** — 阻止触碰未经要求的代码
- **Goal-Driven Execution** — 测试先行，验证成功标准
