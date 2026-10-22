// FoxTerm | Theme.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation

public struct Themes: Codable {
    public let name: String
    public let themes: [Theme]

    enum CodingKeys: String, CodingKey {
        case name
        case themes
    }
}

public struct Theme: Codable {
    public let name: String
    public let appearance: String
    public let style: Style

    enum CodingKeys: String, CodingKey {
        case name
        case appearance
        case style
    }
}

public struct Style: Codable {
    public let editorForeground: String
    public let editorBackground: String
    public let editorGutterBackground: String
    public let editorSubheaderBackground: String
    public let editorActiveLineBackground: String
    public let editorHighlightedLineBackground: String
    public let editorLineNumber: String
    public let editorActiveLineNumber: String
    public let editorHoverLineNumber: String
    public let editorInvisible: String
    public let editorWrapGuide: String
    public let editorActiveWrapGuide: String
    public let editorDocumentHighlightReadBackground: String
    public let editorDocumentHighlightWriteBackground: String
    public let terminalBackground: String
    public let terminalForeground: String
    public let terminalBrightForeground: String
    public let terminalDimForeground: String
    public let terminalAnsiBlack: String
    public let terminalAnsiBrightBlack: String
    public let terminalAnsiDimBlack: String
    public let terminalAnsiRed: String
    public let terminalAnsiBrightRed: String
    public let terminalAnsiDimRed: String
    public let terminalAnsiGreen: String
    public let terminalAnsiBrightGreen: String
    public let terminalAnsiDimGreen: String
    public let terminalAnsiYellow: String
    public let terminalAnsiBrightYellow: String
    public let terminalAnsiDimYellow: String
    public let terminalAnsiBlue: String
    public let terminalAnsiBrightBlue: String
    public let terminalAnsiDimBlue: String
    public let terminalAnsiMagenta: String
    public let terminalAnsiBrightMagenta: String
    public let terminalAnsiDimMagenta: String
    public let terminalAnsiCyan: String
    public let terminalAnsiBrightCyan: String
    public let terminalAnsiDimCyan: String
    public let terminalAnsiWhite: String
    public let terminalAnsiBrightWhite: String
    public let terminalAnsiDimWhite: String
    public let linkTextHover: String
    public let conflict: String
    public let conflictBackground: String
    public let conflictBorder: String
    public let created: String
    public let createdBackground: String
    public let createdBorder: String
    public let deleted: String
    public let deletedBackground: String
    public let deletedBorder: String
    public let error: String
    public let errorBackground: String
    public let errorBorder: String
    public let hidden: String
    public let hiddenBackground: String
    public let hiddenBorder: String
    public let hint: String
    public let hintBackground: String
    public let hintBorder: String
    public let ignored: String
    public let ignoredBackground: String
    public let ignoredBorder: String
    public let info: String
    public let infoBackground: String
    public let infoBorder: String
    public let modified: String
    public let modifiedBackground: String
    public let modifiedBorder: String
    public let predictive: String
    public let predictiveBackground: String
    public let predictiveBorder: String
    public let renamed: String
    public let renamedBackground: String
    public let renamedBorder: String
    public let success: String
    public let successBackground: String
    public let successBorder: String
    public let unreachable: String
    public let unreachableBackground: String
    public let unreachableBorder: String
    public let warning: String
    public let warningBackground: String
    public let warningBorder: String
    public let players: [Players]
    public let syntax: [String: Syntax]

    enum CodingKeys: String, CodingKey {
        case editorForeground = "editor.foreground"
        case editorBackground = "editor.background"
        case editorGutterBackground = "editor.gutter.background"
        case editorSubheaderBackground = "editor.subheader.background"
        case editorActiveLineBackground = "editor.active_line.background"
        case editorHighlightedLineBackground = "editor.highlighted_line.background"
        case editorLineNumber = "editor.line_number"
        case editorActiveLineNumber = "editor.active_line_number"
        case editorHoverLineNumber = "editor.hover_line_number"
        case editorInvisible = "editor.invisible"
        case editorWrapGuide = "editor.wrap_guide"
        case editorActiveWrapGuide = "editor.active_wrap_guide"
        case editorDocumentHighlightReadBackground = "editor.document_highlight.read_background"
        case editorDocumentHighlightWriteBackground = "editor.document_highlight.write_background"
        case terminalBackground = "terminal.background"
        case terminalForeground = "terminal.foreground"
        case terminalBrightForeground = "terminal.bright_foreground"
        case terminalDimForeground = "terminal.dim_foreground"
        case terminalAnsiBlack = "terminal.ansi.black"
        case terminalAnsiBrightBlack = "terminal.ansi.bright_black"
        case terminalAnsiDimBlack = "terminal.ansi.dim_black"
        case terminalAnsiRed = "terminal.ansi.red"
        case terminalAnsiBrightRed = "terminal.ansi.bright_red"
        case terminalAnsiDimRed = "terminal.ansi.dim_red"
        case terminalAnsiGreen = "terminal.ansi.green"
        case terminalAnsiBrightGreen = "terminal.ansi.bright_green"
        case terminalAnsiDimGreen = "terminal.ansi.dim_green"
        case terminalAnsiYellow = "terminal.ansi.yellow"
        case terminalAnsiBrightYellow = "terminal.ansi.bright_yellow"
        case terminalAnsiDimYellow = "terminal.ansi.dim_yellow"
        case terminalAnsiBlue = "terminal.ansi.blue"
        case terminalAnsiBrightBlue = "terminal.ansi.bright_blue"
        case terminalAnsiDimBlue = "terminal.ansi.dim_blue"
        case terminalAnsiMagenta = "terminal.ansi.magenta"
        case terminalAnsiBrightMagenta = "terminal.ansi.bright_magenta"
        case terminalAnsiDimMagenta = "terminal.ansi.dim_magenta"
        case terminalAnsiCyan = "terminal.ansi.cyan"
        case terminalAnsiBrightCyan = "terminal.ansi.bright_cyan"
        case terminalAnsiDimCyan = "terminal.ansi.dim_cyan"
        case terminalAnsiWhite = "terminal.ansi.white"
        case terminalAnsiBrightWhite = "terminal.ansi.bright_white"
        case terminalAnsiDimWhite = "terminal.ansi.dim_white"
        case linkTextHover = "link_text.hover"
        case conflict
        case conflictBackground = "conflict.background"
        case conflictBorder = "conflict.border"
        case created
        case createdBackground = "created.background"
        case createdBorder = "created.border"
        case deleted
        case deletedBackground = "deleted.background"
        case deletedBorder = "deleted.border"
        case error
        case errorBackground = "error.background"
        case errorBorder = "error.border"
        case hidden
        case hiddenBackground = "hidden.background"
        case hiddenBorder = "hidden.border"
        case hint
        case hintBackground = "hint.background"
        case hintBorder = "hint.border"
        case ignored
        case ignoredBackground = "ignored.background"
        case ignoredBorder = "ignored.border"
        case info
        case infoBackground = "info.background"
        case infoBorder = "info.border"
        case modified
        case modifiedBackground = "modified.background"
        case modifiedBorder = "modified.border"
        case predictive
        case predictiveBackground = "predictive.background"
        case predictiveBorder = "predictive.border"
        case renamed
        case renamedBackground = "renamed.background"
        case renamedBorder = "renamed.border"
        case success
        case successBackground = "success.background"
        case successBorder = "success.border"
        case unreachable
        case unreachableBackground = "unreachable.background"
        case unreachableBorder = "unreachable.border"
        case warning
        case warningBackground = "warning.background"
        case warningBorder = "warning.border"
        case players
        case syntax
    }
}

public struct Syntax: Codable {
    public let color: String

    enum CodingKeys: String, CodingKey {
        case color
    }
}

public struct Players: Codable {
    public let cursor: String
    public let background: String
    public let selection: String

    enum CodingKeys: String, CodingKey {
        case cursor
        case background
        case selection
    }
}
