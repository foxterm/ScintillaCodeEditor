# ScintillaCodeEditor

[English](README.md) | [中文文档](README_CN.md)

FoxTerm APP 专用代码编辑器库，基于 Scintilla 的 Swift 封装，支持语法高亮、多语言、主题切换、查找替换及插件架构。

> 本库为 [FoxTerm](https://foxterm.app/) APP 专用核心组件，欢迎下载使用：[https://foxterm.app/](https://foxterm.app/)

## 功能

- **Scintilla 引擎** — 高性能 C++ 编辑核心，支持缓冲绘制、自动换行、覆盖式滚动条
- **语法高亮** — 基于 Tree-sitter 的增量解析，按语言配置高亮查询
- **多语言支持** — Bash、Dockerfile、INI、JSON、Markdown、SSH Config、TOML、XML、YAML
- **主题系统** — JSON 配置主题，支持亮色/暗色外观自动切换（内置 Ayu、Gruvbox、One）
- **查找替换** — 原生搜索栏，支持区分大小写和全字匹配，快捷键（Cmd+F / Cmd+Option+F）
- **插件架构** — 可扩展插件系统，支持语法高亮、自动补全、代码折叠、括号配对、注释切换
- **SwiftUI 集成** — `ScintillaCodeEditor` 视图通过 NSViewRepresentable 桥接，支持 SwiftUI Environment 配置
- **状态栏** — 实时光标位置（行/列）、字符数、选中字符数
- **可定制** — 可配置字体、字号、行号字号、缩放级别、编码页面、换行符模式
- **当前行高亮** — 活动行背景高亮，行号边距标记支持多行选区指示

## 环境要求

| 平台  | 最低版本 |
|-------|---------|
| macOS | 14.0    |
| Swift | 5.10    |

## 安装

### Swift Package Manager

```swift
.package(url: "https://github.com/foxterm/ScintillaCodeEditor.git", branch: "main"),
```

```swift
.product(name: "ScintillaCodeEditor", package: "ScintillaCodeEditor"),
```

### 依赖

- [tree-sitter](https://github.com/tree-sitter/tree-sitter.git) — 增量解析库
- [swiftui-hooks](https://github.com/ra1028/swiftui-hooks) — SwiftUI Hooks
- [Sync](https://github.com/foxterm/Sync) — 并发同步原语
- [Extension](https://github.com/foxterm/Extension) — Foundation 扩展

## 使用

### 基本编辑器

```swift
import ScintillaCodeEditor

struct ContentView: View {
    @State var text = ""

    var body: some View {
        ScintillaCodeEditor(text: $text)
    }
}
```

### 通过 Environment 配置

```swift
ScintillaCodeEditor(text: $text)
    .environment(\.language, .json)
    .environment(\.themes, Themes.load("one"))
    .environment(\.font, "JetBrains Mono")
    .environment(\.fontSize, 16)
    .environment(\.lineNumberFontSize, 12)
    .environment(\.isEditable, true)
    .environment(\.isInvisible, false)
    .environment(\.zoom, 0)
    .environment(\.codePage, .utf8)
    .environment(\.lineEndingMode, .lf)
```

### 主题加载

```swift
import CodeEditorTheme

// 加载指定主题
let themes = Themes.load("one")     // "ayu"、"gruvbox"、"one"

// 列出所有可用主题
let names = Themes.load()           // ["ayu", "gruvbox", "one"]
```

### 亮色 / 暗色外观

```swift
ScintillaCodeEditor(text: $text)
    .environment(\.themes, Themes.load("gruvbox"))
    .preferredColorScheme(.dark)     // 自动切换主题外观
```

### 支持的语言

```swift
import CodeLanguage

let languages: [CodeLanguage] = [
    .bash, .sh, .yaml, .ini, .json,
    .toml, .xml, .markdown, .ssh_config, .dockerfile
]
```

## 项目结构

```
Sources/
├── ScintillaCodeEditor/
│   ├── ScintillaCodeEditor.swift   # 主 SwiftUI 入口视图
│   ├── Environment.swift           # SwiftUI Environment 值与枚举（CodePage、EOLMode）
│   ├── String+Localization.swift   # 本地化字符串工具
│   ├── Bar/
│   │   ├── BarView.swift           # 信息栏容器（NSView + SwiftUI）
│   │   ├── BarBottomView.swift     # 底部状态栏：行、列、字符数
│   │   ├── BarTopView.swift        # 顶部栏：文件路径面包屑
│   │   ├── MenuView.swift          # 菜单组件
│   │   ├── MenuPathView.swift      # 路径面包屑视图
│   │   ├── HistoryButtonView.swift # 导航历史按钮
│   │   ├── TagsView.swift          # 标签显示
│   │   └── NotificationData.swift  # 可观察通知状态
│   └── View/
│       ├── CodeView.swift          # 核心 Scintilla 封装（NSView）
│       ├── SwiftUICodeView.swift   # NSViewRepresentable 桥接
│       ├── Finder.swift            # 原生查找替换栏
│       ├── SearchToolbarView.swift # SwiftUI 悬浮搜索工具栏
│       ├── TextSearch.swift        # 搜索逻辑
│       └── Plugin/
│           ├── Plugin.swift            # PluginDelegate 与 CodeDelegate 协议
│           ├── PluginText.swift        # 文本变更同步插件
│           ├── PluginHighlight.swift   # Tree-sitter 语法高亮插件
│           ├── PluginTextComment.swift # 注释切换插件
│           ├── PluginTextPair.swift    # 括号自动配对插件
│           ├── PluginFold.swift        # 代码折叠插件
│           ├── PluginAutoComplete.swift# 自动补全插件
│           └── PluginCodeServer.swift  # LSP 集成插件
├── CodeEditorTheme/
│   ├── Theme.swift                 # Theme/Style/Syntax 模型（Codable）
│   ├── Bundle.swift                # 主题 JSON 加载器
│   └── Resources/                  # 内置主题 JSON 文件（ayu、gruvbox、one）
├── CodeLanguage/
│   ├── CodeLanguage.swift          # 语言枚举定义
│   ├── CodeLanguage+C.swift        # Tree-sitter 语言绑定
│   ├── Syntax.swift                # 高亮查询引擎（全局缓存）
│   ├── QueryCapture.swift          # 查询捕获结果模型
│   └── Config.swift                # 语言特定配置
├── Scintilla/                      # Scintilla C++ 源码（Cocoa 平台）
├── TreeSitterBash/                 # Tree-sitter 语法：Bash
├── TreeSitterDockerfile/           # Tree-sitter 语法：Dockerfile
├── TreeSitterINI/                  # Tree-sitter 语法：INI
├── TreeSitterJSON/                 # Tree-sitter 语法：JSON
├── TreeSitterMarkdown/             # Tree-sitter 语法：Markdown
├── TreeSitterSSHConfig/            # Tree-sitter 语法：SSH Config
├── TreeSitterTOML/                 # Tree-sitter 语法：TOML
├── TreeSitterXML/                  # Tree-sitter 语法：XML
├── TreeSitterYAML/                 # Tree-sitter 语法：YAML
└── TreeSitter*Queries/             # 各语言高亮查询 .scm 文件
```

## 许可证

MIT
