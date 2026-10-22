// FoxTerm | TextSearch.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Scintilla
import SwiftUI

/// 扩展 CodeView，直接对接底层 ScintillaView 的原生 C++ 文本查找与替换接口
extension CodeView {
    /// 执行文本查找、高亮并自动跳转至匹配位置
    /// - Parameters:
    ///   - searchText: 需要查找的文本字符串
    ///   - matchCase: 是否区分字母大小写(默认 false：不区分)
    ///   - wholeWord: 是否全字匹配，即避免匹配到单词的一部分(默认 false：模糊匹配)
    ///   - backwards: 查找方向(true 表示向上/反向查找，false 表示向下/正向查找，默认 false)
    /// - Returns: Bool 类型，true 表示成功找到匹配项并跳转，false 表示未找到或搜索词为空
    @discardableResult // 标记允许调用方忽略该方法的返回值(编译器不报警告)
    func performSearch(
        _ searchText: String,
        matchCase: Bool = false,
        wholeWord: Bool = false,
        backwards: Bool = false
    ) -> Bool {
        // 安全防御：如果输入的搜索关键字为空，直接终止并返回失败
        guard !searchText.isEmpty else { return false }

        // 调用底层 Objective-C / C++ 封装方法：ScintillaView.findAndHighlightText(...)
        return findAndHighlightText(
            searchText,
            matchCase: matchCase, // 传递：是否区分大小写
            wholeWord: wholeWord, // 传递：是否全字匹配
            scrollTo: true, // 固定开启：找到匹配项后自动将编辑窗口滚动至对应行
            wrap: true, // 固定开启：查找到文档末尾后自动折返回顶部继续搜索
            backwards: backwards // 传递：正向还是反向搜索
        )
    }

    /// 执行文本查找与替换
    /// - Parameters:
    ///   - searchText: 需要被替换的目标文本
    ///   - newText: 用于替换的新文本
    ///   - matchCase: 是否区分字母大小写(默认 false)
    ///   - wholeWord: 是否全字匹配(默认 false)
    ///   - replaceAll: 是否全量替换(true 表示替换文档中所有匹配项，false 表示仅替换当前选中的或下一个匹配项，默认 false)
    /// - Returns: Int32 类型，返回实际成功替换的文本数量(0 表示未进行替换)
    @discardableResult // 允许忽略返回值
    func performReplace(
        _ searchText: String,
        replacement newText: String,
        matchCase: Bool = false,
        wholeWord: Bool = false,
        replaceAll: Bool = false
    ) -> Int32 {
        // 安全防御：如果搜索关键词为空，不执行替换，直接返回 0
        guard !searchText.isEmpty else { return 0 }

        // 调用底层 Objective-C / C++ 封装方法：ScintillaView.findAndReplaceText(...)
        return findAndReplaceText(
            searchText,
            byText: newText, // 替换目标的新字符串
            matchCase: matchCase, // 是否区分大小写
            wholeWord: wholeWord, // 是否全字匹配
            doAll: replaceAll // 是否全部替换(对应底层 doAll 标志位)
        )
    }
}
