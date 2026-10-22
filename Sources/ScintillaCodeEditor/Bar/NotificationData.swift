// FoxTerm | NotificationData.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import Scintilla

class NotificationData: ObservableObject {
    @Published var type: NotificationType? = nil
    @Published var message: String? = nil
    @Published var location: NSPoint = .zero
    @Published var value: Float = .zero
    @Published var selectedCharacterCount: Int = 0

    func updateSelection(characterCount: Int) {
        selectedCharacterCount = characterCount
    }

    func update(type: NotificationType?, message: String?, location: NSPoint, value: Float) {
        self.type = type
        self.message = message
        self.location = location
        self.value = value
    }
}
