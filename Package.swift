// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dagger",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .plugin(
            name: "SwiftDaggerPlugin",
            targets: ["SwiftDaggerPlugin"]
        ),
        .executable(
            name: "swift-dagger",
            targets: ["swift-dagger"]
        ),
        .executable(
            name: "ExampleApp",
            targets: ["ExampleApp"]
        ),
        .library(
            name: "SwiftDagger",
            targets: ["SwiftDagger"]
        ),
        .library(
            name: "SwiftDaggerKit",
            targets: ["SwiftDaggerKit"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            revision: "0.50500.0"
        ),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),

        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "lib_InternalSwiftSyntaxParser",
            url:
                "https://github.com/keith/StaticInternalSwiftSyntaxParser/releases/download/5.5.2/lib_InternalSwiftSyntaxParser.xcframework.zip",
            checksum: "96bbc9ab4679953eac9ee46778b498cb559b8a7d9ecc658e54d6679acfbb34b8"
        ),

        .plugin(
            name: "SwiftDaggerPlugin",
            capability: .buildTool(),
            dependencies: [
                "swift-dagger"
            ]
        ),
        .executableTarget(
            name: "swift-dagger",
            dependencies: [
                "lib_InternalSwiftSyntaxParser",
                "SwiftDaggerKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "DependencyModel"),
        .target(
            name: "DependencyAnalyzer",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                "DependencyModel",
            ]
        ),
        .target(name: "CodeGeneration"),
        .target(
            name: "SwiftDaggerKit",
            dependencies: [
                "DependencyAnalyzer",
                "DependencyModel",
                "CodeGeneration",
            ]
        ),
        .target(
            name: "SwiftDagger",
            dependencies: []
        ),
        .target(
            name: "Example",
            dependencies: [
                "ExampleCore"
            ],
            plugins: [
                .plugin(name: "SwiftDaggerPlugin")
            ]
        ),
        .target(
            name: "ExampleCore",
            dependencies: [
                "SwiftDagger"
            ],
            plugins: [
                .plugin(name: "SwiftDaggerPlugin")
            ]
        ),
        .executableTarget(
            name: "ExampleApp",
            dependencies: [
                "Example"
            ],
            plugins: [
                .plugin(name: "SwiftDaggerPlugin")
            ]
        ),
        .testTarget(
            name: "SwiftDaggerKitTests",
            dependencies: ["SwiftDaggerKit"]
        ),
        .testTarget(
            name: "swift-daggerTests",
            dependencies: ["swift-dagger"]
        ),
    ]
)
