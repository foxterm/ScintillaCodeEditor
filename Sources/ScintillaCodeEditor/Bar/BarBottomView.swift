// FoxTerm | BarBottomView.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Hooks
import Scintilla
import SwiftUI

struct BarBottomView: View {
    @ObservedObject var notificationData: NotificationData

//    @Environment(\.codePage) var codePage
//    @Environment(\.lineEndingMode) var lineEndingMode

    ///    @Environment(\.file) var file
    @Environment(\.count) var count
    /// @Environment(\.location) var location
    @Environment(\.selectedCharCount) var selectedCharCount

    /// @Environment(\.language) var language
    var body: some View {
        HookScope {
            let x = useMemo(.preserved(by: notificationData.location.x)) {
                Int(notificationData.location.x) + 1
            }
            let y = useMemo(.preserved(by: notificationData.location.y)) {
                Int(notificationData.location.y) + 1
            }
            VStack(alignment: .center, spacing: 0) {
                HStack(spacing: 15) {
                    Spacer()
                    //                    Text(codePage.encoding.description)
                    //                    Text(lineEndingMode.description)
                    // Text(language.name)
                    Text("Line: %d".localizedWithFormat(arguments: y))
                    Text("Col: %d".localizedWithFormat(arguments: x))
                    //
                    if selectedCharCount > 0 {
                        Text("Selected %d Characters".localizedWithFormat(arguments: selectedCharCount))
                    } else {
                        Text("%d Characters".localizedWithFormat(arguments: count))
                    }
                }.padding(.vertical, 5)
            }.buttonStyle(.plain)
                .font(.caption)
                .padding(.horizontal)
                // .frame(height: 25)
                // .textSelection(.enabled)
                .background(.regularMaterial)
                .overlay(alignment: .top) {
                    Divider().overlay(.clear)
                }
        }
    }

//    func setLocation() {
//        guard location.x > 0 || location.y > 0, let file, let db = MMKV(mmapID: file.url.string) else {
//            return
//        }
//        db.set(location.x, forKey: "location.x")
//        db.set(location.y, forKey: "location.y")
//    }
}
