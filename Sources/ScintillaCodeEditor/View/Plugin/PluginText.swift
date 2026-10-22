// FoxTerm | PluginText.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import Scintilla

/// 文本插件类，用于监听和处理编辑器文本变更事件
class PluginTextPlugin: PluginDelegate {
    private let parent: SwiftUICodeView

    /// 初始化方法
    /// - Parameter parent: 关联的Scintilla编辑器实例
    init(_ parent: SwiftUICodeView) {
        self.parent = parent
    }

    /// 插件设置方法
    /// - Parameter view: 代码视图实例
    func setup(_: some CodeView) {}

    /// 通知处理方法，处理Scintilla编辑器的各种通知事件
    /// - Parameters:
    ///   - view: 代码视图实例
    ///   - notification: Scintilla通知结构体指针
    func notification(_ view: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?) {
        guard let notification else { return }

        let scNotification = notification.pointee
        let code = Int32(scNotification.nmhdr.code)

        switch code {
        case SCN_MODIFIED:
            let modificationType = scNotification.modificationType
            if (modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) != 0 {
                parent.setText(view.text)
            }
        case SCN_UPDATEUI:
            if (scNotification.updated & SC_UPDATE_SELECTION) != 0 {
                // 获取选择的字符数量
                let selectionStart = view.getGeneralProperty(SCI_GETSELECTIONSTART, parameter: 0, extra: 0)
                let selectionEnd = view.getGeneralProperty(SCI_GETSELECTIONEND, parameter: 0, extra: 0)
                let selectedCharCount = abs(Int(selectionEnd - selectionStart))
                parent.setSelectedCharCount(selectedCharCount)
            }
        default:
            break
        }
    }

    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {
        // parent.setLocation(location)
    }

//    /// 处理文本修改事件
//    /// - Parameters:
//    ///   - view: 代码视图实例
//    ///   - scNotification: Scintilla通知结构体
//    private func handleModification(_ view: some CodeView, scNotification: SCNotification) {
//        let modificationType = scNotification.modificationType
//        if (modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) != 0 {
//            parent.setText(view.text)
//        }
//    }
}
