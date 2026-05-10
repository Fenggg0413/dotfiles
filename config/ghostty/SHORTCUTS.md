# Ghostty Shortcuts

我在 `config` 里自定义的所有键位。所有未列出的（复制 `Cmd+C`、粘贴 `Cmd+V`、新窗口 `Cmd+N` 等）走 Ghostty 默认。

## 标签页 (Tabs)

| 快捷键 | 动作 |
| --- | --- |
| `Cmd+T` | 新建标签页 |
| `Cmd+W` | 关闭当前 surface（标签页/分屏） |
| `Cmd+Shift+←` | 上一个标签页 |
| `Cmd+Shift+→` | 下一个标签页 |

## 分屏 (Splits)

| 快捷键 | 动作 |
| --- | --- |
| `Cmd+D` | 向右分屏 |
| `Cmd+Shift+D` | 向下分屏 |
| `Cmd+Option+←` | 跳到左侧分屏 |
| `Cmd+Option+→` | 跳到右侧分屏 |
| `Cmd+Option+↑` | 跳到上方分屏 |
| `Cmd+Option+↓` | 跳到下方分屏 |
| `Cmd+Shift+E` | 平分所有分屏 |
| `Cmd+Shift+F` | 放大/还原当前分屏（zoom toggle） |

## 字号 (Font Size)

| 快捷键 | 动作 |
| --- | --- |
| `Cmd++` | 字号 +1 |
| `Cmd+-` | 字号 -1 |
| `Cmd+0` | 重置字号 |

## 快速终端 (Quick Terminal)

| 快捷键 | 动作 |
| --- | --- |
| `Option+`` ` | 全局呼出/隐藏 Quake 风格下拉终端 |

> Quick Terminal 配置：从顶部下拉、跟随鼠标所在屏幕、失焦自动隐藏、动画 0.15s。

## 配置 (Config)

| 快捷键 | 动作 |
| --- | --- |
| `Cmd+Shift+,` | 重载 `~/.config/ghostty/config` |

---

完整 action 列表见 `ghostty +list-actions`，所有配置项见 `ghostty +show-config --default --docs`。
