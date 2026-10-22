// FoxTerm | BarView.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import Scintilla
import SwiftUI

class BarView: NSView {
    private var hostingView: NSHostingView<BarBottomView>?
    private let notificationData = NotificationData()
    override func viewWillDraw() {
        super.viewWillDraw()
        setupSwiftUIContent()
    }

    private func setupSwiftUIContent() {
        guard hostingView == nil else {
            return
        }
        let swiftUIView = BarBottomView(notificationData: notificationData)
        hostingView = NSHostingView(rootView: swiftUIView)

        guard let hostingView else {
            return
        }

        // 添加到视图层级
        addSubview(hostingView)

        // 设置约束填满整个 BarView
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // hostingView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    deinit {
        #if DEBUG
            print("♻️", "BarView")
        #endif
    }
}

extension BarView: InfoBarCommunicator {
    func setCallback(_ callback: (any InfoBarCommunicator)!) {
        guard let view = callback as? CodeView else {
            return
        }
        view.addPlugin(self)
    }

    func notify(_ type: NotificationType, message: String!, location: NSPoint, value: Float) {
        notificationData.update(type: type, message: message, location: location, value: value)
        //   super.notify(type, message: message, location: location, value: value)
    }
}

extension BarView: PluginDelegate {
    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}

    func setup(_: some CodeView) {}

    func setupLanguage(_: some CodeView) {}

    func setupTheme(_: some CodeView) {}

    func notification(_ view: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?) {
        guard let notification else { return }
        let scNotification = notification.pointee
        let code = Int32(scNotification.nmhdr.code)
        guard code == SCN_UPDATEUI else { return }
        if (scNotification.updated & SC_UPDATE_SELECTION) != 0 {
            // 获取选择的字符数量
            let selectionStart = view.getGeneralProperty(SCI_GETSELECTIONSTART, parameter: 0, extra: 0)
            let selectionEnd = view.getGeneralProperty(SCI_GETSELECTIONEND, parameter: 0, extra: 0)
            let selectedCharCount = abs(Int(selectionEnd - selectionStart))
            notificationData.updateSelection(characterCount: selectedCharCount)
        }
    }
}
