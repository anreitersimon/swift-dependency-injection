public struct Extension: Equatable, Codable, DeclarationScope {
    public let extendedType: String
    
    public let scope: String

    @DefaultEmpty public var initializers: [Initializer] = []
    @DefaultEmpty public var variables: [Variable] = []
    @DefaultEmpty public var functions: [Function] = []
    @DefaultEmpty public var types: [TypeDeclaration] = []
    @DefaultEmpty public var typealiases: [TypeAlias] = []
    @DefaultEmpty public var modifiers: [Modifier]
    @DefaultEmpty public var generics: Generics = .empty
    @DefaultEmpty public var inheritedTypes: [TypeSignature] = []
    public let sourceRange: SourceRange?

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
    }

    var path: String { extendedType }

    public var fullyQualifiedName: String { "\(scope).\(extendedType)" }
    public var accessLevel: AccessLevel { modifiers.accessLevel }
}
