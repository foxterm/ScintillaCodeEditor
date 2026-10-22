// FoxTerm | QueryCapture.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation
import TreeSitter

public struct QueryCapture: Identifiable {
    public let id = UUID()
    public let name: String
    let capture: TSQueryCapture
}

public extension QueryCapture {
    var startByte: Int {
        Int(ts_node_start_byte(capture.node))
    }

    var endByte: Int {
        Int(ts_node_end_byte(capture.node))
    }

    var startPoint: TSPoint {
        ts_node_start_point(capture.node)
    }

    var endPoint: TSPoint {
        ts_node_end_point(capture.node)
    }

    var error: Bool {
        ts_node_has_error(capture.node)
    }

    var type: String {
        guard let type = ts_node_type(capture.node) else {
            return ""
        }
        return .init(cString: type)
    }

    var highlight: (String, Int, Int, Int) {
        let start = startByte
        let end = endByte
        let length = end - start
        return (name, start, end, length)
    }
}

extension String.Encoding {
    var internalEncoding: TSInputEncoding {
        switch self {
        case .utf8:
            TSInputEncodingUTF8
        case .utf16LittleEndian:
            TSInputEncodingUTF16LE
        case .utf16BigEndian:
            TSInputEncodingUTF16BE
        default:
            TSInputEncodingUTF8
        }
    }
}
