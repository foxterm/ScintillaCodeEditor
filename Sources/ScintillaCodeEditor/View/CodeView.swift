// FoxTerm | CodeView.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import CodeEditorTheme
import CodeLanguage
import Foundation
import Scintilla
import SwiftUI

class CodeView: ScintillaView {
    /// 行号跟随高亮使用的 marker 编号 (0-20 未被 Scintilla 预留占用)
    private static let currentLineMarker = 20

    var themes: Themes? {
        didSet {
            configureTheme()
            configurePlugin()
        }
    }

    var colorScheme: ColorScheme = .dark {
        didSet {
            configureTheme()
            configurePlugin()
        }
    }

    var language: CodeLanguage? {
        didSet {
            configurePlugin()
        }
    }

    var text: String {
        get {
            string()
        }
        set {
            setString(newValue)
            clearUndoHistory()
        }
    }

    /// 设置或获取换行符模式
    var lineEndingMode: EOLMode {
        get {
            EOLMode(rawValue: getGeneralProperty(SCI_GETEOLMODE)) ?? .lf
        }
        set {
            setGeneralProperty(SCI_SETEOLMODE, value: newValue.rawValue)
        }
    }

    var font: String = "" {
        didSet {
            configureTheme()
            configurePlugin()
        }
    }

    var zoom: Double = 0 {
        didSet {
            setGeneralProperty(SCI_SETZOOM, value: Int(zoom))
        }
    }

    var lineNumberFontSize: Int = 12 {
        didSet {
            setGeneralProperty(SCI_STYLESETSIZE, parameter: Int(STYLE_LINENUMBER), value: lineNumberFontSize)
            updateLineNumberMarginWidth()
        }
    }

    var fontSize: Int = 16 {
        didSet {
            setGeneralProperty(SCI_STYLESETSIZE, parameter: Int(STYLE_DEFAULT), value: fontSize)
        }
    }

    ///    var isEditable: Bool {
    ///        get {
    ///            isEditable()
    ///        }
    ///        set {
    ///            setEditable(newValue)
    ///        }
    ///    }
    var isDocumentEditable: Bool {
        get {
            isEditable()
        }
        set {
            setEditable(newValue)
        }
    }

    var codePage: CodePage {
        get {
            CodePage(rawValue: getGeneralProperty(SCI_GETCODEPAGE)) ?? .utf8
        }
        set {
            setGeneralProperty(SCI_SETCODEPAGE, value: newValue.rawValue)
        }
    }

    var isInvisible: Bool {
        get {
            getGeneralProperty(SCI_GETVIEWWS) != 0
        }
        set {
            setGeneralProperty(SCI_SETVIEWWS, value: newValue ? 1 : 0)
            if let style {
                setColorProperty(SCI_SETWHITESPACEFORE, parameter: 1, fromHTML: style.editorInvisible)
                setColorProperty(SCI_SETWHITESPACEBACK, parameter: 1, fromHTML: style.editorBackground)
            }
        }
    }

    var location: NSPoint = .init(x: 0, y: 0) {
        didSet {
            let line = Int(location.y)
            let column = Int(location.x)
            let position = getGeneralProperty(SCI_FINDCOLUMN, parameter: line, extra: column)
            setGeneralProperty(SCI_GOTOPOS, value: position)
            setGeneralProperty(SCI_SCROLLCARET, value: 0)
        }
    }

//    init() {
//        super.init(frame: .zero)
//    }

//    @available(*, unavailable)
//    required init?(coder _: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    var plugins: [PluginDelegate] = []

    func setup() {
        setGeneralProperty(SC_SUPPORTS_THREAD_SAFE_MEASURE_WIDTHS, value: 1)
        suspendDrawing(true)
        defer {
            suspendDrawing(false)
        }
        configure()
        configureScrollbars()
        configureTheme()
        configurePlugin()
        updateLineNumberHighlight()
        // setupTextFinder()
    }

    private func configurePlugin() {
        for plugin in plugins {
            plugin.setup(self)
        }
    }

    func addPlugin(_ plugin: PluginDelegate) {
        plugins.append(plugin)
    }

    var theme: Theme? {
        guard let themes else {
            return nil
        }
        return colorScheme == .dark ? themes.themes.first(where: { $0.appearance == "dark" }) : themes.themes.first(where: { $0.appearance == "light" })
    }

    var style: Style? {
        guard let theme else {
            return nil
        }
        return theme.style
    }

    var syntaxTheme: EnumeratedSequence<[String: Syntax]> {
        guard let style else {
            return [:].enumerated()
        }
        return style.syntax.enumerated()
    }

    var players: Players? {
        guard let style else {
            return nil
        }
        return style.players.first
    }

    func configure() {
        setGeneralProperty(SCI_SETENDATLASTLINE, parameter: 0, value: 0)
        // 确保启用缓冲绘制
        setGeneralProperty(SCI_SETBUFFEREDDRAW, value: 1)
        // 限制不必要的更新通知
//        setGeneralProperty(SCI_SETCOMMANDEVENTS, parameter: 0, value: 0) // 禁用命令事件
//        setGeneralProperty(SCI_SETMODEVENTMASK, parameter: Int(SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT), value: 0) // 只监听必要的修改事件
        // 禁用水平滚动条以提高性能
        setGeneralProperty(SCI_SETHSCROLLBAR, parameter: 0, value: 0)

        // 启用换行以避免水平滚动
        setGeneralProperty(SCI_SETWRAPMODE, value: Int(SC_WRAP_WORD))

        // 优化换行性能
        setGeneralProperty(SCI_SETWRAPINDENTMODE, value: Int(SC_WRAPINDENT_FIXED))

        // 设置合适的滚动宽度
        setGeneralProperty(SCI_SETSCROLLWIDTH, value: 1000)
        setGeneralProperty(SCI_SETSCROLLWIDTHTRACKING, value: 1)

        // 设置词法分析器性能选项
        setLexerProperty("lexer.cpp.track.preprocessor", value: "0") // 减少预处理器跟踪
        setLexerProperty("lexer.cpp.update.preprocessor", value: "0") // 减少预处理器更新
    }

    func updateLineNumberMarginWidth() {
        let lineCount = getGeneralProperty(SCI_GETLINECOUNT)
        let digits = max(2, String(lineCount).count)

        // 根据字体大小动态计算合适的行号宽度，留足 Padding
        let fontWidth = lineNumberFontSize > 0 ? lineNumberFontSize : 12
        let width = digits * (fontWidth / 2 + 3) + 16

        // 参数 0 代表第一个 Margin 区域(即行号区)
        setGeneralProperty(SCI_SETMARGINWIDTHN, parameter: 0, value: width)
    }

    /// 应用主题与基础编辑配置
    func configureTheme() {
        guard let style else {
            return
        }
        configureDefaultStyle(style)
        configureLineNumbers(style)
        configureCaretAndSelection(style)
        configureFolding()
        setGeneralProperty(SCI_SETTABWIDTH, value: 4)
    }

    /// 默认文本样式
    private func configureDefaultStyle(_ style: Style) {
        setColorProperty(SCI_STYLESETBACK, parameter: Int(STYLE_DEFAULT), fromHTML: style.editorBackground)
        setColorProperty(SCI_STYLESETFORE, parameter: Int(STYLE_DEFAULT), fromHTML: style.editorForeground)
        if !font.isEmpty {
            setStringProperty(SCI_STYLESETFONT, parameter: Int(STYLE_DEFAULT), value: font)
        }
        setGeneralProperty(SCI_STYLESETSIZE, parameter: Int(STYLE_DEFAULT), value: fontSize)

        setColorProperty(SCI_SETWHITESPACEFORE, parameter: 1, fromHTML: style.editorInvisible)
        setColorProperty(SCI_SETWHITESPACEBACK, parameter: 1, fromHTML: style.editorBackground)
        setGeneralProperty(SCI_STYLECLEARALL, value: 0)
    }

    /// 行号边距与当前行/选区行高亮跟随
    private func configureLineNumbers(_ style: Style) {
        // 行号数字边距
        setGeneralProperty(SCI_SETMARGINTYPEN, parameter: 0, value: Int(SC_MARGIN_NUMBER))
        updateLineNumberMarginWidth()
        setColorProperty(SCI_STYLESETFORE, parameter: Int(STYLE_LINENUMBER), fromHTML: style.editorLineNumber)
        setColorProperty(SCI_STYLESETBACK, parameter: Int(STYLE_LINENUMBER), fromHTML: style.editorGutterBackground)
        setGeneralProperty(SCI_STYLESETSIZE, parameter: Int(STYLE_LINENUMBER), value: lineNumberFontSize)
        if !font.isEmpty {
            setStringProperty(SCI_STYLESETFONT, parameter: Int(STYLE_LINENUMBER), value: font)
        }

        // 行号右侧高亮条边距：以 marker 背景标记当前行/选区行，颜色与文本当前行高亮一致
        setGeneralProperty(SCI_SETMARGINTYPEN, parameter: 1, value: Int(SC_MARGIN_BACK))
        setGeneralProperty(SCI_SETMARGINWIDTHN, parameter: 1, value: 6)
        setGeneralProperty(SCI_SETMARGINMASKN, parameter: 1, value: 1 << Self.currentLineMarker)
        setGeneralProperty(SCI_MARKERDEFINE, parameter: Self.currentLineMarker, value: Int(SC_MARK_BACKGROUND))
        setGeneralProperty(SCI_MARKERSETBACK, parameter: Self.currentLineMarker, value: getColor(style.editorActiveLineBackground))
    }

    /// 光标与选区样式
    private func configureCaretAndSelection(_ style: Style) {
        // 当前行文本高亮
        setGeneralProperty(SCI_SETCARETLINEVISIBLE, value: 1)
        setGeneralProperty(SCI_SETCARETLINEBACK, value: getColor(style.editorActiveLineBackground))

        setGeneralProperty(SCI_SETCARETWIDTH, value: 2)
        if let players {
            setGeneralProperty(SCI_SETCARETFORE, value: getColor(players.cursor))
            setGeneralProperty(SCI_SETSELBACK, parameter: 1, value: getColor(players.selection))
            setGeneralProperty(SCI_SETSELALPHA, value: 100)
        }
    }

    /// 禁用折叠相关边距与词法折叠
    private func configureFolding() {
        setGeneralProperty(SCI_SETMARGINWIDTHN, parameter: 2, value: 0)
        setGeneralProperty(SCI_SETMARGINMASKN, parameter: 2, value: 0)
        setGeneralProperty(SCI_SETMARGINSENSITIVEN, parameter: 2, value: 0)
        setLexerProperty("fold", value: "0")
    }

    /// 更新行号跟随高亮：标记当前行（或选区涉及的所有行）
    func updateLineNumberHighlight() {
        setGeneralProperty(SCI_MARKERDELETEALL, parameter: Self.currentLineMarker, value: 0)

        let currentPos = Int(getGeneralProperty(SCI_GETCURRENTPOS, parameter: 0, extra: 0))
        let anchorPos = Int(getGeneralProperty(SCI_GETANCHOR, parameter: 0, extra: 0))
        let currentLine = Int(getGeneralProperty(SCI_LINEFROMPOSITION, parameter: currentPos, extra: 0))
        let anchorLine = Int(getGeneralProperty(SCI_LINEFROMPOSITION, parameter: anchorPos, extra: 0))

        for line in min(currentLine, anchorLine) ... max(currentLine, anchorLine) {
            setGeneralProperty(SCI_MARKERADD, parameter: line, value: Self.currentLineMarker)
        }
    }

//    // 在 CodeView 中添加测试方法
//    func testFold() {
//        let lineCount = getGeneralProperty(SCI_GETLINECOUNT, parameter: 0, extra: 0)
//        if lineCount > 2 {
//            // 将第1行设置为可折叠头部
//            var level = Int(SC_FOLDLEVELBASE)
//            level |= Int(SC_FOLDLEVELHEADERFLAG)
//            setGeneralProperty(SCI_SETFOLDLEVEL, parameter: 0, value: level)
//
//            // 设置折叠级别
//            setGeneralProperty(SCI_SETFOLDLEVEL, parameter: 1, value: Int(SC_FOLDLEVELBASE))
//            setGeneralProperty(SCI_SETFOLDEXPANDED, parameter: 0, value: 0) // 折叠
//        }
//    }
//    func notificationTheme() {
//        for plugin in plugins {
//            plugin.setupTheme(self)
//        }
//    }
//
//    func notificationLanguage() {
//        for plugin in plugins {
//            plugin.setupLanguage(self)
//        }
//    }
//
//    func configureLanguage() {
//        notificationLanguage()
//    }

    func configureScrollbars() {
        scrollView.scrollerStyle = .overlay
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]

        // 确保 ScrollView 也是不透明的，防止底色穿透导致的残影
        scrollView.drawsBackground = true
    }

    func runMan(_ callback: @escaping () -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            callback()
            semaphore.signal()
        }
        semaphore.wait()
    }

    private var _hasFocus = false
    open var hasFocus: Bool {
        get {
            _hasFocus && (window?.isKeyWindow ?? false)
        }
        set {
            _hasFocus = newValue
            if newValue {
                becomeFirstResponder()
                window?.makeFirstResponder(self)
                setGeneralProperty(SCI_SETFOCUS, value: 1)
            } else {
                resignFirstResponder()
                setGeneralProperty(SCI_SETFOCUS, value: 0)
            }
        }
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    deinit {
        // 注意：不能在此调用 CodeLanguage.clearMemoryCache()。
        // QueryCache 是跨所有 CodeView 实例共享的全局缓存；
        // 单个编辑器关闭时清空会让其它仍在运行的高亮后台任务持有的
        // TSQuery 指针变成悬垂指针(use-after-free)，且会让其它编辑器被迫重编译。
        #if DEBUG
            print("♻️", "CodeView")
        #endif
    }
}

extension CodeView {
    override func notification(_ notification: UnsafeMutablePointer<SCNotification>!) {
        super.notification(notification)
        let scNotification = notification.pointee
        let code = Int32(scNotification.nmhdr.code)
        if code == SCN_MODIFIED {
            let modificationType = scNotification.modificationType
            if (modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) != 0 {
                updateLineNumberMarginWidth()
            }
        }
        if code == SCN_UPDATEUI, (scNotification.updated & SC_UPDATE_SELECTION) != 0 {
            updateLineNumberHighlight()
        }

        for plugin in plugins {
            autoreleasepool {
                plugin.notification(self, notification)
            }
        }
    }

    override func notify(_ type: NotificationType, message: String, location: NSPoint, value: Float) {
        for plugin in plugins {
            autoreleasepool {
                plugin.notify(self, type, message: message, location: location, value: value)
            }
        }
    }
}

extension CodeView {
    /// 获取总行数
    var totalLines: Int {
        Int(getGeneralProperty(SCI_GETLINECOUNT, parameter: 0, extra: 0))
    }

    /// 获取当前可视区域的第一行
    var getFirstVisibleLine: Int {
        Int(getGeneralProperty(SCI_GETFIRSTVISIBLELINE, parameter: 0, extra: 0))
    }

    /// 获取每页显示的行数
    var getLinesOnScreen: Int {
        Int(getGeneralProperty(SCI_LINESONSCREEN, parameter: 0, extra: 0))
    }

    /// 获取当前可视区域的最后一行
    var getLastVisibleLine: Int {
        let firstVisibleLine = getFirstVisibleLine
        let linesOnScreen = getLinesOnScreen
        // 计算最后一行，并增加5行的缓冲
        let lastVisibleLine = firstVisibleLine + linesOnScreen - 1 + 5

        // 确保不超过文档总行数
        return min(lastVisibleLine, totalLines - 1)
    }

    /// 获取指定行的第一个字符位置
    func getLineStartPosition(line: Int) -> Int {
        Int(getGeneralProperty(SCI_POSITIONFROMLINE, parameter: line, extra: 0))
    }

    /// 获取指定行的结束字符位置
    func getLineEndPosition(line: Int) -> Int {
        Int(getGeneralProperty(SCI_GETLINEENDPOSITION, parameter: line, extra: 0))
    }

    /// 获取当前可视区域的第一行的起始字节位置
    var getVisibleStartByte: Int {
        let firstVisibleLine = getFirstVisibleLine
        return getLineStartPosition(line: firstVisibleLine)
    }

    /// 获取当前可视区域的最后一行的结束字节位置
    var getVisibleEndByte: Int {
        let lastVisibleLine = getLastVisibleLine
        return getLineEndPosition(line: lastVisibleLine)
    }

    /// 获取当前可视区域的字节范围(startByte, endByte)
    var getVisibleByteRange: (startByte: Int, endByte: Int) {
        (startByte: getVisibleStartByte, endByte: getVisibleEndByte)
    }
}

extension CodeView {
    /// 清除撤销/重做历史，并设置当前点为保存节点
    /// 用于初始化文本加载后，防止 Cmd+Z 撤销回空白文本
    func clearUndoHistory() {
        setGeneralProperty(SCI_EMPTYUNDOBUFFER, value: 1)
        setGeneralProperty(SCI_SETSAVEPOINT, value: 1)
    }
}
