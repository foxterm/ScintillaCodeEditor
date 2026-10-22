// FoxTerm | Bundle.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Extension
import Foundation

public extension Themes {
    static func load(_ name: String = "one") -> Themes? {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json"), let data = try? Data(contentsOf: url) else {
            return nil
        }
        do {
            return try JSONDecoder().decode(Themes.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }

    static func load() -> [String] {
        guard let url = Bundle.module.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return []
        }
        return url.map { $0.lastPathComponent.removingSuffix(".json") }
    }
}

extension Themes: Equatable {
    public static func == (lhs: Themes, rhs: Themes) -> Bool {
        lhs.name == rhs.name
    }
}
