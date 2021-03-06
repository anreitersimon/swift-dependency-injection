import CodeGeneration
import DependencyModel
import Foundation
import SourceModel

public class XcodeDiagnostics: Diagnostics {
    public init() {}

    public var hasErrors: Bool = false

    public func record(_ diagnostic: Diagnostic) {
        if diagnostic.level == .error {
            hasErrors = true
        }
        print(diagnostic.description)
    }
}

public struct Generator {

    public static func generateFactories(
        moduleName: String,
        inputFile: URL,
        outputFile: URL,
        diagnostics: Diagnostics
    ) throws {
        // TODO
        let sourceFile = try SourceFile.parse(
            module: moduleName,
            file: inputFile
        )

        let fileGraph = try DependencyGraphCollector.extractGraph(
            file: sourceFile,
            diagnostics: diagnostics
        )

        let contents = CodeGen.generateSources(
            fileGraph: fileGraph
        )

        try FileManager.default.smartWrite(
            contents.data(using: .utf8)!,
            to: outputFile,
            compare: true
        )

    }

    public static func generateModule(
        moduleGraph: ModuleDependencyGraph,
        outputFile: URL
    ) throws {

        let contents = CodeGen.generateSources(moduleGraph: moduleGraph)
        try FileManager.default.smartWrite(
            contents.data(using: .utf8)!,
            to: outputFile,
            compare: true
        )

    }

}

extension FileManager {
    func smartWrite(
        _ contents: Data,
        to url: URL,
        compare: Bool = false
    ) throws {
        if fileExists(atPath: url.path) {
            if compare {
                let existing = try Data(contentsOf: url)
                if existing == contents {
                    print("Not writing \(url.lastPathComponent) because its unchanged")
                    return
                }
            }

            try self.removeItem(at: url)
        }
        try self.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try contents.write(to: url, options: .atomic)

    }
}
