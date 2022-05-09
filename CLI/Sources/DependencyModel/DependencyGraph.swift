import Foundation
import SourceModel

public struct FileDependencyGraph: Codable {
    public let fileName: String
    public let module: String
    
    public var imports: [Import] = []
    public var scopes: [ScopeDefinition] = []
    
    public var provides: [ProvidedType] = []
    public var bindings: [Binding] = []
    
    public var uses: [Injection] = []

    public mutating func registerInjectableType(
        _ type: TypeDeclaration,
        kind: InjectableProtocol,
        initializer: Initializer
    ) {
        self.provides.append(
            ProvidedType(
                kind: kind,
                name: type.name,
                fullName: type.fullyQualifiedName,
                initializer: initializer
            )
        )

        uses.append(Injection(arguments: initializer.arguments))
    }

    public mutating func registerBinding(
        type: TypeSignature,
        kind: InjectableProtocol,
        factoryMethod: Function,
        scope: TypeSignature
    ) {
        self.bindings.append(
            Binding(
                kind: kind,
                type: type,
                factoryMethod: factoryMethod,
                scope: scope
            )
        )

        uses.append(Injection(arguments: factoryMethod.arguments))
    }

    public init(
        fileName: String,
        module: String,
        imports: [Import] = [],
        provides: [ProvidedType] = [],
        uses: [Injection] = []
    ) {
        self.fileName = fileName
        self.module = module
        self.imports = imports
        self.provides = provides
        self.uses = uses
    }

}

public struct ModuleDependencyGraph: Codable {

    public let module: String
    public var files: [URL]
    public var modules: [String]

    public init(
        module: String,
        files: [URL] = [],
        modules: [String] = []
    ) {
        self.module = module
        self.files = files
        self.modules = modules
    }

}

public struct TopLevelDependencyGraph: Codable {}

public struct ProvidedType: Codable {
    public let kind: InjectableProtocol
    public let name: String
    public let fullName: String
    public let initializer: Initializer
}

public struct Binding: Codable {
    public let kind: InjectableProtocol
    public let type: TypeSignature
    public let factoryMethod: Function
    public let scope: TypeSignature
}

public struct ScopeDefinition: Codable {
    public let name: String
    public let parent: String
}

public struct Injection: Codable {
    public let arguments: [Function.Argument]

    public init(arguments: [Function.Argument]) {
        self.arguments = arguments
    }
}
