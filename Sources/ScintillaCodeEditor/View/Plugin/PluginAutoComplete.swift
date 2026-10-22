// FoxTerm | PluginAutoComplete.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

// import Foundation
// import Scintilla
// import SwifterSwift
//
// class PluginAutoComplete: PluginDelegate {
//    private var keywords: [String] = []
//
//    /// private let lock = NSLock()
//    private var currentHighlightTask: DispatchWorkItem?
//
//    func setup(_ view: some CodeView) {
//        // 设置自动补全的基本属性
//        view.setGeneralProperty(SCI_AUTOCSETIGNORECASE, value: 0) // 忽略大小写
//        view.setGeneralProperty(SCI_AUTOCSETCHOOSESINGLE, value: 0) // 单个选项时自动选择
//        view.setGeneralProperty(SCI_AUTOCSETDROPRESTOFWORD, value: 0) // 替换单字剩余部分
//        view.setGeneralProperty(SCI_AUTOCSETCANCELATSTART, value: 0) // 允许在单词开头触发自动补全
//        view.setGeneralProperty(SCI_AUTOCCOMPLETE, value: 1)
//        view.setGeneralProperty(SCI_AUTOCSETORDER, value: Int(SC_ORDER_PRESORTED))
//        view.setGeneralProperty(SCI_AUTOCSETOPTIONS, value: Int(SC_AUTOCOMPLETE_SELECT_FIRST_ITEM))
//
//        // 设置自动补全最大高度(例如最多显示10个项目)
//        view.setGeneralProperty(SCI_AUTOCSETMAXHEIGHT, value: 10)
//
//        // 设置自动补全最大宽度(例如最多显示30个字符宽度)
//        view.setGeneralProperty(SCI_AUTOCSETMAXWIDTH, value: 30)
//
//        // 设置分隔符，空格、换行等会触发完成选择
//        let separators = " \n\t\r[]{}()<>+-*/=\\|&!@#$%^&*(),./?;:'\"[]{}~`"
//        view.setStringProperty(SCI_AUTOCSTOPS, parameter: 0, value: separators)
//
//        // 分配默认样式
//        view.setGeneralProperty(SCI_ALLOCATEEXTENDEDSTYLES, value: 1)
//    }
//
////    func setupLanguage(_: some CodeView) {
//    ////        keywords += view.language?.id.keywords ?? []
//    ////        keywords += view.language?.id.types ?? []
//    ////        keywords += view.language?.id.constants ?? []
//    ////        keywords += view.language?.id.builtins ?? []
////    }
//
////    func setupTheme(_ view: some CodeView) {
////        guard let editorTheme = view.style else { return }
////
////        view.setColorProperty(SCI_CALLTIPSETBACK, parameter: 0, fromHTML: editorTheme.editorBackground)
////        view.setColorProperty(SCI_CALLTIPSETFORE, parameter: 0, fromHTML: editorTheme.editorForeground)
////        //  view.setColorProperty(SCI_CALLTIPSETFOREHLT, parameter: 0, fromHTML: editorTheme.selection)
////    }
//
//    func notification(_ view: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?) {
//        guard let notification else { return }
//        let scNotification = notification.pointee
//        let code = Int32(scNotification.nmhdr.code)
//
//        switch code {
//        case SCN_CHARADDED:
//            handleCharacterAdded(view)
//        case SCN_AUTOCSELECTION:
//            // 处理自动补全选择
//            break
//        case SCN_AUTOCCANCELLED:
//            // 处理自动补全取消
//            currentHighlightTask?.cancel()
//        default:
//            break
//        }
//    }
//
//    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}
//
//    private func handleCharacterAdded(_ view: some CodeView) {
//        currentHighlightTask?.cancel()
//
//        let task = DispatchWorkItem { [self] in
//            runMan {
//                self.showAutoCompletion(view)
//            }
//        }
//
//        currentHighlightTask = task
//
//        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1, execute: task)
//    }
//
//    func runMan(_ callback: @escaping () -> Void) {
//        let semaphore = DispatchSemaphore(value: 0)
//        DispatchQueue.main.async {
//            callback()
//            semaphore.signal()
//        }
//        semaphore.wait()
//    }
//
//    private func showAutoCompletion(_ view: some CodeView) {
////        // 使用锁确保同一时间只有一个高亮任务在执行
////        guard lock.try() else {
////            view.setGeneralProperty(SCI_AUTOCCANCEL, value: 0)
////            #if DEBUG
////                print("❌", "自动补全 操作正在进行中，忽略本次请求")
////            #endif
////            return
////        }
////
////        // 确保锁最终会被释放
////        defer {
////            lock.unlock()
////            #if DEBUG
////                print("👌", "释放 自动补全 锁")
////            #endif
////        }
//        let currentPos = Int(view.getGeneralProperty(SCI_GETCURRENTPOS, parameter: 0, extra: 0))
//        let wordStartPos = Int(view.getGeneralProperty(SCI_WORDSTARTPOSITION, parameter: currentPos, extra: 0))
//        let wordLen = currentPos - wordStartPos
//
//        guard wordLen > 0 else {
//            view.setGeneralProperty(SCI_AUTOCCANCEL, value: 0)
//            return
//        }
//
//        // let currentPos = Int(view.getGeneralProperty(SCI_GETCURRENTPOS, parameter: 0, extra: 0))
//        //  let wordLen = currentPos - wordStartPos
//
//        // 分配足够的内存来存储文本
//        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: wordLen + 1)
//        defer { buffer.deallocate() }
//
//        // 初始化缓冲区
//        buffer.initialize(repeating: 0, count: wordLen + 1)
//        defer { buffer.deinitialize(count: wordLen + 1) }
//
//        // 创建文本范围结构
//        var textRange = Sci_TextRange(
//            chrg: Sci_CharacterRange(
//                cpMin: Sci_PositionCR(wordStartPos),
//                cpMax: Sci_PositionCR(currentPos)
//            ),
//            lpstrText: buffer
//        )
//
//        withUnsafePointer(to: &textRange) { ptr in
//            _ = view.message(UInt32(SCI_GETTEXTRANGE), wParam: 0, lParam: sptr_t(Int(bitPattern: ptr)))
//        }
//
//        // 从缓冲区获取文本
//        let typedWord = String(cString: buffer)
//
//        // 过滤关键字列表，找出匹配的项
//        let matchingKeywords = keywords.filter { keyword in
//            keyword.lowercased().hasPrefix(typedWord.lowercased())
//        } // .sorted()
//
//        // 如果有匹配的关键字，则显示自动补全
//        if !matchingKeywords.isEmpty {
//            let autoCompleteList = matchingKeywords.joined(separator: " ")
//            view.setStringProperty(SCI_AUTOCSHOW, parameter: typedWord.count, value: autoCompleteList)
//        }
//    }
// }
