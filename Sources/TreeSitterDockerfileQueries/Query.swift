// FoxTerm | Query.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation

public enum Query {
    public static var highlightsFileURL: URL {
        url(named: "highlights")
    }
}

private extension Query {
    static func url(named filename: String) -> URL {
        Bundle.module.url(forResource: filename, withExtension: "scm")!
    }
}
