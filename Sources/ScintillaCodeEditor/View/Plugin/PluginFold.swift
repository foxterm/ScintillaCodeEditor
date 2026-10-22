// FoxTerm | PluginFold.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

//
// import CodeEditor
// import Foundation
//
// class PluginFold: PluginDelegate {
//    private var currentHighlightTask: DispatchWorkItem?
//    private var isCompatible = false
//    func setup(_ view: some CodeView) {
//        setupLanguage(view)
//        // setupFoldMarkers(view)
//    }
//
//    func setupLanguage(_ view: some CodeView) {
//        isCompatible = view.language?.doctor() ?? false
//        guard isCompatible else {
//            return
//        }
//        queryFold(view)
//    }
//
//    // 设置折叠标记样式
//    private func setupFoldMarkers(_ view: some CodeView) {
//        view.setLexerProperty("fold", value: "1")
//        view.setLexerProperty("fold.compact", value: "1")
//        // 定义折叠标记的样式
//
//        // 设置折叠边距
//        // view.setGeneralProperty(SCI_SETMARGINWIDTHN, parameter: Int(SC_MARGIN_TREE), value: 16)
//        //  view.setGeneralProperty(SCI_SETMARGINMASKN, parameter: Int(SC_MARGIN_TREE), value: Int(SC_MASK_FOLDERS))
//        //  view.setGeneralProperty(SCI_SETMARGINSENSITIVEN, parameter: Int(SC_MARGIN_TREE), value: 1)
//        guard let style = view.style else {
//            return
//        }
//        // 定义折叠标记的样式(包括连接线)
//        // 使用自定义字符作为折叠标记
//
//        // 设置折叠标记前景色和背景色
//
//        // 设置折叠边距
//        view.setGeneralProperty(SCI_SETMARGINWIDTHN, parameter: Int(SC_MARGIN_BACK), value: 16)
//        view.setGeneralProperty(SCI_SETMARGINMASKN, parameter: Int(SC_MARGIN_BACK), value: Int(SC_MASK_FOLDERS))
//        view.setGeneralProperty(SCI_SETMARGINSENSITIVEN, parameter: Int(SC_MARGIN_BACK), value: 1)
//
//        // 设置折叠区域背景色
//        view.setColorProperty(SCI_SETFOLDMARGINCOLOUR, parameter: Int(SC_MARGIN_BACK), fromHTML: style.editorSubheaderBackground)
//        view.setColorProperty(SCI_SETFOLDMARGINHICOLOUR, parameter: Int(SC_MARGIN_BACK), fromHTML: style.editorHighlightedLineBackground)
//
//        // 启用自动折叠
//        // view.setGeneralProperty(SCI_SETAUTOMATICFOLD, value: Int(SC_AUTOMATICFOLD_SHOW | SC_AUTOMATICFOLD_CLICK | SC_AUTOMATICFOLD_CHANGE))
//    }
//
//    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}
//
//    func notification(_: some CodeView, _ notification: UnsafeMutablePointer<SCNotification>?) {
//        guard isCompatible else {
//            return
//        }
//        guard let notification else { return }
//        let scNotification = notification.pointee
//        let code = Int32(scNotification.nmhdr.code)
//        switch code {
//        case SCN_MODIFIED:
//            let modificationType = scNotification.modificationType
//            if (modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) != 0 {
//                //  queryFold(view)
//            }
////        case SCN_UPDATEUI:
////            let updated = scNotification.updated
////            if (updated & (SC_UPDATE_V_SCROLL | SC_UPDATE_H_SCROLL)) != 0 {
////                queryFold(view)
////            }
//        default:
//            break
//        }
//    }
//
//    /// 执行代码高亮
//    /// - Parameter view: 代码视图实例
//    private func queryFold(_ view: some CodeView) {
//        guard isCompatible else {
//            return
//        }
//        currentHighlightTask?.cancel()
//
//        let task = DispatchWorkItem { [weak self, weak view] in
//            guard let self, let view else { return }
//            self.queryCursor(view)
//        }
//
//        currentHighlightTask = task
//
//        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.02, execute: task)
//    }
//
//    private func queryCursor(_ view: some CodeView, startByte _: Int = 0, endByte _: Int = 0) {
//        view.language?.tags(code: view.text, encoding: view.codePage.encoding) { _ in
////            let start = capture.startPoint
////            let end = capture.endPoint
////            print(capture.type)
//        }
//    }
// }
