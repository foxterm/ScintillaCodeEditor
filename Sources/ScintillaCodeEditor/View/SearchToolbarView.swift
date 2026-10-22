// FoxTerm | SearchToolbarView.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import AppKit
import SwiftUI

// MARK: - 完整的悬浮搜索框 UI

struct FloatingSearchView: View {
    @Binding var searchText: String
    @Binding var isPresented: Bool

    // 搜索选项参数
    @State private var matchCase: Bool = false
    @State private var wholeWord: Bool = false

    /// 触发底层的搜索回调闭包
    var onSearch: (_ text: String, _ matchCase: Bool, _ wholeWord: Bool, _ backwards: Bool) -> Void

    var body: some View {
        HStack(spacing: 6) {
            // 1. 原生输入框
//            NativeSearchField(text: $searchText) { isShiftPressed in
//                onSearch(searchText, matchCase, wholeWord, isShiftPressed)
//            }
            TextField("Search", text: $searchText)
                .frame(width: 170)
                .onChange(of: searchText) { newValue in
                    // 实时打字搜索高亮
                    onSearch(newValue, matchCase, wholeWord, false)
                }

            // 2. 匹配选项开关组 (大小写敏感 & 全字匹配)
            HStack(spacing: 2) {
                // 区分大小写 (Aa)
                Toggle(isOn: $matchCase) {
                    Text("Aa")
                        .font(.system(size: 11, design: .monospaced))
                }
                .toggleStyle(SearchOptionToggleStyle())
                .help("Match Case")
                .onChange(of: matchCase) { newValue in
                    onSearch(searchText, newValue, wholeWord, false)
                }

                // 全字匹配 (\b)
                Toggle(isOn: $wholeWord) {
                    Text("W")
                        .font(.system(size: 11, design: .monospaced))
                }
                .toggleStyle(SearchOptionToggleStyle())
                .help("Whole Word")
                .onChange(of: wholeWord) { newValue in
                    onSearch(searchText, matchCase, newValue, false)
                }
            }

            Divider()
                .frame(height: 14)

            // 3. 上下切换导航按钮
            HStack(spacing: 2) {
                // 上一个
                Button(action: {
                    onSearch(searchText, matchCase, wholeWord, true)
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
                .help(NSLocalizedString("Previous Match (Shift+Enter)", comment: ""))

                // 下一个
                Button(action: {
                    onSearch(searchText, matchCase, wholeWord, false)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.borderless)
                .help(NSLocalizedString("Next Match (Enter)", comment: ""))
            }

            Divider()
                .frame(height: 14)

            // 4. 关闭按钮
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 18, height: 18)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
        // 捕获 Esc 键自动关闭搜索框
        .onExitCommand {
            isPresented = false
        }
    }
}

// MARK: - 自定义选项按钮样式 (Aa 和 W 的高亮切换效果)

struct SearchOptionToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            configuration.label
                .frame(width: 20, height: 20)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(configuration.isOn ? Color.accentColor.opacity(0.25) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(configuration.isOn ? Color.accentColor : Color.clear, lineWidth: 1)
                )
                .foregroundColor(configuration.isOn ? .accentColor : .secondary)
        }
        .buttonStyle(.borderless)
    }
}
