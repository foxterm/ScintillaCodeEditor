// FoxTerm | PluginTextPair.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

//
// import CodeEditor
// import CodeLanguage
// import Foundation
//
// class PluginTextPair: PluginDelegate {
//    // 定义需要自动配对的符号映射
//    private var pairMap: [Brackets] = []
//    var tabSize: Int = 0
//
//    func setup(_ view: some CodeView) {
//        guard let config = view.language?.config else { return }
//        pairMap = config.brackets
//        tabSize = config.tabSize
//    }
//
//    func notification(_ view: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?) {
//        guard let notification else { return }
//        let scNotification = notification.pointee
//        let code = scNotification.nmhdr.code
//
//        // 监听字符添加事件
//        if code == SCN_CHARADDED {
//            guard let unicode = UnicodeScalar(Int(scNotification.ch)) else { return }
//            let char = Character(unicode)
//            codeQuotes(view, char: char)
//        }
//    }
//
//    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}
//
//    private func codeQuotes(_ view: some CodeView, char: Character) {
//        handleCharacterAdded(view, char: char)
//    }
//
//    private func handleCharacterAdded(_: some CodeView, char _: Character) {}
// }
