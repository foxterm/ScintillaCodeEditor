// FoxTerm | ScintillaCodeEditor.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import SwiftUI

public struct ScintillaCodeEditor: View {
    @Binding var text: String

//    @CloudStorage("EditorFont") private var font: String = "VictorMono-SemiBold"
//    @CloudStorage("EditorFontSize") var fontSize: Int = 16
//    @CloudStorage("EditorLineNumberFontSize") var lineNumberFontSize: Int = 12
//    @CloudStorage("EditorInvisible") var invisible: Bool = false
//    @CloudStorage("EditorZoom") var zoom: Double = 0

    @State var selectedCharCount: Int = 0

    public init(text: Binding<String>) {
        _text = text
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            SwiftUICodeView(text: $text, selectedCharCount: $selectedCharCount)
                //            .safeAreaInset(edge: .top, spacing: 0) {
                //                BarTopView()
                //            }
                //            .safeAreaInset(edge: .bottom, spacing: 0) {
                //                BarBottomView()
                //            }
                .environment(\.isInvisible, false)
                .environment(\.count, text.count)
                .environment(\.selectedCharCount, selectedCharCount)

            //        .environment(\.font, font)
            //        .environment(\.fontSize, fontSize)
            //        .environment(\.zoom, zoom)
        }
        // .animation(.default, value: showSearch)
    }
}
