// FoxTerm | BarTopView.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

//
// import Hooks
// import SwiftUI
//
// struct BarTopView: View {
//    @Environment(\.file) var file
//    @Environment(\.workspaceURL) var workspaceURL
//    var body: some View {
//        //            let name = useMemo(.preserved(by: file)) {
//        //                file?.name ?? ""
//        //            }
//        //            let img = useMemo(.preserved(by: file)) {
//        //                file?.icon
//        //            }
//        if let file, let workspaceURL {
//            VStack(alignment: .center, spacing: 0) {
//                HStack {
//                    MenuPathView(file: file.url, root: workspaceURL)
//                    Spacer()
//                }
//            }.buttonStyle(.plain).lineLimit(1)
//                // .font(.caption)
//                .padding(.horizontal, 10)
//                .frame(height: 25)
//                // .textSelection(.enabled)
//                .background(.regularMaterial)
//                .overlay(alignment: .bottom) {
//                    Divider().overlay(.clear)
//                }
//        }
//    }
// }
//
// struct PathComponent: Identifiable {
//    let id = UUID()
//    let name: String
//    let url: URL
// }
