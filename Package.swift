// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let localCLITools =
    ProcessInfo.processInfo.environment["SWIFT_DEPENDENCY_INJECTION_LOCAL_CLI_TOOLS"] != nil

let package = Package(
    name: "swift-dependency-injection",
    products: [
        .plugin(
            name: "DependencyInjectionPlugin",
            targets: ["DependencyInjectionPlugin"]
        ),
        .library(
            name: "DependencyInjection",
            targets: ["DependencyInjection"]
        ),
    ],
    dependencies: [],
    targets: [
        .plugin(
            name: "DependencyInjectionPlugin",
            capability: .buildTool(),
            dependencies: [
                "swift-dependency-injection"
            ]
        ),
        .target(
            name: "DependencyInjection",
            dependencies: [],
            swiftSettings: [
                .define("swift_dependency_injection_exclude")
            ]
        ),
        .target(
            name: "Example",
            dependencies: [
                "ExampleCore"
            ],
            plugins: [
                .plugin(name: "DependencyInjectionPlugin")
            ]
        ),
        .target(
            name: "ExampleCore",
            dependencies: [
                "DependencyInjection"
            ],
            plugins: [
                .plugin(name: "DependencyInjectionPlugin")
            ]
        ),
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                "Example"
            ],
            plugins: [
                .plugin(name: "DependencyInjectionPlugin")
            ]
        ),
    ]
)

if localCLITools {

    package.dependencies += [
        .package(
            url: "https://github.com/anreitersimon/swift-package-utils",
            branch: "main"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            branch: "0.50600.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump",
            from: "0.3.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
    ]

    package.products += [
        .executable(
            name: "swift-dependency-injection",
            targets: ["swift-dependency-injection"]
        )
    ]

    package.targets += [
        .executableTarget(
            name: "swift-dependency-injection",
            dependencies: [
                "DependencyInjectionKit",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
            ],
            path: "Sources/CLI/swift-dependency-injection"
        ),
        .target(
            name: "SourceModel",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ],
            path: "Sources/CLI/SourceModel"
        ),
        .target(
            name: "DependencyModel",
            dependencies: [
                "SourceModel"
            ],
            path: "Sources/CLI/DependencyModel"
        ),
        .target(
            name: "DependencyAnalyzer",
            dependencies: [
                "DependencyModel"
            ],
            path: "Sources/CLI/DependencyAnalyzer"
        ),
        .target(
            name: "CodeGeneration",
            dependencies: [
                "DependencyModel"
            ],
            path: "Sources/CLI/CodeGeneration"
        ),
        .target(
            name: "DependencyInjectionKit",
            dependencies: [
                "DependencyAnalyzer",
                "DependencyModel",
                "CodeGeneration",
            ],
            path: "Sources/CLI/DependencyInjectionKit"
        ),
        .testTarget(
            name: "SourceModelTests",
            dependencies: [
                "SourceModel",
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ],
            path: "Tests/CLI/SourceModelTests",
            exclude: [
                "Fixtures"
            ]
        ),
        .testTarget(
            name: "DependencyAnalyzerTests",
            dependencies: [
                "DependencyAnalyzer",
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ],
            path: "Tests/CLI/DependencyAnalyzerTests"
        ),
        .testTarget(
            name: "CodeGenerationTests",
            dependencies: [
                "CodeGeneration",
                "DependencyAnalyzer",
                "SourceModel",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ],
            path: "Tests/CLI/CodeGenerationTests"
        ),
    ]
} else {
    print("\(#file): warning: Using Precompiled Plugin")
    package.targets.append(
        .binaryTarget(
            name: "swift-dependency-injection",
            path: "swift-dependency-injection.zip"
        )
    )
}
