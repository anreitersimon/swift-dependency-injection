import ArgumentParser
import DependencyInjectionKit
import DependencyModel
import Foundation

@main struct SwiftDependencyInjection: ParsableCommand {
    static let configuration = CommandConfiguration(subcommands: [
        Generate.self,
        GenerateFile.self,
        GenerateModule.self,
    ])
}

struct Generate: ParsableCommand {

    @Option
    var moduleName: String

    @Option(parsing: .upToNextOption)
    var inputFiles: [String]

    @Option
    var outputDirectory: String

    func run() throws {

        var graph = ModuleDependencyGraph(module: moduleName)
        let outputURL = URL(fileURLWithPath: outputDirectory)

        for inputFile in inputFiles {
            let inputURL = URL(fileURLWithPath: inputFile)
            let inputBaseName = inputURL.deletingPathExtension().lastPathComponent

            graph.files.append(inputURL)

            let outputFile =
                outputURL
                .appendingPathComponent("Factories")
                .appendingPathComponent("\(inputBaseName)+Factories.swift")

            let diagnostics = XcodeDiagnostics()

            try Generator.generateFactories(
                moduleName: moduleName,
                inputFile: URL(fileURLWithPath: inputFile),
                outputFile: outputFile,
                diagnostics: diagnostics
            )

            if diagnostics.hasErrors {
                throw ExitCode(1)
            }
        }

        let moduleFile =
            outputURL
            .appendingPathComponent("Module")
            .appendingPathComponent("\(moduleName)_Module.swift")

        try Generator.generateModule(
            moduleGraph: graph,
            outputFile: moduleFile
        )

    }
}

struct GenerateFile: ParsableCommand {

    @Option
    var moduleName: String

    @Option
    var inputFile: String

    @Option
    var outputFile: String

    mutating func run() throws {
        let diagnostics = XcodeDiagnostics()

        try Generator.generateFactories(
            moduleName: moduleName,
            inputFile: URL(fileURLWithPath: inputFile),
            outputFile: URL(fileURLWithPath: outputFile),
            diagnostics: diagnostics
        )

        if diagnostics.hasErrors {
            throw ExitCode(1)
        }
    }
}

struct GenerateModule: ParsableCommand {

    @Option
    var fileListFile: String

    @Option
    var moduleListFile: String

    @Option
    var moduleName: String

    @Option
    var outputFile: String

    mutating func run() throws {
        var graph = ModuleDependencyGraph(module: moduleName)
        // let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let fileList = try String(contentsOfFile: fileListFile).split(separator: "\n")
        let moduleList = try String(contentsOfFile: moduleListFile).split(separator: "\n")

        for path in fileList {
            graph.files.append(URL(fileURLWithPath: String(path)))
        }
        for module in moduleList {
            graph.modules.append(String(module))
        }

        try Generator.generateModule(
            moduleGraph: graph,
            outputFile: URL(fileURLWithPath: outputFile)
        )

    }
}
