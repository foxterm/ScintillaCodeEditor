// FoxTerm | SwiftUICodeView.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import CodeEditorTheme
import CodeLanguage
import Scintilla
import SwiftUI

/// Scintilla 编辑器的 SwiftUI 包装器
struct SwiftUICodeView: NSViewRepresentable {
    @Binding var text: String
    @Binding var selectedCharCount: Int
    @Environment(\.isEditable) var isEditable
    @Environment(\.isInvisible) var isInvisible
    @Environment(\.language) var language
    @Environment(\.themes) var themes
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.font) var font
    @Environment(\.isEditorActive) var isActive
    @Environment(\.codePage) var codePage
    @Environment(\.lineNumberFontSize) var lineNumberFontSize
    @Environment(\.fontSize) var fontSize
    @Environment(\.zoom) var zoom
    @Environment(\.lineEndingMode) var lineEndingMode
    // @Environment(\.file) var file

    init(
        text: Binding<String>,
        selectedCharCount: Binding<Int>
    ) {
        _text = text
        _selectedCharCount = selectedCharCount
    }

    func makeNSView(context: Context) -> CodeView {
        let codeView = CodeView()
        codeView.autoresizingMask = [.width, .height]
        codeView.autoresizesSubviews = true
        codeView.text = text
        let barView = BarView()
        // barView.setDisplay(.showAll)
        codeView.setInfoBar(barView, top: false)

        codeView.lineNumberFontSize = lineNumberFontSize
        codeView.font = font
        codeView.fontSize = fontSize
        codeView.colorScheme = colorScheme
        codeView.language = language
        codeView.themes = themes
        codeView.isInvisible = isInvisible
        codeView.isDocumentEditable = isEditable

        // 添加插件
        codeView.addPlugin(context.coordinator)
        // codeView.addPlugin(PluginTextPair())
        codeView.addPlugin(PluginHighlight())
        // codeView.addPlugin(PluginCodeServer())
        // codeView.addPlugin(AutoCompletePlugin())
        // codeView.addPlugin(PluginTextComment())

        codeView.setup()
        upadeResponder(codeView)
//        DispatchQueue.main.async {
//            codeViewRef = codeView
//        }

//        if let file, let db = MMKV(mmapID: file.url.string) {
//            let x = db.double(forKey: "location.x")
//            let y = db.double(forKey: "location.y")
//            codeView.location = .init(x: x, y: y)
//        }
        return codeView
    }

    func setText(_ text: String) {
        DispatchQueue.main.async {
            self.text = text
        }
    }

//    func setLocation(_ location: NSPoint) {
//        DispatchQueue.main.async {
//            self.location = location
//        }
//    }

    func setSelectedCharCount(_ selectedCharCount: Int) {
        DispatchQueue.main.async {
            self.selectedCharCount = selectedCharCount
        }
    }

    func updateNSView(_ view: CodeView, context _: Context) {
        if view.codePage != codePage {
            view.codePage = codePage
        }
        if view.text != text {
            view.text = text
        }
        if view.isDocumentEditable != isEditable {
            view.isDocumentEditable = isEditable
        }
        if view.language != language {
            view.language = language
        }
        if view.themes != themes {
            view.themes = themes
        }
        if view.colorScheme != colorScheme {
            view.colorScheme = colorScheme
        }
        if view.isInvisible != isInvisible {
            view.isInvisible = isInvisible
        }
        if view.font != font {
            view.font = font
        }
        if view.lineNumberFontSize != lineNumberFontSize {
            view.lineNumberFontSize = lineNumberFontSize
        }
        if view.fontSize != fontSize {
            view.fontSize = fontSize
        }
        if view.zoom != zoom {
            view.zoom = zoom
        }
        if view.lineEndingMode != lineEndingMode {
            view.lineEndingMode = lineEndingMode
        }
//        if view.location != location {
//            view.location = location
//        }

        upadeResponder(view)
    }

    func upadeResponder(_ view: CodeView) {
        if view.hasFocus != isActive {
            #if DEBUG
                print("活动", isActive, view.hasFocus)
            #endif
            view.hasFocus = isActive
        }
    }

    /// 创建协调器来处理委托回调
    func makeCoordinator() -> PluginTextPlugin {
        PluginTextPlugin(self)
    }
}
