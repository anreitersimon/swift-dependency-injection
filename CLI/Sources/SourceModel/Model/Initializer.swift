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

    public var modifiers: [Modifier] = []
    public var trailingModifiers: [Function.TrailingModifier] = []
    public var generics: Generics = .empty

    public var arguments: [Function.Argument] = []
    public var sourceRange: SourceRange? = nil
}

public struct TypeAlias: Equatable, Codable {

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
    }

    public var accessLevel: AccessLevel {
        modifiers.accessLevel
    }

    public var modifiers: [Modifier] = []
    public var identifier: String
    public var type: TypeSignature?

    public var sourceRange: SourceRange? = nil
}
