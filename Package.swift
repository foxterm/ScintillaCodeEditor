// swift-tools-version:5.10

import PackageDescription

// let Sparkle = true

let swiftSettings: [SwiftSetting] = []
let package = Package(
    name: "ScintillaCodeEditor",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "ScintillaCodeEditor", targets: ["ScintillaCodeEditor"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tree-sitter/tree-sitter.git", .upToNextMinor(from: "0.25.10")),
        .package(url: "https://github.com/ra1028/swiftui-hooks", branch: "main"),
        .package(url: "https://github.com/foxterm/Sync.git", branch: "main"),
        .package(url: "https://github.com/foxterm/Extension.git", branch: "main"),

    ],
    targets: [
        .target(
            name: "ScintillaCodeEditor",
            dependencies: [
                .target(name: "CodeLanguage"),
                .target(name: "Scintilla"),
                .target(name: "CodeEditorTheme"),
                .product(name: "Hooks", package: "swiftui-hooks"),
                .product(name: "Extension", package: "Extension"),
            ]
        ),
        .target(
            name: "CodeEditorTheme",
            dependencies: [
                .product(name: "Extension", package: "Extension"),
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "CodeLanguage",
            dependencies: [
                .product(name: "Extension", package: "Extension"),
                .product(name: "Sync", package: "Sync"),
                .product(name: "TreeSitter", package: "tree-sitter"),
                .target(name: "TreeSitterBash"),
                .target(name: "TreeSitterDockerfile"),
                .target(name: "TreeSitterINI"),
                .target(name: "TreeSitterJSON"),
                .target(name: "TreeSitterMarkdown"),
                .target(name: "TreeSitterSSHConfig"),
                .target(name: "TreeSitterTOML"),
                .target(name: "TreeSitterXML"),
                .target(name: "TreeSitterYAML"),
                .target(name: "TreeSitterBashQueries"),
                .target(name: "TreeSitterDockerfileQueries"),
                .target(name: "TreeSitterINIQueries"),
                .target(name: "TreeSitterJSONQueries"),
                .target(name: "TreeSitterMarkdownQueries"),
                .target(name: "TreeSitterSSHConfigQueries"),
                .target(name: "TreeSitterTOMLQueries"),
                .target(name: "TreeSitterXMLQueries"),
                .target(name: "TreeSitterYAMLQueries"),
            ],
            resources: [
                .process("Themes.xcassets"),
                .copy("Resources"),
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
                .process("Resources"),
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
        .target(name: "TreeSitterBash"),
        .target(name: "TreeSitterDockerfile"),
        .target(name: "TreeSitterINI"),
        .target(name: "TreeSitterJSON"),
        .target(name: "TreeSitterMarkdown"),
        .target(name: "TreeSitterSSHConfig"),
        .target(name: "TreeSitterTOML"),
        .target(name: "TreeSitterXML"),
        .target(name: "TreeSitterYAML"),
        .target(name: "TreeSitterBashQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterDockerfileQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterINIQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterJSONQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterMarkdownQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterSSHConfigQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterTOMLQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterXMLQueries",
                resources: [
                    .process("Resources"),
                ]),
        .target(name: "TreeSitterYAMLQueries",
                resources: [
                    .process("Resources"),
                ]),

    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx17
)
