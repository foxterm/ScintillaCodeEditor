// FoxTerm | CodeLanguage+C.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import TreeSitter
import TreeSitterBash
import TreeSitterDockerfile
import TreeSitterINI
import TreeSitterJSON
import TreeSitterMarkdown
import TreeSitterSSHConfig
import TreeSitterTOML
import TreeSitterXML
import TreeSitterYAML

public extension CodeLanguage {
    /// 获取对应语言的 TreeSitter 解析器
    var tsLanguage: OpaquePointer? {
        switch self {
        case .bash, .sh: tree_sitter_bash()
        case .ini: tree_sitter_ini()
        case .json: tree_sitter_json()
        case .markdown: tree_sitter_markdown()
        case .ssh_config: tree_sitter_ssh_config()
        case .toml: tree_sitter_toml()
        case .xml: tree_sitter_xml()
        case .yaml: tree_sitter_yaml()
        case .dockerfile: tree_sitter_dockerfile()
        case .plain_text: nil
        }
    }

    #if DEBUG
        /// 检查所有语言解析器的状态
        static func doctor() {
            autoreleasepool {
                for language in allCases {
                    guard let tsLanguage = language.tsLanguage else {
                        print("❌ 语言解析器缺失:", language.rawValue)
                        continue
                    }
                    let version = ts_language_version(tsLanguage)
                    let isCompatible = version >= TREE_SITTER_MIN_COMPATIBLE_LANGUAGE_VERSION &&
                        version <= TREE_SITTER_LANGUAGE_VERSION
                    ts_language_delete(tsLanguage)
                    if isCompatible {
                        print("✅ 语言解析器版本兼容:", language.rawValue, "版本:", version)
                    } else {
                        print("❌ 语言解析器版本不兼容:", language.rawValue, "版本:", version)
                    }
                }
            }
        }
    #endif
    var version: UInt32 {
        guard let tsLanguage else {
            return 0
        }
        defer {
            ts_language_delete(tsLanguage)
        }
        return ts_language_version(tsLanguage)
    }

    func doctor() -> Bool {
        let v = version
        let isCompatible = v >= TREE_SITTER_MIN_COMPATIBLE_LANGUAGE_VERSION &&
            v <= TREE_SITTER_LANGUAGE_VERSION
        #if DEBUG
            if isCompatible {
                print("✅ 语言解析器版本兼容:", rawValue, "版本:", v)
            } else {
                print("❌ 语言解析器版本不兼容:", rawValue, "版本:", v)
            }
        #endif
        return isCompatible
    }
}
