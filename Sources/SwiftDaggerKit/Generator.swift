import CodeGen
import Foundation
import SwiftSyntax

public struct Generator {

    public static func generateFactories(
        moduleName: String,
        inputFile: URL,
        outputFile: URL,
        graphFile: URL
    ) throws {
        let sourceFile = try SyntaxParser.parse(inputFile)
        let scanner = SourceFileScanner(
            moduleName: moduleName,
            converter: SourceLocationConverter(
                file: inputFile.absoluteString,
                tree: sourceFile
            )
        )
        scanner.walk(sourceFile)

        try FileManager.default.createDirectory(
            at: outputFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: graphFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        try encoder.encode(scanner.dependencyGraph).write(to: graphFile)

        print("warning: writing graph to \(graphFile.absoluteString)")
        print("warning: writing to \(outputFile.absoluteString)")

        let fileWriter = FileWriter()

        try fileWriter.write(
            File.generatedFactories(imports: scanner.imports, graph: scanner.dependencyGraph),
            to: outputFile
        )
    }

    public static func generateModule(
        moduleName: String,
        mergedGraph: DependencyGraph,
        outputFile: URL
    ) throws {

        try FileManager.default.createDirectory(
            at: outputFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let fileWriter = FileWriter()

        try fileWriter.write(
            File.module(name: moduleName, graph: mergedGraph),
            to: outputFile
        )
    }

}

extension SwiftDaggerKit.Argument {
    func toFunctionArgument() -> Function.Argument {
        Function.Argument(
            firstName: firstName,
            secondName: secondName,
            type: type.name
        )
    }
}
