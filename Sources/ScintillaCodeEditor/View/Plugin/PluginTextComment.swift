// FoxTerm | PluginTextComment.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import Scintilla

class PluginTextComment: PluginDelegate {
    func setup(_: some CodeView) {}

    func notification(_: some CodeView, _: UnsafeMutablePointer<SCNotification>?) {}

    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}
}
