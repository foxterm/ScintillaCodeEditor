// FoxTerm | Plugin.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import Scintilla

/// 插件代理协议，定义插件的基本行为
protocol PluginDelegate: CodeDelegate {
    /// 插件初始化设置
    /// - Parameter view: 代码视图实例
    func setup(_ view: some CodeView)
//    func setupLanguage(_ view: some CodeView)
//    func setupTheme(_ view: some CodeView)
}

/// 代码事件委托协议，处理代码编辑器的通知事件
protocol CodeDelegate {
    /// 处理代码编辑器通知事件
    /// - Parameters:
    ///   - view: 代码视图实例
    ///   - notification: Scintilla通知结构体指针
    func notification(_ view: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?)
    func notify(_ view: some CodeView, _ type: NotificationType, message: String, location: NSPoint, value: Float)
}
