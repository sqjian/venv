## Shell Scripting Rules

### 参数校验

使用 `${var:?message}` 时，错误信息应包含 usage 格式：

```bash
# 推荐：显示用法
readonly NODE="${1:?Usage: ${0##*/} <node_name>}"

# 避免：仅描述参数
readonly NODE="${1:?node name required}"
```

`${0##*/}` 自动取脚本名，维护成本低且符合 Unix 惯例。

### 常量声明

脚本内不会变化的变量使用 `readonly` 声明：

```bash
readonly CONFIG_PATH="/etc/app/config.yml"
readonly TIMEOUT=30
```

防止意外覆盖，也向读者表明设计意图。

### Heredoc 格式

使用 `<<-EOF` 配合 tab 缩进，保持代码结构整齐：

```bash
curl -sf "$URL" -d @- <<-EOF
	{
	    "model": "${MODEL}",
	    "messages": [{"role": "user", "content": "hello"}]
	}
	EOF
```

- `<<-` 允许 heredoc 内容使用 tab 缩进（空格无效）
- 结束符 `EOF` 也需 tab 缩进对齐
- 配合 `@-` 从 stdin 读取，适合传递 JSON body
