public struct Initializer: Equatable, Codable {
    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
        case `open`
    }

    public var accessLevel: AccessLevel {
        modifiers.accessLevel
    }

    @DefaultEmpty public var modifiers: [Modifier] = []
    @DefaultEmpty public var trailingModifiers: [Function.TrailingModifier] = []
    @DefaultEmpty public var generics: Generics = .empty

    @DefaultEmpty public var arguments: [Function.Argument] = []
    public var sourceRange: SourceRange? = nil
}

public struct TypeAlias: Equatable, Codable {

    public var accessLevel: AccessLevel {
        modifiers.accessLevel
    }

    public var identifier: String
    @DefaultEmpty public var modifiers: [Modifier] = []
    public var type: TypeSignature?

    public var sourceRange: SourceRange? = nil

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
    }

}
