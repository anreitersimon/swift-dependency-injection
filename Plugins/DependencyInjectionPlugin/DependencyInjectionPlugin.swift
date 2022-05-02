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
        let modulesList = context.pluginWorkDirectory.appending("modules-list.txt")

        Diagnostics.remark("Working Directory: \(context.pluginWorkDirectory.string)")
        let moduleFile = modulesDir.appending(
            "\(target.name)_Module.swift"
        )

        var files: [String] = []
        var commands: [Command] = []

        let modules = target.recursiveTargetDependencies
            .compactMap { $0 as? SwiftSourceModuleTarget }
            .filter {
                !$0.compilationConditions.contains("swift_dependency_injection_exclude")

            }
            .filter {
                $0.recursiveTargetDependencies.contains {
                    $0.name == "DependencyInjection"
                }
            }
            .map { $0.moduleName }

        Diagnostics.remark("SubModules: \(modules.joined(separator: ", "))")

        FileManager.default.smartWrite(
            atPath: modulesList.string,
            contents: modules.joined(separator: "\n")
        )

        FileManager.default.smartWrite(
            atPath: fileList.string,
            contents:
                target
                .sourceFiles(withSuffix: "swift")
                .map(\.path.string)
                .joined(separator: "\n")
        )

        for file in target.sourceFiles(withSuffix: "swift") {
            let outputFile = factoriesDir.appending(
                "\(file.path.stem)+DependencyFactories.swift"
            )
            files.append(file.path.string)

            commands.append(
                Command.buildCommand(
                    displayName: "Generating Dependencies from \(file.path.stem)",
                    executable: tool.path,
                    arguments: [
                        "generate-file",
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
            "generate-module",
            "--output-file=\(moduleFile)",
            "--module-name=\(target.moduleName)",
            "--module-list-file=\(modulesList)",
            "--file-list-file=\(fileList)",
        ]

        commands.append(
            .buildCommand(
                displayName: "Generating \(target.moduleName) DependencyModule",
                executable: tool.path,
                arguments: arguments,
                inputFiles: [fileList, modulesList],
                outputFiles: [moduleFile]
            )
        )

        return commands
    }

}
