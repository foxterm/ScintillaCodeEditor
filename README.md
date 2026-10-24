# ScintillaCodeEditor

[English](README.md) | [中文文档](README_CN.md)

A dedicated code editor library for the FoxTerm APP. Built as a Swift wrapper around Scintilla, it provides syntax highlighting, multi-language support, theme switching, find & replace, and a plugin architecture.

> This library is a dedicated core component for the [FoxTerm](https://foxterm.app/) APP. Download it here: [https://foxterm.app/](https://foxterm.app/)

## Features

- **Scintilla Engine** — High-performance C++ editing core with buffered drawing, word wrap, and overlay scrollbars
- **Syntax Highlighting** — Tree-sitter based incremental parsing with per-language highlight queries
- **Multi-Language Support** — Bash, Dockerfile, INI, JSON, Markdown, SSH Config, TOML, XML, YAML
- **Theme System** — JSON-based themes with light/dark appearance switching (Ayu, Gruvbox, One built-in)
- **Find & Replace** — Native search bar with case-sensitive and whole-word matching, keyboard shortcuts (Cmd+F / Cmd+Option+F)
- **Plugin Architecture** — Extensible plugin system for syntax highlighting, auto-completion, code folding, text pairs, and comment toggling
- **SwiftUI Integration** — `ScintillaCodeEditor` view via NSViewRepresentable with SwiftUI Environment configuration
- **Status Bar** — Real-time cursor position (line/column), character count, and selection count
- **Customizable** — Configurable font, font size, line number font size, zoom level, code page, and EOL mode
- **Current Line Highlight** — Active line background highlighting with line number margin indicator for multi-line selections

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| macOS    | 14.0           |
| Swift    | 5.10           |

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/foxterm/ScintillaCodeEditor.git", branch: "main"),
```

```swift
.product(name: "ScintillaCodeEditor", package: "ScintillaCodeEditor"),
```

### Dependencies

- [tree-sitter](https://github.com/tree-sitter/tree-sitter.git) — Incremental parsing library
- [swiftui-hooks](https://github.com/foxterm/swiftui-hooks.git) — SwiftUI hooks
- [Sync](https://github.com/foxterm/Sync) — Concurrency synchronization primitives
- [Extension](https://github.com/foxterm/Extension) — Foundation extensions
- [CodeLanguage](https://github.com/foxterm/CodeLanguage) — Tree-sitter based syntax highlighting and language detection

## Usage

### Basic Editor

```swift
import ScintillaCodeEditor

struct ContentView: View {
    @State var text = ""

    var body: some View {
        ScintillaCodeEditor(text: $text)
    }
}
```

### Configuration via Environment

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

### Theme Loading

```swift
import CodeEditorTheme

// Load a specific theme
let themes = Themes.load("one")     // "ayu", "gruvbox", "one"

// List available themes
let names = Themes.load()           // ["ayu", "gruvbox", "one"]
```

### Light / Dark Appearance

```swift
ScintillaCodeEditor(text: $text)
    .environment(\.themes, Themes.load("gruvbox"))
    .preferredColorScheme(.dark)     // Switches theme appearance automatically
```

### Supported Languages

```swift
import CodeLanguage

let languages: [CodeLanguage] = [
    .bash, .sh, .yaml, .ini, .json,
    .toml, .xml, .markdown, .ssh_config, .dockerfile
]
```

## Project Structure

```
Sources/
├── ScintillaCodeEditor/
│   ├── ScintillaCodeEditor.swift   # Main SwiftUI entry view
│   ├── Environment.swift           # SwiftUI Environment values & enums (CodePage, EOLMode)
│   ├── String+Localization.swift   # Localized string helpers
│   ├── Bar/
│   │   ├── BarView.swift           # Info bar container (NSView + SwiftUI)
│   │   ├── BarBottomView.swift     # Status bar: line, column, character count
│   │   ├── BarTopView.swift        # Top bar: file path breadcrumb
│   │   ├── MenuView.swift          # Menu components
│   │   ├── MenuPathView.swift      # Path breadcrumb view
│   │   ├── HistoryButtonView.swift # Navigation history buttons
│   │   ├── TagsView.swift          # Tags display
│   │   └── NotificationData.swift  # Observable notification state
│   └── View/
│       ├── CodeView.swift          # Core Scintilla wrapper (NSView)
│       ├── SwiftUICodeView.swift   # NSViewRepresentable bridge
│       ├── Finder.swift            # Native find & replace bar
│       ├── SearchToolbarView.swift # SwiftUI floating search toolbar
│       ├── TextSearch.swift        # Search logic
│       └── Plugin/
│           ├── Plugin.swift            # PluginDelegate & CodeDelegate protocols
│           ├── PluginText.swift        # Text change sync plugin
│           ├── PluginHighlight.swift   # Tree-sitter syntax highlighting plugin
│           ├── PluginTextComment.swift # Comment toggle plugin
│           ├── PluginTextPair.swift    # Bracket pair auto-completion plugin
│           ├── PluginFold.swift        # Code folding plugin
│           ├── PluginAutoComplete.swift# Auto-completion plugin
│           └── PluginCodeServer.swift  # LSP integration plugin
├── CodeEditorTheme/
│   ├── Theme.swift                 # Theme/Style/Syntax model (Codable)
│   ├── Bundle.swift                # Theme JSON loader
│   └── Resources/                  # Built-in theme JSON files (ayu, gruvbox, one)
└── Scintilla/                      # Scintilla C++ source (cocoa platform)
```

## License

MIT
