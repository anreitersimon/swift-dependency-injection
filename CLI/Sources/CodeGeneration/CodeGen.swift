import DependencyModel
import Foundation
import SourceModel

extension String {

    /// Returns a form of the string that is a valid bundle identifier
    public func swiftIdentifier() -> String {
        return self.filter { $0.isNumber || $0.isLetter }
    }

    public var lowerFirst: String {
        guard let firstCharacter = self.first else { return self }

        return firstCharacter.lowercased() + self.dropFirst()
    }
}

// TODO: Dont duplicate
extension Function.Argument {

    public var isInjected: Bool {
        !Constants.injectAnnotations.intersection(attributes).isEmpty
    }

    public var isAssisted: Bool {
        !Constants.assistedAnnotations.intersection(attributes).isEmpty
    }
}

extension Initializer {
    public var isAssisted: Bool {
        return arguments.contains(where: \.isAssisted)
    }
}

public enum CodeGen {

    static let header = "// Automatically generated DO NOT MODIFY"

    public static func generateSources(
        moduleGraph graph: ModuleDependencyGraph
    ) -> String {

        let writer = FileWriter()

        writer.writeMultiline(
            """
            \(header)

            import DependencyInjection
            """
        )
        for module in graph.modules {
            writer.writeLine("import \(module)")
        }

        writer.scope("public enum \(graph.module)_Module: DependencyInjection.DependencyModule") {

            $0.writeLine("public static let submodules: [DependencyModule.Type] = [")
            $0.indent {
                for module in graph.modules {
                    $0.writeLine("\(module)_Module.self,")
                }
            }
            $0.writeLine("]")

            $0.scope("public static func register(in registry: DependencyRegistry)") {
                for file in graph.files {
                    let fileName = file.deletingPathExtension().lastPathComponent.swiftIdentifier()
                    $0.writeLine("register_\(fileName)(in: registry)")
                }
            }

        }

        return writer.builder
    }

    public static func generateSources(
        fileGraph graph: FileDependencyGraph
    ) -> String {

        let writer = FileWriter()

        writer.writeLine(header)
        writer.endLine()

        for imp in graph.imports {
            writer.writeLine(imp.description)
        }

        if !graph.imports.contains(where: { $0.path == "DependencyInjection" }) {
            writer.write("import DependencyInjection")
        }

        writer.endLine()

        writer.writeLine("// MARK: - File Extension -")

        writer.scope("extension \(graph.module)_Module") {
            $0.scope(
                "static func register_\(graph.fileName.swiftIdentifier())(in registry: DependencyRegistry)"
            ) {

                $0.endLine()
                $0.writeLine("// Scopes")
                for scope in graph.scopes {
                    $0.writeLine("registry.registerScope(\(scope.name).self)")
                }

                $0.endLine()
                $0.writeLine("// Types")

                for provided in graph.provides
                where !provided.initializer.arguments.contains(where: \.isAssisted) {
                    $0.writeLine("\(provided.fullName).register(in: registry)")
                }

                $0.endLine()
                $0.writeLine("// Bindings")

                for binding in graph.bindings {
                    $0.writeLine(
                        "register_Binding_\(binding.type.description.swiftIdentifier())(in: registry)"
                    )
                }
            }
        }

        for scope in graph.scopes {
            writer.writeMultiline(
                """
                public protocol Provides_\(scope.name): Provides_\(scope.parent.description) {}

                extension \(scope.name): Provides_\(scope.name) {}
                """
            )
        }

        writer.writeLine("// User defined Binding extensions")
        writer.endLine()

        writer.scope("extension \(graph.module)_Module") {
            for binding in graph.bindings {
                generateCustomBinding(in: $0, binding: binding)
            }
        }

        writer.writeLine("// Provided Types")
        writer.endLine()

        for provided in graph.provides {
            writer.scope("extension \(provided.fullName)") {
                generateRegistration(in: $0, injectable: provided)
                generateTypeFactory(in: $0, injectable: provided)
            }
        }

        writer.endLine()

        writer.endLine()
        writer.writeLine("// Container Extensions")

        for provided in graph.provides {
            generateContainerFactoryMethod(
                in: writer,
                accessLevel: provided.accessLevel,
                typeName: provided.name,
                scope: provided.scope.description,
                arguments: provided.initializer.arguments
            )
        }

        for binding in graph.bindings {
            generateContainerFactoryMethod(
                in: writer,
                accessLevel: binding.accessLevel ?? .internal,
                typeName: binding.type.description,
                scope: binding.scope.description,
                arguments: []
            )
        }

        return writer.builder
    }

    private static func generateCustomBinding(
        in writer: FileWriter,
        binding: Binding
    ) {

        writer.scope(
            "fileprivate static func register_Binding_\(binding.type.description.swiftIdentifier())(in registry: DependencyRegistry)"
        ) {
            generateRequirementsVariable(
                in: $0,
                arguments: binding.factoryMethod.arguments
            )

            let methodName: String
            let extendedKind: String

            switch binding.kind {
            case .factory:
                methodName = "registerFactory"
                extendedKind = "Dependencies.Factories"
            case .singleton:
                methodName = "registerSingleton"
                extendedKind = "Dependencies.Singletons"
            case .weakSingleton:
                methodName = "registerWeakSingleton"
                extendedKind = "Dependencies.WeakSingletons"
            }
            
            let extendedScope = "\(extendedKind)<\(binding.scope.description)>"

            let typeName = binding.type.asMetatype()

            if typeName == nil {
                $0.writeLine("#error(\"No Metatype\")")
            }

            $0.writeMultiline(
                """
                registry.\(methodName)(
                    ofType: \(typeName ?? "Never.self"),
                    in: \(binding.scope.asMetatype() ?? "Never.self"),
                    requirements: requirements
                ) { resolver -> \(binding.type.description) in
                """
            )
            $0.indent {
                $0.write("\(extendedScope).\(binding.methodName)")
                $0.writeCallArguments(binding.factoryMethod.arguments) { _ in
                    "resolver.resolve()"
                }
                $0.endLine()
            }
            $0.writeLine("}")

        }
    }

    private static func generateRegistration(
        in writer: FileWriter,
        injectable: ProvidedType
    ) {
        writer.scope("fileprivate static func register(in registry: DependencyRegistry)") {
            generateRequirementsVariable(
                in: $0,
                arguments: injectable.initializer.arguments.filter(\.isInjected)
            )

            switch injectable.kind {
            case .factory where injectable.initializer.isAssisted:
                $0.writeMultiline(
                    """
                    registry.registerAssistedFactory(
                        ofType: \(injectable.fullName).self,
                        in: \(injectable.fullName).Scope.self,
                        requirements: requirements
                    )
                    """
                )
            case .factory, .singleton, .weakSingleton:
                let methodName: String

                switch injectable.kind {
                case .factory:
                    methodName = "registerFactory"
                case .singleton:
                    methodName = "registerSingleton"
                case .weakSingleton:
                    methodName = "registerWeakSingleton"
                }

                $0.writeMultiline(
                    """
                    registry.\(methodName)(
                        ofType: \(injectable.fullName).self,
                        in: \(injectable.fullName).Scope.self,
                        requirements: requirements
                    ) { resolver in
                        \(injectable.fullName).newInstance(resolver: resolver)
                    }
                    """
                )
            }

        }
    }

    private static func generateContainerFactoryMethod(
        in writer: FileWriter,
        accessLevel: AccessLevel,
        typeName: String,
        scope: String,
        arguments: [Function.Argument]
    ) {
        let allArguments = arguments.filter { $0.isAssisted || $0.isInjected }
        let assisted = allArguments.filter(\.isAssisted)
        var actualArguments = assisted
        actualArguments.insert(Function.Argument(firstName: "resolver"), at: 0)

        writer.scope("extension DependencyContainer where Scope: Provides_\(scope)") {

            $0.write(
                "\(accessLevel.rawValue) func \(typeName.swiftIdentifier().lowerFirst)"
            )
            
            $0.writeDeclarationArguments(assisted)

            $0.scope(" -> \(typeName)") {
                if assisted.isEmpty {
                    $0.writeLine("resolve()")
                } else {
                    $0.write("\(typeName).newInstance")
                    $0.writeCallArguments(actualArguments) {
                        $0.firstName == "resolver" ? "self" : nil
                    }
                }
            }

        }
    }

    private static func generateTypeFactory(
        in writer: FileWriter,
        injectable: ProvidedType
    ) {
        let allArguments = injectable.initializer.arguments
            .filter { $0.isAssisted || $0.isInjected }
        let assisted = allArguments.filter(\.isAssisted)

        writer.writeLine("fileprivate static func newInstance(")
        writer.indent {
            $0.write("resolver: DependencyResolver = Dependencies.sharedResolver")

            for argument in assisted {
                $0.write(",")
                $0.endLine()
                $0.write(argument.description)
            }
        }
        writer.endLine()
        writer.scope(") -> \(injectable.fullName)") {
            $0.write("\(injectable.fullName)")
            $0.writeCallArguments(allArguments.filter { $0.isInjected || $0.isAssisted }) {
                $0.isInjected ? "resolver.resolve()" : nil
            }
        }

    }

    private static func generateRequirementsVariable(
        in writer: FileWriter,
        arguments: [Function.Argument]
    ) {
        writer.write("let requirements: [String: Any.Type] = [")

        guard !arguments.isEmpty else {
            writer.write(":]")
            writer.endLine()
            writer.endLine()
            return
        }
        writer.endLine()

        writer.indent {
            for field in arguments {
                if let metaType = field.type?.asMetatype() {
                    $0.writeLine("\"\(field.firstName ?? field.secondName ?? "-")\": \(metaType),")
                }
            }
        }
        writer.writeLine("]")
        writer.endLine()
    }
}

extension FileWriter {

    func writeDeclarationArguments(
        _ arguments: [Function.Argument]
    ) {
        self.write("(")
        self.indent {

            var isFirst = true

            for argument in arguments {

                if !isFirst {
                    $0.write(",")
                }
                $0.endLine()

                if let outerLabel = argument.firstName {
                    $0.write(outerLabel)
                    if let internalName = argument.secondName {
                        $0.write(" ")
                        $0.write(internalName)
                    }
                }
                $0.write(": \(argument.type?.description ?? "")")
                
                if let defaultValue = argument.defaultValue {
                    $0.write(" = \(defaultValue)")
                }
                isFirst = false
            }
        }

        if !arguments.isEmpty {
            endLine()
        }

        self.write(")")

    }

    func writeCallArguments(
        _ arguments: [Function.Argument],
        valueProvider: (Function.Argument) -> String?
    ) {
        self.write("(")
        self.indent {

            var isFirst = true

            for argument in arguments {

                if !isFirst {
                    $0.write(",")
                }
                $0.endLine()

                if let argName = argument.callSiteName {
                    $0.write(argName)
                    $0.write(": ")
                }

                if let custom = valueProvider(argument) {
                    $0.write(custom)
                } else if argument.isAssisted {
                    let internalName = argument.secondName ?? argument.firstName

                    assert(internalName != nil, "argument must at least have internal name")

                    $0.write(internalName!)
                }
                isFirst = false
            }
        }

        if !arguments.isEmpty {
            endLine()
        }

        self.write(")")
    }

}
