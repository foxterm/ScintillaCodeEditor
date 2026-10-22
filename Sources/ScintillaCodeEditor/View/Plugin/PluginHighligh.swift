// FoxTerm | PluginHighligh.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import CodeEditorTheme
import CodeLanguage
import Foundation
import Scintilla

/// 代码高亮插件类，用于处理代码语法高亮显示
class PluginHighlight: PluginDelegate {
    let styleLastPredefined = Int(STYLE_LASTPREDEFINED + 1)
    private var lastHighlightedRange: (start: Int, end: Int) = (0, 0)
    private var isCompatible = false
    private var currentHighlightTask: DispatchWorkItem?

    /// 设置插件初始状态
    /// - Parameter view: 代码视图实例
    func setup(_ view: some CodeView) {
        setupTheme(view)
        setupLanguage(view)
    }

    func setupLanguage(_ view: some CodeView) {
        // 清除所有现有高亮
        // view.setGeneralProperty(SCI_CLEARDOCUMENTSTYLE, parameter: 0, value: 0)

        isCompatible = view.language?.doctor() ?? false
        guard isCompatible else {
            return
        }
        _ = autoreleasepool {
            malloc_zone_pressure_relief(nil, 0)
        }
        // 启用空闲样式化模式
        view.setGeneralProperty(SCI_SETIDLESTYLING, value: Int(SC_IDLESTYLING_TOVISIBLE))

        lastHighlightedRange = (0, 0)
        codeHighligh(view)
    }

    func setupTheme(_ view: some CodeView) {
        for (offset, syntax) in view.syntaxTheme {
            let style = offset + styleLastPredefined
            view.setColorProperty(SCI_STYLESETFORE, parameter: style, fromHTML: syntax.value.color)
        }
    }

    /// 处理Scintilla通知事件
    /// - Parameters:
    ///   - view: 代码视图实例
    ///   - notification: Scintilla通知结构体指针
    func notification(_ view: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?) {
        guard isCompatible else {
            return
        }
        guard let notification else { return }
        let scNotification = notification.pointee
        let code = Int32(scNotification.nmhdr.code)
        switch code {
        case SCN_MODIFIED:
            let modificationType = scNotification.modificationType
            if (modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) != 0 {
                codeHighligh(view)
            }
        case SCN_UPDATEUI:
            let updated = scNotification.updated
            if (updated & (SC_UPDATE_V_SCROLL | SC_UPDATE_H_SCROLL | SC_UPDATE_CONTENT)) != 0 {
                #if DEBUG
                    print("绘制完成")
                #endif
                codeHighligh(view)
            }
        default:
            break
        }
    }

    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}

    /// 执行代码高亮
    /// - Parameter view: 代码视图实例
    private func codeHighligh(_ view: some CodeView) {
        let (startByte, endByte) = view.getVisibleByteRange
        guard startByte >= 0, endByte >= 0 else {
            return
        }

        // 避免重复高亮相同区域
        if lastHighlightedRange.start == startByte, lastHighlightedRange.end == endByte {
            return
        }
        lastHighlightedRange = (startByte, endByte)

        // 取消之前的高亮任务(防抖)
        currentHighlightTask?.cancel()

        // 在主线程一次性捕获 Scintilla / 主题相关状态，
        // 后台解析线程不直接访问 view 的 Scintilla 接口，避免数据竞争与跨线程调用。
        let code: String = view.text

        // 如果代码太长 跳过高亮处理
        guard endByte - startByte <= 0x8000 else {
            #if DEBUG
                print("❌", "代码太长 跳过高亮处理")
            #endif
            return
        }
        let syntaxTheme = view.syntaxTheme
        let stringCapture = syntaxTheme.first(where: { $1.key == "string" })
        let encoding = view.codePage.encoding
        let language = view.language

        // 创建新的高亮任务(tree-sitter 解析放在后台线程)
        let task = DispatchWorkItem { [weak self, weak view] in
            guard let self, let view else { return }
            queryCursor(
                view,
                code: code,
                startByte: startByte,
                endByte: endByte,
                encoding: encoding,
                language: language,
                syntaxTheme: syntaxTheme,
                stringCapture: stringCapture
            )
        }

        currentHighlightTask = task

        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.01, execute: task)
    }

    private func queryCursor(
        _ view: some CodeView,
        code: String,
        startByte: Int,
        endByte: Int,
        encoding: String.Encoding,
        language: CodeLanguage?,
        syntaxTheme: EnumeratedSequence<[String: Syntax]>,
        stringCapture: EnumeratedSequence<[String: Syntax]>.Element?
    ) {
        // 后台线程：仅做 tree-sitter 解析与样式区间计算，不触碰 Scintilla 接口
        var styledRanges: [(start: Int, end: Int, style: Int)] = []
        language?.highlights(code: code, startByte: startByte, endByte: endByte, encoding: encoding) { capture in
            let name = capture.name
            guard let index = syntaxTheme.first(where: { $1.key == name }) ?? stringCapture else {
                return
            }
            let style: Int = index.offset + self.styleLastPredefined
            let s = capture.startByte
            let e = capture.endByte
            guard e > s else { return }
            styledRanges.append((s, e, style))
        }

        // 回到主线程统一应用样式(Scintilla 接口只能在主线程调用)
        DispatchQueue.main.async { [weak view] in
            guard let view else { return }
            for range in styledRanges {
                view.setGeneralProperty(SCI_STARTSTYLING, value: range.start)
                view.setGeneralProperty(SCI_SETSTYLING, parameter: range.end - range.start, value: range.style)
            }
        }
    }
}
