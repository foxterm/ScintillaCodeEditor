// swift-tools-version:5.10

import PackageDescription

// let Sparkle = true

let swiftSettings: [SwiftSetting] = []
let package = Package(
    name: "ScintillaCodeEditor",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "ScintillaCodeEditor", targets: ["ScintillaCodeEditor"])
    ],
    dependencies: [
        .package(url: "https://github.com/tree-sitter/tree-sitter", .upToNextMinor(from: "0.20.9")),
        .package(url: "https://github.com/foxterm/swiftui-hooks.git", branch: "main"),
        .package(url: "https://github.com/foxterm/Sync.git", branch: "main"),
        .package(url: "https://github.com/foxterm/Extension.git", branch: "main"),
        .package(url: "https://github.com/foxterm/CodeLanguage.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "ScintillaCodeEditor",
            dependencies: [
                .target(name: "Scintilla"),
                .target(name: "CodeEditorTheme"),
                .product(name: "Hooks", package: "swiftui-hooks"),
                .product(name: "Extension", package: "Extension"),
                .product(name: "CodeLanguage", package: "CodeLanguage"),
            ]
        ),
        .target(
            name: "CodeEditorTheme",
            dependencies: [
                .product(name: "Extension", package: "Extension")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "Scintilla",
            exclude: [
                "SciTE.properties",
                "Scintilla.iface",
                "PositionCache.cxx.orig",
            ],
            resources: [
                .process("Resources")
            ],
            publicHeadersPath: "public_include",
            cxxSettings: [
                .headerSearchPath("public_include"),
                .headerSearchPath("include"),
                .headerSearchPath("src"),
                .headerSearchPath("cocoa"),
                .headerSearchPath("."),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedFramework("AppKit"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreText"),
            ]
        ),

    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx17
)
