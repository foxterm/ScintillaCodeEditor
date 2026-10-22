// FoxTerm | Finder.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

#if os(macOS)
    import AppKit
    import Scintilla
    import SwiftUI

    // MARK: - 原生 Scintilla 查找 & 替换面板

    final class CustomFindReplaceBarView: NSVisualEffectView, NSTextFieldDelegate {
        weak var codeView: CodeView?

        // 控件定义
        let toggleReplaceButton = NSButton()
        let searchField = NSSearchField()
        let replaceField = NSTextField()

        // 区分大小写与全字匹配开关按钮
        private let caseSensitiveButton = NSButton()
        private let wholeWordButton = NSButton()

        // MARK: - 统一按钮创建工厂函数

        private static func createFindBarButton(title: String? = nil, imageName: String? = nil) -> NSButton {
            let button = NSButton()
            button.isBordered = false
            button.bezelStyle = .inline
            button.controlSize = .small

            if let title {
                button.title = title
                button.font = NSFont.systemFont(ofSize: 12)
            }

            if let imageName {
                let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
                button.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
                button.imagePosition = .imageOnly
            }

            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 20).isActive = true

            if imageName != nil {
                button.widthAnchor.constraint(equalToConstant: 20).isActive = true
            }

            return button
        }

        // MARK: - 属性声明

        private lazy var prevButton = Self.createFindBarButton(imageName: "chevron.up")
        private lazy var nextButton = Self.createFindBarButton(imageName: "chevron.down")
        private lazy var doneButton = Self.createFindBarButton(title: "Done".localized)

        private lazy var replaceButton = Self.createFindBarButton(title: "Replace".localized)
        private lazy var replaceAllButton = Self.createFindBarButton(title: "Replace All".localized)

        private var replaceRowStack: NSStackView!
        private var isReplaceExpanded: Bool = false

        override func resetCursorRects() {
            super.resetCursorRects()
            addCursorRect(bounds, cursor: .arrow)
        }

        /// 查找选项状态
        private var isCaseSensitive: Bool = false {
            didSet {
                caseSensitiveButton.state = isCaseSensitive ? .on : .off
                performSearch(backwards: false)
            }
        }

        private var isWholeWord: Bool = false {
            didSet {
                wholeWordButton.state = isWholeWord ? .on : .off
                performSearch(backwards: false)
            }
        }

        init(codeView: CodeView) {
            self.codeView = codeView
            super.init(frame: .zero)
            setupUI()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupUI() {
            translatesAutoresizingMaskIntoConstraints = false

            material = .popover
            blendingMode = .withinWindow
            state = .active
            wantsLayer = true
            layer?.cornerRadius = 10
            layer?.masksToBounds = true
            layer?.borderWidth = 0.5
            layer?.borderColor = NSColor.separatorColor.cgColor

            // 1. 折叠箭头
            toggleReplaceButton.bezelStyle = .disclosure
            toggleReplaceButton.title = ""
            toggleReplaceButton.target = self
            toggleReplaceButton.action = #selector(onToggleReplace)

            // 2. 搜索框 & 替换框
            setupTextField(searchField, placeholder: "Find".localized, action: #selector(onNext))
            setupTextField(replaceField, placeholder: "Replace with...".localized, action: #selector(onReplaceCurrent))

            // 3. 选项按钮 (区分大小写 Aa / 全字匹配 \b)
            setupOptionButton(caseSensitiveButton, title: "Aa", toolTip: "Match Case".localized, action: #selector(onToggleCaseSensitive))
            setupOptionButton(wholeWordButton, title: "\\b", toolTip: "Whole Word".localized, action: #selector(onToggleWholeWord))

            // 4. 其它功能按钮
            for btn in [prevButton, nextButton, doneButton, replaceButton, replaceAllButton] {
                btn.bezelStyle = .inline
                btn.isBordered = true
            }

            prevButton.target = self
            prevButton.action = #selector(onPrev)

            nextButton.target = self
            nextButton.action = #selector(onNext)

            doneButton.target = self
            doneButton.action = #selector(dismissBar)

            replaceButton.target = self
            replaceButton.action = #selector(onReplaceCurrent)

            replaceAllButton.target = self
            replaceAllButton.action = #selector(onReplaceAll)

            // Stack 布局
            let findRowStack = NSStackView(views: [
                toggleReplaceButton,
                searchField,
                caseSensitiveButton,
                wholeWordButton,
                prevButton,
                nextButton,
                doneButton,
            ])
            findRowStack.orientation = .horizontal
            findRowStack.spacing = 5
            findRowStack.alignment = .centerY

            replaceRowStack = NSStackView(views: [replaceField, replaceButton, replaceAllButton])
            replaceRowStack.orientation = .horizontal
            replaceRowStack.spacing = 6
            replaceRowStack.alignment = .centerY

            let mainStack = NSStackView(views: [findRowStack, replaceRowStack])
            mainStack.orientation = .vertical
            mainStack.spacing = 8
            mainStack.alignment = .leading
            mainStack.translatesAutoresizingMaskIntoConstraints = false

            addSubview(mainStack)

            NSLayoutConstraint.activate([
                mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

                searchField.widthAnchor.constraint(equalToConstant: 200),
                replaceField.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
                replaceField.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            ])

            updateReplaceRowState(animated: false)
        }

        private func setupTextField(_ tf: NSTextField, placeholder: String, action: Selector) {
            tf.placeholderString = placeholder
            tf.delegate = self
            tf.target = self
            tf.action = action
            tf.bezelStyle = .roundedBezel
            tf.font = NSFont.systemFont(ofSize: 12)
            tf.translatesAutoresizingMaskIntoConstraints = false
        }

        private func setupOptionButton(_ btn: NSButton, title: String, toolTip: String, action: Selector) {
            btn.setButtonType(.toggle)
            btn.bezelStyle = .inline
            btn.isBordered = true
            btn.title = title
            btn.toolTip = toolTip
            btn.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .bold)
            btn.target = self
            btn.action = action
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 26).isActive = true
        }

        @objc private func onToggleReplace() {
            isReplaceExpanded.toggle()
            updateReplaceRowState(animated: true)
        }

        @objc private func onToggleCaseSensitive() {
            isCaseSensitive.toggle()
        }

        @objc private func onToggleWholeWord() {
            isWholeWord.toggle()
        }

        private func updateReplaceRowState(animated: Bool) {
            toggleReplaceButton.state = isReplaceExpanded ? .on : .off
            toggleReplaceButton.isBordered = false
            toggleReplaceButton.bezelStyle = .inline
            toggleReplaceButton.imagePosition = .imageOnly

            let imageName = isReplaceExpanded ? "chevron.down.circle" : "chevron.right.circle"
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            toggleReplaceButton.image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
            toggleReplaceButton.contentTintColor = .secondaryLabelColor

            NSAnimationContext.runAnimationGroup { context in
                context.duration = animated ? 0.15 : 0
                self.replaceRowStack.isHidden = !self.isReplaceExpanded
                self.layoutSubtreeIfNeeded()
            }
        }

        func show(replace: Bool) {
            isReplaceExpanded = replace
            updateReplaceRowState(animated: false)
            isHidden = false

            window?.makeFirstResponder(replace ? replaceField : searchField)
            if !searchField.stringValue.isEmpty {
                performSearch(backwards: false)
            }
        }

        @objc func dismissBar() {
            isHidden = true
            window?.makeFirstResponder(codeView)
        }

        // MARK: - Delegate & 原生 Scintilla 动作对接

        func controlTextDidChange(_ obj: Notification) {
            if (obj.object as? NSTextField) == searchField {
                performSearch(backwards: false)
            }
        }

        @objc private func onNext() {
            performSearch(backwards: false)
        }

        @objc private func onPrev() {
            performSearch(backwards: true)
        }

        @objc private func onReplaceCurrent() {
            let query = searchField.stringValue
            let replacement = replaceField.stringValue
            guard !query.isEmpty else { return }

            codeView?.performReplace(
                query,
                replacement: replacement,
                matchCase: isCaseSensitive,
                wholeWord: isWholeWord,
                replaceAll: false
            )
        }

        @objc private func onReplaceAll() {
            let query = searchField.stringValue
            let replacement = replaceField.stringValue
            guard !query.isEmpty else { return }

            codeView?.performReplace(
                query,
                replacement: replacement,
                matchCase: isCaseSensitive,
                wholeWord: isWholeWord,
                replaceAll: true
            )
        }

        private func performSearch(backwards: Bool = false) {
            let query = searchField.stringValue
            guard !query.isEmpty else { return }

            codeView?.performSearch(
                query,
                matchCase: isCaseSensitive,
                wholeWord: isWholeWord,
                backwards: backwards
            )
        }
    }

    // MARK: - CodeView 挂载 & 快捷键响应

    extension CodeView {
        private static var findBarKey: UInt8 = 0

        var customFindBar: CustomFindReplaceBarView {
            if let bar = objc_getAssociatedObject(self, &Self.findBarKey) as? CustomFindReplaceBarView {
                return bar
            }
            let bar = CustomFindReplaceBarView(codeView: self)
            bar.isHidden = true

            addSubview(bar)

            NSLayoutConstraint.activate([
                bar.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                bar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ])

            objc_setAssociatedObject(self, &Self.findBarKey, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bar
        }

        func showNativeSearch(replace: Bool) {
            customFindBar.show(replace: replace)
        }

        override open func performKeyEquivalent(with event: NSEvent) -> Bool {
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            guard let key = event.charactersIgnoringModifiers?.lowercased() else {
                return super.performKeyEquivalent(with: event)
            }

            if key == "f" {
                if flags.contains([.command, .option]) {
                    showNativeSearch(replace: true)
                    return true
                }
                if flags.contains(.command) {
                    showNativeSearch(replace: false)
                    return true
                }
            } else if event.keyCode == 53, !customFindBar.isHidden { // ESC 快捷键关闭面板
                customFindBar.dismissBar()
                return true
            }

            return super.performKeyEquivalent(with: event)
        }
    }
#endif
