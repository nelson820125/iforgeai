# UI 约束条件

> 在 UI 设计阶段开始前填写（由 PM、技术负责人或设计师完成）。
> UI 设计师读取此文件，以遵循品牌规范、技术栈约束与可用性要求。
> 若某字段留空，UI 设计师将自行提案并应用中性的企业级默认值。

## 品牌色彩

```yaml
primary:          ""   # 主色，如 #1677ff — 主操作按钮、激活导航、链接
primary_dark:     ""   # 主色深色态，如 #0958d9 — 悬停 / 按下状态
secondary:        ""   # 辅助色 / 强调色，如 #52c41a
danger:           ""   # 错误 / 危险操作，如 #ff4d4f
warning:          ""   # 警告状态，如 #faad14
success:          ""   # 成功确认，如 #52c41a
info:             ""   # 信息提示徽标，如 #1677ff
neutral_bg:       ""   # 页面 / 布局背景色，如 #f5f5f5
surface:          ""   # 卡片、面板、弹窗背景，如 #ffffff
text_primary:     ""   # 正文与标题文字，如 #1f1f1f
text_secondary:   ""   # 次要 / 提示 / 占位文字，如 #8c8c8c
border:           ""   # 默认分割线与边框色，如 #d9d9d9
```

## 风格基调

```yaml
tone: ""
# 可选值：
#   clean-light       — 白底背景、细边框、极简阴影（默认）
#   enterprise-gray   — 灰底背景、卡片面板布局
#   professional-dark — 深色侧边栏 + 浅色内容区（VS Code 式分割）
```

## UI 组件库

```yaml
ui_library: ""
# 必须与 workflow-config.md 技术栈中的 ui_library 保持一致。
# 线框图视觉语言将遵循该组件库的设计规范。
# 如：Element Plus | Ant Design | 自定义
```

## 字体排版

```yaml
font_family:    ""   # 如 system-ui, "Microsoft YaHei", sans-serif
font_size_base: ""   # 如 14px（企业级系统默认）
line_height:    ""   # 如 1.5
```

## 布局

```yaml
sidebar_width:   ""   # 如 240px（折叠态：64px）
header_height:   ""   # 如 56px
content_padding: ""   # 如 24px
border_radius:   ""   # 如 6px（Element Plus）| 2px（Ant Design）| 0（紧凑表格型）
```

## 其他

```yaml
dark_mode:  ""   # required（必须）| optional（可选）| not-needed（不需要）
i18n:       ""   # zh-CN | en-US | both
```

## 参考资料

> 在此粘贴品牌规范 URL、Figma 链接或现有截图路径。
