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

    func removingSuffux(_ str: String) -> String {
        if self.hasSuffix(str) {
            return String(self.dropLast(str.count))
        } else {
            return self
        }
    }
}

extension Extension {
    var isDependencyBindingsExtension: Bool {
        let sanitized = self.extendedType.removingPrefix("\(Constants.runtimeLibraryName).")

        return sanitized == "Dependencies.Bindings"
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

enum ArgumentInjectionKind: Equatable {
    case injected(qualifier: String?)
    case assisted
    case none
    case inValid

    var preventsInjection: Bool {
        return self == .inValid
    }
}

public enum BuiltinQualifier: String, Codable {
    case Public
    case Singleton
    case WeakSingleton
}

public struct Qualifiers: Codable, Equatable {
    @DefaultEmpty public var builtIn: [BuiltinQualifier]
    public let custom: String?

    public var qualifierSuffix: String {
        custom.map { "_\($0)" } ?? ""
    }

    public var effectiveQalifier: String {
        "Qualifiers.\(custom ?? "Default").self"
    }

    init(raw: String) {
        var components = raw.split(separator: ".")[...]
        guard
            components.first == "Qualifiers"
                || components.first == "\(Constants.runtimeLibraryName).Qualifiers"
        else {
            self.builtIn = []
            self.custom = nil
            return
        }

        components = components.dropFirst()

        if components.last == "self" {
            components = components.dropLast()
        }
        if components.last == "Default" {
            components = components.dropLast()
        }

        self.builtIn = components.compactMap {
            BuiltinQualifier(rawValue: String($0))
        }
        self.custom =
            components
            .drop(while: { BuiltinQualifier(rawValue: String($0)) != nil })
            .first?.description

    }
}

extension Attribute {
    var isInjectedOrAssisted: Bool {
        return isInjected || isAssisted
    }

    var isInjected: Bool {
        return Constants.injectAnnotations.contains(name)
    }

    var isAssisted: Bool {
        return Constants.assistedAnnotations.contains(name)
    }

    var injectionKind: ArgumentInjectionKind? {
        if self.isAssisted {
            return .assisted
        } else if self.isInjected {
            return .injected(qualifier: self.arguments.first?.name)
        } else {
            return nil
        }
    }

}

extension Function.Argument {
    public var isInjected: Bool {
        attributes.contains(where: \.isInjected)
    }

    public var isAssisted: Bool {
        attributes.contains(where: \.isAssisted)
    }

    public var isInjectedOrAssisted: Bool {
        attributes.contains(where: \.isInjectedOrAssisted)
    }

    public var qualifiers: Qualifiers {
        Qualifiers(raw: self.attributes.first?.name ?? "")
    }

    func extractInjectionKind(diagnostics: Diagnostics?) -> ArgumentInjectionKind {
        let name = firstName ?? secondName ?? ""

        let relevantAttributes = attributes.filter { $0.isInjectedOrAssisted }
        let injectableAnnotations = relevantAttributes.filter { $0.isInjected }
        let assistedAnnotations = relevantAttributes.filter { $0.isAssisted }

        if injectableAnnotations.count > 1 {
            diagnostics?.warn("Too many Inject Annotation for \(name)")
            return .inValid
        }
        if assistedAnnotations.count > 1 {
            diagnostics?.warn(
                "Too many Assisted Annotation for \(name)",
                at: self.sourceRange?.start
            )
            return .inValid
        }

        if !injectableAnnotations.isEmpty && !assistedAnnotations.isEmpty {

            diagnostics?.error(
                "Cannot combine Inject and Assisted",
                at: self.sourceRange?.start
            )
            return .inValid
        }

        if injectableAnnotations.isEmpty
            && assistedAnnotations.isEmpty
            && defaultValue == nil
        {
            diagnostics?.error(
                "argument \(name) must either be annotated with Inject or Assisted or provide a defaultValue",
                at: self.sourceRange?.start
            )
            return .inValid
        }

        return relevantAttributes.first?.injectionKind ?? .none
    }

}

extension Function {
    var qualifiers: Qualifiers {
        Qualifiers(raw: attributes.first?.name ?? "")
    }
}

extension SourceModel.Initializer {

    func isInjectable(diagnostics: Diagnostics?) -> Bool {
        var isValid = true

        for arg in self.arguments {
            let kind = arg.extractInjectionKind(diagnostics: diagnostics)
            isValid = isValid && !kind.preventsInjection
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
            collectScopeDeclaration(type)
        }

        for type in file.recursiveTypes {
            collectInjectableType(type)
        }

    }

}
