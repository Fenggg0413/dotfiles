# tmux 本地配置说明

本目录只管理 oh-my-tmux 的本地覆盖配置。主配置由 `init.sh` 安装到：

```text
~/.local/share/tmux/oh-my-tmux/.tmux.conf
```

并通过 XDG 路径加载：

```text
~/.config/tmux/tmux.conf
```

本仓库管理的覆盖配置是：

```text
config/tmux/tmux.conf.local
```

`init.sh` 会把它链接到：

```text
~/.config/tmux/tmux.conf.local
```

## 当前自定义项

### 1. Prefix 键

使用 `Ctrl-a` 作为唯一 Prefix：

```tmux
set -gu prefix2
unbind C-a
unbind C-b
set -g prefix C-a
bind C-a send-prefix
```

效果：

- `Ctrl-a` 是主要 Prefix；
- 不再同时保留 `Ctrl-b` 作为第二 Prefix；
- 需要向终端程序发送字面量 `Ctrl-a` 时，按两次 `Ctrl-a`。

### 2. 新建 pane 的目录行为

保留 oh-my-tmux 当前设置：

```tmux
tmux_conf_new_pane_retain_current_path=true
```

效果：

- 新建 pane 会从当前 pane 的目录开始；
- 新建 window 不强制保留当前目录，仍按 oh-my-tmux 当前配置处理。

### 3. 状态栏内容

状态栏内容保持 oh-my-tmux 当前本地配置，不额外改动：

```tmux
tmux_conf_theme_status_left=" ❐ #S | ↑#{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" #{prefix}#{mouse}#{pairing}#{synchronized}#{?battery_status,#{battery_status},}#{?battery_bar, #{battery_bar},}#{?battery_percentage, #{battery_percentage},} , %R , %d %b | #{username}#{root} | #{hostname} "
```

左侧显示：

- session 名；
- uptime 信息。

右侧显示：

- prefix、mouse、pairing、synchronized 等状态指示；
- 电池状态；
- 时间和日期；
- 用户名和主机名。

### 4. Pane 高亮

关闭 focused pane 背景高亮：

```tmux
tmux_conf_theme_highlight_focused_pane=false
```

效果：

- 当前 pane 不会改变背景色；
- 仍保留 active pane 边框高亮，由 oh-my-tmux 的 active border 颜色控制：

```tmux
tmux_conf_theme_pane_active_border="$tmux_conf_theme_colour_4"
```

### 5. 鼠标

启用鼠标：

```tmux
set -g mouse on
```

效果：

- 可以用鼠标选择 pane；
- 可以用鼠标调整 pane 大小；
- 可以用滚轮进入/浏览 tmux scrollback。

### 6. Vi 模式

启用 tmux 命令提示和 copy-mode 的 vi 风格按键：

```tmux
set -g status-keys vi
setw -g mode-keys vi
```

效果：

- copy-mode 使用 vi 风格移动；
- 命令提示输入使用 vi 风格编辑。

### 7. 系统剪贴板

启用复制到系统剪贴板：

```tmux
tmux_conf_copy_to_os_clipboard=true
```

效果：

- 在 tmux copy-mode 里复制内容时，oh-my-tmux 会尝试同步到系统剪贴板；
- Linux 上可能需要 `xsel`、`xclip` 或 `wl-copy`；
- macOS 通常使用系统自带剪贴板工具。

### 8. Scrollback 历史长度

设置历史长度为 65536 行：

```tmux
set -g history-limit 65536
```

效果：

- 每个 pane 保留更多滚动历史；
- 适合查看构建日志、测试输出和长命令输出。

### 9. Window 和 pane 编号

编号从 1 开始：

```tmux
set -g base-index 1
setw -g pane-base-index 1
```

效果：

- window 编号从 `1` 开始；
- pane 编号从 `1` 开始；
- 更贴近键盘数字键位置。

### 10. 自动重排 window 编号

关闭 window 后自动重排编号：

```tmux
set -g renumber-windows on
```

效果：

- 关闭中间的 window 后，后续 window 编号会自动补齐；
- 避免长期出现编号空洞。

### 11. Escape 延迟

取消 escape sequence 等待延迟：

```tmux
set -sg escape-time 0
```

效果：

- vi、nvim、fzf 等终端程序里的 Esc 响应更快；
- 减少模式切换时的顿挫感。

### 12. Reload 快捷键

设置 `Prefix + r` 重新加载配置：

```tmux
bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
```

使用方式：

```text
Ctrl-a r
```

效果：重新 source oh-my-tmux 主配置，并由主配置继续加载 `tmux.conf.local`。

### 13. 同步输入快捷键

设置 `Prefix + e` 切换 pane 同步输入：

```tmux
bind e setw synchronize-panes \; display-message "synchronize-panes #{?synchronize-panes,on,off}"
```

使用方式：

```text
Ctrl-a e
```

效果：

- 开启后，同一个 window 内多个 pane 会同时收到输入；
- 适合在多个 shell、服务器或目录里执行同一命令；
- 再按一次关闭。

### 14. TPM 插件

启用两个插件：

```tmux
set -g @plugin 'tmux-plugins/tmux-copycat'
set -g @plugin 'tmux-plugins/tmux-resurrect'
```

#### tmux-copycat

用途：增强 tmux 内搜索和复制能力。

常见能力包括：

- 搜索文件路径；
- 搜索 URL；
- 搜索 git hash；
- 搜索常见文本模式。

#### tmux-resurrect

用途：保存和恢复 tmux 会话布局。

常用快捷键：

```text
Prefix + Ctrl-s  保存 tmux 会话
Prefix + Ctrl-r  恢复 tmux 会话
```

如果插件没有自动安装，可以在 tmux 中运行：

```text
Ctrl-a I
```

## 常用操作

### 重新加载配置

```text
Ctrl-a r
```

或手动运行：

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

### 查看 tmux 实际加载的配置文件

```bash
tmux display-message -p '#{config_files}'
```

期望看到 oh-my-tmux 主配置路径，例如：

```text
/Users/feng/.local/share/tmux/oh-my-tmux/.tmux.conf
```

### 检查关键配置

```bash
tmux show -gqv prefix
tmux show -gqv history-limit
tmux show -gqv status-keys
tmux show -gw mode-keys
tmux show -gqv mouse
```
