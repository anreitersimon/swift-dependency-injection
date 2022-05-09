// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dependency-injection-cli",
    products: [
        .executable(
            name: "swift-dependency-injection",
            targets: ["swift-dependency-injection"]
        )
    ],
    dependencies: [
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
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.9.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.1"
        ),
    ],
    targets: [
        .executableTarget(
            name: "swift-dependency-injection",
            dependencies: [
                "DependencyInjectionKit",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
            ]
        ),
        .target(
            name: "SourceModel",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "DependencyModel",
            dependencies: [
                "SourceModel"
            ]
        ),
        .target(
            name: "TestHelpers",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Yams", package: "Yams"),

            ]
        ),
        .target(
            name: "CodeGeneration",
            dependencies: [
                "DependencyModel"
            ]
        ),
        .target(
            name: "DependencyInjectionKit",
            dependencies: [
                "DependencyModel",
                "CodeGeneration",
            ]
        ),
        .testTarget(
            name: "SourceModelTests",
            dependencies: [
                "SourceModel",
                "TestHelpers",
            ],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "DependencyModelTests",
            dependencies: [
                "DependencyModel",
                "TestHelpers",
            ],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "CodeGenerationTests",
            dependencies: [
                "CodeGeneration",
                "DependencyModel",
                "SourceModel",
                "TestHelpers",
            ],
            exclude: ["__Snapshots__"]
        ),
    ]
)
