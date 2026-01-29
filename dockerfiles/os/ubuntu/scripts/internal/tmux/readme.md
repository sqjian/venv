# tmux 非交互脚本使用说明

```shell
# 创建会话
tmux new-session -d -s your-session-name

# 发送命令
tmux send-keys -t your-session-name 'your-command' Enter

# 捕获输出并过滤空行
tmux capture-pane -t your-session-name -p -S -100 | awk 'NF'

# 检查状态
tmux display-message -t your-session-name -p '#{pane_dead}'

# 检查窗格当前运行的命令
tmux display-message -t your-session-name -p '#{pane_current_command}'

# 列出会话/窗口/窗格
tmux list-sessions -F '#{session_name}'
tmux list-windows -t your-session-name -F '#{window_index}:#{window_name}'
tmux list-panes -t your-session-name -F '#{pane_index}:#{pane_pid}:#{pane_current_command}'
```