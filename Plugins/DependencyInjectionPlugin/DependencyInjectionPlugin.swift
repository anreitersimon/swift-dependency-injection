import Foundation
import PackagePlugin

@main
struct DependencyInjectionPlugin: BuildToolPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {

        guard let target = target as? SwiftSourceModuleTarget else {
            Diagnostics.remark(
                "Plugin can only be applied to Swift targets"
            )
            return []
        }

        if !target.recursiveTargetDependencies.contains(where: { $0.name == "DependencyInjection" })
        {
            Diagnostics.error(
                "Target \(target.name) does not have required dependency DependencyInjection"
            )
        }

        let tool = try context.tool(named: "swift-dependency-injection")
        let generatedSources = context.pluginWorkDirectory.appending("GeneratedSources")
        let factoriesDir = generatedSources.appending("Factories")
        let modulesDir = generatedSources.appending("Modules")
        let fileList = context.pluginWorkDirectory.appending("file-list.txt")

        Diagnostics.remark("Working Directory: \(context.pluginWorkDirectory.string)")
        let moduleFile = modulesDir.appending(
            "\(target.name)_Module.swift"
        )

        var files: [String] = []
        var commands: [Command] = []

        FileManager.default.createFile(
            atPath: fileList.string,
            contents: target
                .sourceFiles(withSuffix: "swift")
                .map(\.path.string)
                .joined(separator: "\n")
                .data(using: .utf8),
            attributes: nil
        )

        for file in target.sourceFiles(withSuffix: "swift") {
            let outputFile = factoriesDir.appending(
                "\(file.path.stem)+DependencyFactories.swift"
            )
            files.append(file.path.string)

            commands.append(
                Command.buildCommand(
                    displayName: "Generating \(outputFile.stem)",
                    executable: tool.path,
                    arguments: [
                        "extract",
                        "--module-name=\(target.moduleName)",
                        "--output-file=\(outputFile)",
                        "--input-file=\(file.path)",
                    ],
                    environment: [:],
                    inputFiles: [file.path],
                    outputFiles: [outputFile]
                )
            )
        }

        let arguments = [
            "merge",
            "--output-file=\(moduleFile)",
            "--module-name=\(target.moduleName)",
            "--input-file=\(fileList)",
        ]

        commands.append(
            .buildCommand(
                displayName: "Generating \(target.moduleName) DependencyModule",
                executable: tool.path,
                arguments: arguments,
                inputFiles: [fileList],
                outputFiles: [moduleFile]
            )
        )

        return commands
    }

}
