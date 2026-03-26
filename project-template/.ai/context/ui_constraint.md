# UI Constraints

> Filled in before the UI Design phase (by PM, Tech Lead, or designer).
> The UI Designer reads this file to match brand identity, technology stack, and usability requirements.
> If a field is left blank, the UI Designer will propose and apply a neutral enterprise default.

## Brand Colours

```yaml
primary:          ""   # e.g. #1677ff  — main action buttons, active nav, links
primary_dark:     ""   # e.g. #0958d9  — hover / pressed state of primary
secondary:        ""   # e.g. #52c41a  — secondary accent or category colour
danger:           ""   # e.g. #ff4d4f  — error, destructive actions
warning:          ""   # e.g. #faad14  — warning / caution states
success:          ""   # e.g. #52c41a  — success confirmations
info:             ""   # e.g. #1677ff  — informational badges / tips
neutral_bg:       ""   # e.g. #f5f5f5  — page / layout background
surface:          ""   # e.g. #ffffff  — card, panel, modal background
text_primary:     ""   # e.g. #1f1f1f  — body and heading text
text_secondary:   ""   # e.g. #8c8c8c  — hint, placeholder, label text
border:           ""   # e.g. #d9d9d9  — default divider and border colour
```

## Style Tone

```yaml
tone: ""
# Options:
#   clean-light       — white background, subtle borders, minimal shadows  (default)
#   enterprise-gray   — mid-gray background, card-and-panel layout
#   professional-dark — dark sidebar + light content area  (VS Code–style split)
```

## UI Library

```yaml
ui_library: ""
# Must match the ui_library value in workflow-config.md Tech Stack.
# The wireframe visual language will follow this library's conventions.
# e.g. Element Plus | Ant Design | custom
```

## Typography

```yaml
font_family:    ""   # e.g. system-ui, "Microsoft YaHei", sans-serif
font_size_base: ""   # e.g. 14px  (enterprise systems default)
line_height:    ""   # e.g. 1.5
```

## Layout

```yaml
sidebar_width:   ""   # e.g. 240px  (collapsed: 64px)
header_height:   ""   # e.g. 56px
content_padding: ""   # e.g. 24px
border_radius:   ""   # e.g. 6px  (Element Plus) | 2px  (Ant Design) | 0  (dense grid)
```

## Other

```yaml
dark_mode:  ""   # required | optional | not-needed
i18n:       ""   # zh-CN | en-US | both
```

## Reference

> Paste brand guideline URL, Figma link, or existing screenshot path here.
