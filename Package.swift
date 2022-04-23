// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
        .binaryTarget(
            name: "swift-dependency-injection",
            url:
                "https://github.com/anreitersimon/swift-dependency-injection-cli/releases/download/1.0.0/swift-dependency-injection.zip",
            checksum: "e57df711464c6ad29b2a61e751ba41c80d3d7965e235c72d0c5aa1e9fb37891d"
        ),
        .plugin(
            name: "DependencyInjectionPlugin",
            capability: .buildTool(),
            dependencies: [
                "swift-dependency-injection"
            ]
        ),
        .target(
            name: "DependencyInjection",
            dependencies: []
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
