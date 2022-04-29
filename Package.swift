// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let localCLITools =
    ProcessInfo.processInfo.environment["SWIFT_DEPENDENCY_INJECTION_LOCAL_CLI_TOOLS"] != nil

let cliToolsTarget: Target

if localCLITools {
    cliToolsTarget = .binaryTarget(
        name: "swift-dependency-injection",
        path: "swift-dependency-injection.zip"
    )
} else {
    cliToolsTarget = .binaryTarget(
        name: "swift-dependency-injection",
        url:
            "https://github.com/anreitersimon/swift-dependency-injection-cli/releases/download/0.0.1/swift-dependency-injection.zip",
        checksum: "7a7ea0184392ad49d16a1ee0a46e258b8409da9a6dbfbf66e3c595be28f4bd3c"
    )
}

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
        cliToolsTarget,
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
