import Foundation
import SourceModel

protocol TypeInheritance {
    var inheritedTypes: [TypeSignature] { get }
    var sourceRange: SourceRange? { get }
}

extension Extension: TypeInheritance {}
extension TypeDeclaration: TypeInheritance {}

extension String {
    func removingPrefix(_ str: String) -> String {
        if self.hasPrefix(str) {
            return String(self.dropFirst(str.count))
        } else {
            return self
        }
    }
}

extension Extension {
    var extendedFactoryType: InjectableProtocol? {
        let sanitized = self.extendedType.removingPrefix("\(Constants.runtimeLibraryName).")

        switch sanitized {
        case "Dependencies.Factories":
            return .factory
        case "Dependencies.Singletons":
            return .singleton
        case "Dependencies.WeakSingletons":
            return .weakSingleton
        default:
            return nil
        }
    }
}

extension TypeInheritance {

    var conformsToInjectable: Bool {
        !injectableConformances.isEmpty
    }

    var injectableConformances: [InjectableProtocol] {
        inheritedTypes.compactMap(InjectableProtocol.from(type:))
    }

}

extension TypeDeclaration {

    func initializersWithInjectableArguments() -> [Initializer] {
        self.allAvailableInitializers.filter {
            $0.arguments.contains { $0.isAssisted || $0.isInjected }
        }
    }

    func findPrimaryInjectionInitializer(
        diagnostics: Diagnostics
    ) -> SourceModel.Initializer? {

        guard initializers.count <= 1 else {
            diagnostics.error(
                "Too many Initializers defined for Injectable type \(name)\nMove other Initializers to a extension to disambiguate"
            )

            return nil
        }

        let initializer: SourceModel.Initializer

        if initializers.count == 1 {
            initializer = initializers[0]

        } else {
            guard let memberwiseInitializer = implicitMemberwiseInitializer else {
                diagnostics.error(
                    "No Initializer defined for Injectable type \(name)"
                )

                return nil
            }
            initializer = memberwiseInitializer
        }

        guard initializer.isInjectable(diagnostics: diagnostics) else {
            return nil
        }

        return initializer
    }
}

extension Function.Argument {

    public var isInjected: Bool {
        !Constants.injectAnnotations.intersection(attributes).isEmpty
    }

    public var isAssisted: Bool {
        !Constants.assistedAnnotations.intersection(attributes).isEmpty
    }

    func isInjectable(diagnostics: Diagnostics) -> Bool {
        var isValid = true
        let name = firstName ?? secondName ?? ""

        let injectableAnnotations = Constants.injectAnnotations.intersection(attributes)

        let assistedAnnotations = Constants.assistedAnnotations.intersection(attributes)

        if injectableAnnotations.count > 1 {
            diagnostics.warn("Too many Inject Annotation for \(name)")
        }
        if assistedAnnotations.count > 1 {
            diagnostics.warn(
                "Too many Assisted Annotation for \(name)",
                at: self.sourceRange?.start
            )
        }

        if !injectableAnnotations.isEmpty && !assistedAnnotations.isEmpty {
            isValid = false

            diagnostics.error(
                "Cannot combine Inject and Assisted",
                at: self.sourceRange?.start
            )
        }

        if injectableAnnotations.isEmpty
            && assistedAnnotations.isEmpty
            && defaultValue == nil
        {
            diagnostics.error(
                "argument \(name) must either be annotated with Inject or Assisted or provide a defaultValue",
                at: self.sourceRange?.start
            )
        }

        return isValid
    }

}

extension SourceModel.Initializer {
    func isInjectable(diagnostics: Diagnostics) -> Bool {
        var isValid = true

        for arg in self.arguments {
            isValid = isValid && arg.isInjectable(diagnostics: diagnostics)
        }

        return isValid
    }
}

public enum DependencyAnalysisError: Error {
    case error
}

public struct DependencyGraphCollector {
    var graph: FileDependencyGraph
    let diagnostics: Diagnostics

    public static func extractGraph(
        file: SourceFile,
        diagnostics: Diagnostics
    ) throws -> FileDependencyGraph {
        var collector = DependencyGraphCollector(
            graph: FileDependencyGraph(
                fileName: file.fileName,
                module: file.module,
                imports: file.imports
            ),
            diagnostics: diagnostics
        )

        collector.run(file)

        return collector.graph
    }

    public mutating func run(_ file: SourceFile) {

        for proto in file.recursiveTypes where proto.kind == .protocol {

        }

        for ext in file.extensions where ext.conformsToInjectable {
            diagnostics.error(
                "Injectable conformance must be declared in the type-declaration",
                at: ext.sourceRange?.start
            )
        }

        for ext in file.extensions {
            collectBindingExtensions(ext)
        }

        for type in file.recursiveTypes {
            collectInjectableType(type)
        }

    }

}
