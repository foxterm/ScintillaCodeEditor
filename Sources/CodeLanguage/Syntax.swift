// FoxTerm | Syntax.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Darwin
import Extension
import Foundation
import Sync
import TreeSitter

public extension CodeLanguage {
    /// 线程安全的全局缓存池：复用耗资巨大的 TSQuery 对象
    private enum QueryCache {
        private static var cache: [CodeLanguage: OpaquePointer] = [:]
        private static let lock = Mutex()

        static func getQuery(for language: CodeLanguage) -> OpaquePointer? {
            lock.lock()
            defer { lock.unlock() }

            if let existingQuery = cache[language] {
                return existingQuery
            }

            // 首次使用时编译 Query，后续永久复用
            guard let url = language.resource,
                  let sourceData = try? Data(contentsOf: url),
                  let tsLanguage = language.tsLanguage
            else {
                return nil
            }

            var errorOffset: UInt32 = 0
            var queryError: TSQueryError = TSQueryErrorNone

            // 使用 Data 内存直接传递给 C，零额外 String 拷贝
            let query = sourceData.withUnsafeBytes { buffer in
                ts_query_new(
                    tsLanguage,
                    buffer.baseAddress?.assumingMemoryBound(to: Int8.self),
                    buffer.count.uint32,
                    &errorOffset,
                    &queryError
                )
            }

            if let query {
                cache[language] = query
            }
            return query
        }

        /// 提供给 App 在收到内存警告或关闭页面时清空缓存的方法
        static func purge() {
            lock.lock()
            defer { lock.unlock() }
            for (_, query) in cache {
                ts_query_delete(query)
            }
            cache.removeAll()
            // 强制 C malloc 向 macOS 归还物理内存
            MemoryManager.shared.purge()
        }
    }

    func highlights(code: String, startByte: Int = 0, endByte: Int = 0, encoding: String.Encoding, callback: @escaping (_ queryCapture: QueryCapture) -> Void) {
        autoreleasepool {
            processQueryMatches(code: code, startByte: startByte, endByte: endByte, encoding: encoding, callback: callback)
        }
    }

    func processQueryMatches(code: String, startByte: Int, endByte: Int, encoding: String.Encoding, callback: @escaping (_ queryCapture: QueryCapture) -> Void) {
        guard let tsLanguage else { return }

        // 1. 获取预编译并缓存好的 TSQuery，不要每次都新建！
        guard let query = QueryCache.getQuery(for: self) else { return }

        // 2. 创建并配置 Parser
        guard let parser = ts_parser_new() else { return }
        defer { ts_parser_delete(parser) }

        ts_parser_set_language(parser, tsLanguage)
        ts_parser_set_timeout_micros(parser, 500_000) // 500ms 超时限制

        // 3. 解析源码
        guard let tree = ts_parser_parse_string_encoding(
            parser,
            nil,
            code.bytesArray,
            code.utf8.count.uint32,
            encoding.internalEncoding
        ) else { return }
        defer { ts_tree_delete(tree) }

        // 4. 创建 Query Cursor 游标
        guard let cursor = ts_query_cursor_new() else { return }
        defer { ts_query_cursor_delete(cursor) }

        ts_query_cursor_set_timeout_micros(cursor, 500_000)

        if endByte > startByte {
            ts_query_cursor_set_byte_range(cursor, startByte.uint32, endByte.uint32)
        }

        let rootNode = ts_tree_root_node(tree)
        ts_query_cursor_exec(cursor, query, rootNode)

        // 5. C 名称字符串的本地临时缓存(避免在 while 循环里重复对相同的 Capture ID 生成 Swift String)
        var nameCache: [UInt32: String] = [:]

        var match = TSQueryMatch()
        while ts_query_cursor_next_match(cursor, &match) {
            for i in 0 ..< match.capture_count.int {
                let capture = match.captures[i]
                guard !ts_node_is_null(capture.node) else { continue }

                // 从本地缓存取 String，避免反复跨 C/Swift 拷贝字符串
                let name: String
                if let cachedName = nameCache[capture.index] {
                    name = cachedName
                } else {
                    var captureNameLength: UInt32 = 0
                    guard let captureNameCString = ts_query_capture_name_for_id(
                        query,
                        capture.index,
                        &captureNameLength
                    ) else { continue }

                    name = captureNameCString.string
                    nameCache[capture.index] = name
                }

                callback(.init(name: name, capture: capture))
            }
        }
    }

    /// 当 App 收到内存警告或切换回后台时手动调用
    static func clearMemoryCache() {
        QueryCache.purge()
    }
}
