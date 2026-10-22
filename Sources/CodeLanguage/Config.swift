// FoxTerm | Config.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import TreeSitterBashQueries
import TreeSitterDockerfileQueries
import TreeSitterINIQueries
import TreeSitterJSONQueries
import TreeSitterMarkdownQueries
import TreeSitterSSHConfigQueries
import TreeSitterTOMLQueries
import TreeSitterXMLQueries
import TreeSitterYAMLQueries

public extension CodeLanguage {
    var resource: URL? {
        switch self {
        case .bash, .sh: TreeSitterBashQueries.Query.highlightsFileURL
        case .dockerfile: TreeSitterDockerfileQueries.Query.highlightsFileURL
        case .ini: TreeSitterINIQueries.Query.highlightsFileURL
        case .json: TreeSitterJSONQueries.Query.highlightsFileURL
        case .markdown: TreeSitterMarkdownQueries.Query.highlightsFileURL
        case .ssh_config: TreeSitterSSHConfigQueries.Query.highlightsFileURL
        case .toml: TreeSitterTOMLQueries.Query.highlightsFileURL
        case .yaml: TreeSitterYAMLQueries.Query.highlightsFileURL
        case .xml: TreeSitterXMLQueries.Query.highlightsFileURL
        case .plain_text: nil
        }
    }

    /// 完整的文件名及后缀映射字典(全部统一为小写)
    static let extensionMap: [String: CodeLanguage] = [
        // MARK: - 特殊文件名 & 无后缀配置文件

        "makefile": .bash,
        "pom.xml": .xml,

        ".bashrc": .bash,
        ".bash_profile": .bash,
        ".zshrc": .bash,
        ".zprofile": .bash,
        ".profile": .bash,
        ".bash_aliases": .bash,

        ".gitignore": .ini,
        ".gitattributes": .ini,
        ".editorconfig": .ini,
        ".npmrc": .ini,
        ".env": .ini,
        ".env.local": .ini,
        ".env.development": .ini,
        ".env.production": .ini,

        // MARK: - SSH Configs

        "ssh_config": .ssh_config,
        "sshd_config": .ssh_config,
        "ssh_config.d": .ssh_config,
        "sshd_config.d": .ssh_config,
        "known_hosts": .ssh_config,
        "authorized_keys": .ssh_config,
        "sshconfig": .ssh_config,

        // MARK: - Shell / Bash

        "sh": .bash,
        "bash": .bash,
        "zsh": .bash,
        "ksh": .bash,
        "ash": .bash,
        "ebuild": .bash,
        "eclass": .bash,

        // MARK: - Dockerfile

        "dockerfile": .dockerfile,
        "containerfile": .dockerfile,

        // MARK: - INI / Config

        "ini": .ini,
        "cfg": .ini,
        "conf": .ini,
        "config": .ini,
        "inf": .ini,
        "properties": .ini,
        "directory": .ini,

        // MARK: - JSON

        "json": .json,
        "geojson": .json,
        "topojson": .json,
        "jsonld": .json,

        // MARK: - Markdown

        "md": .markdown,
        "markdown": .markdown,
        "mdown": .markdown,
        "mkd": .markdown,
        "mkdn": .markdown,
        "mdwn": .markdown,
        "mdtext": .markdown,

        // MARK: - TOML

        "toml": .toml,

        // MARK: - XML

        "xml": .xml,
        "plist": .xml,
        "svg": .xml,
        "xsd": .xml,
        "xsl": .xml,
        "xslt": .xml,
        "wsdl": .xml,
        "xliff": .xml,
        "storyboard": .xml,
        "xib": .xml,
        "drawio": .xml,
        "rss": .xml,

        // MARK: - YAML

        "yaml": .yaml,
        "yml": .yaml,
    ]

    /// 每种语言支持的所有常见文件后缀
    var pathExtensions: [String] {
        Self.extensionMap.compactMap { key, value in
            value == self ? key : nil
        }
    }

    /// 仅通过文件名/路径解析语言
    static func from(fileName fileNameOrPath: String) -> CodeLanguage {
        let path = fileNameOrPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else { return .plain_text }

        let nsPath = path as NSString
        let lastPathComponent = nsPath.lastPathComponent.lowercased()
        let pathExtension = nsPath.pathExtension.lowercased()

        // 1. 优先校验全名匹配
        if let lang = extensionMap[lastPathComponent] {
            return lang
        }

        // 2. 校验文件后缀
        if !pathExtension.isEmpty, let lang = extensionMap[pathExtension] {
            return lang
        }

        // 3. 容错纯后缀文本(如 "xml")
        let cleanExtension = path.trimmingCharacters(in: CharacterSet(charactersIn: ".")).lowercased()
        if let lang = extensionMap[cleanExtension] {
            return lang
        }

        return .plain_text
    }

    /// 单行/首行特征智能识别
    static func from(firstLine contentFirstLine: String) -> CodeLanguage {
        let line = contentFirstLine.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty else { return .plain_text }

        let lower = line.lowercased()

        // 1. OpenWrt UCI 配置识别 (归类为 .bash 点亮高亮)
        if line.hasPrefix("config ") {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            if parts.count >= 2 {
                return .bash
            }
        }

        // 2. Shebang (#!/...) 脚本识别
        if line.hasPrefix("#!") {
            if lower.contains("bash") || lower.contains("sh") || lower.contains("zsh") {
                return .bash
            }
        }

        // 3. Dockerfile 语法识别 (# syntax= 或 FROM)
        if lower.hasPrefix("# syntax=") || lower.hasPrefix("from ") {
            return .dockerfile
        }

        // 4. XML 头部声明识别
        if lower.hasPrefix("<?xml") {
            return .xml
        }

        // 5. Markdown
        if line.hasPrefix("# ") || line.hasPrefix("## ") || line.hasPrefix("### ") {
            return .markdown
        }

        // 6. YAML (文档起始符)
        if line == "---" {
            return .yaml
        }

        // 7. JSON (数组或对象开头)
        if line.hasPrefix("{") || line.hasPrefix("[") {
            return .json
        }

        return .plain_text
    }

    /// 完整的段落内容智能扫描
    static func from(content: String?) -> CodeLanguage {
        guard let content, !content.isEmpty else { return .plain_text }

        let lines = content.components(separatedBy: .newlines)

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)

            // 跳过空行
            if line.isEmpty {
                continue
            }

            let lower = line.lowercased()

            // 特殊优先行检测：Shebang 或 Dockerfile 语法行
            if line.hasPrefix("#!") || lower.hasPrefix("# syntax=") {
                let detected = from(firstLine: line)
                if detected != .plain_text {
                    return detected
                }
            }

            // 跳过普通注释行继续向下查找有效代码
            if line.hasPrefix("#") || line.hasPrefix("//") || line.hasPrefix("/*") {
                continue
            }

            // 匹配找到的第一行有效代码
            return from(firstLine: line)
        }

        return .plain_text
    }

    /// 综合判断主函数：同时接收文件名与文件内容(内容可为空)
    static func from(name fileNameOrPath: String, content: String?) -> CodeLanguage {
        // 1. 优先尝试文件名/扩展名检测
        let langFromFilename = from(fileName: fileNameOrPath)
        if langFromFilename != .plain_text {
            return langFromFilename
        }

        // 2. 文件名匹配失败时，尝试通过内容识别
        return from(content: content)
    }
}
