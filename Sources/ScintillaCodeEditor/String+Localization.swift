// FoxTerm | String+Localization.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import SwiftUI

public extension String {
    var localized: String {
        NSLocalizedString(self, tableName: "Localizable", bundle: .main, comment: "")
    }

    func localizedWithFormat(arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    var localizedStringKey: LocalizedStringKey {
        LocalizedStringKey(self)
    }
}

public extension String {
    var bool: Bool {
        let selfLowercased = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch selfLowercased {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }
}
