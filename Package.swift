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
        .target(
            name: "DependencyInjection",
            dependencies: [],
            swiftSettings: []
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
    print("\(#file): warning: Using Local Plugin")
    package.dependencies.append(.package(path: "CLI"))

    package.targets += [
        .plugin(
            name: "DependencyInjectionPlugin",
            capability: .buildTool(),
            dependencies: [
                .product(
                    name: "swift-dependency-injection",
                    package: "CLI"
                )
            ]
        )
    ]
} else {
    print("\(#file): warning: Using Precompiled Plugin")
    package.targets += [
        .plugin(
            name: "DependencyInjectionPlugin",
            capability: .buildTool(),
            dependencies: [
                "swift-dependency-injection"
            ]
        ),
        .binaryTarget(
            name: "swift-dependency-injection",
            path: "swift-dependency-injection.zip"
        ),
    ]
}
