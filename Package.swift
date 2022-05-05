// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let localCLITools =
    ProcessInfo.processInfo.environment["SWIFT_DEPENDENCY_INJECTION_LOCAL_CLI_TOOLS"] != nil

let package = Package(
    name: "swift-dependency-injection",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .plugin(
            name: "DependencyInjectionPlugin",
            targets: ["DependencyInjectionPlugin"]
        ),
        .executable(
            name: "ExampleApp",
            targets: ["ExampleApp"]
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

if localCLITools && false {
    print("\(#file): warning: Using Local Plugin")
    package.dependencies.append(
        .package(path: "./swift-dependency-injection-cli")
    )
} else {
    print("\(#file): warning: Using Precompiled Plugin")
    package.targets.append(
        .binaryTarget(
            name: "swift-dependency-injection",
            path: "swift-dependency-injection.zip"
        )
    )
}
