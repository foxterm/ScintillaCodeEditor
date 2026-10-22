// FoxTerm | Environment.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import CodeEditorTheme
import CodeLanguage
import Scintilla
import SwiftUI

public extension EnvironmentValues {
    @Entry var isEditorActive: Bool = false
    @Entry var isEditable: Bool = true
    @Entry var isInvisible: Bool = false
    @Entry var language: CodeLanguage = .plain_text
    @Entry var themes: Themes?
    @Entry var font: String = "JetBrains Mono"
    @Entry var codePage: CodePage = .utf8
    @Entry var lineNumberFontSize: Int = 15
    @Entry var fontSize: Int = 15
    @Entry var count: Int = 0
    @Entry var zoom: Double = 0
    @Entry var lineEndingMode: EOLMode = .lf
    @Entry var location: NSPoint = .init(x: 0, y: 0)
    @Entry var selectedCharCount: Int = 0
}

public enum CodePage: Int, CaseIterable {
    case utf8
}

public extension CodePage {
    var rawValue: Int {
        Int(SC_CP_UTF8)
    }

    var encoding: String.Encoding {
        switch self {
        case .utf8:
            .utf8
        }
    }
}

public enum EOLMode: Int, CaseIterable {
    case crlf // Windows: \r\n
    case cr // Mac Classic: \r
    case lf // Unix/Linux: \n
}

public extension EOLMode {
    var rawValue: Int {
        switch self {
        case .crlf:
            Int(SC_EOL_CRLF)
        case .cr:
            Int(SC_EOL_CR)
        case .lf:
            Int(SC_EOL_LF)
        }
    }

    var description: String {
        switch self {
        case .crlf:
            "CRLF"
        case .cr:
            "CR"
        case .lf:
            "LF"
        }
    }
}
