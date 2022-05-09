public struct Function: Equatable, Codable {

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
        case `open`

        case `static`
        case `class`

        case `weak`
        case `unowned`

        case `mutating`
    }

    public enum TrailingModifier: String, Codable, ModifierProtocol {
        case `throws`, `rethrows`, `async`
    }

    public var accessLevel: AccessLevel { modifiers.accessLevel }
    public let name: String
    public var arguments: [Argument] = []
    public var modifiers: [Modifier]
    public var generics: Generics = .empty
    public let trailingModifiers: [TrailingModifier]
    public let returnType: TypeSignature?
    public var sourceRange: SourceRange? = nil

    public struct Argument: Equatable, Codable, CustomStringConvertible {
        public init(
            firstName: String? = nil,
            secondName: String? = nil,
            type: TypeSignature? = nil,
            attributes: [String] = [],
            defaultValue: String? = nil,
            sourceRange: SourceRange? = nil
        ) {
            self.firstName = firstName
            self.secondName = secondName
            self.type = type
            self.attributes = attributes
            self.defaultValue = defaultValue
            self.sourceRange = sourceRange
        }

        public var firstName: String?
        public var secondName: String?
        public var type: TypeSignature?
        public var attributes: [String] = []
        public var defaultValue: String? = nil
        public var sourceRange: SourceRange? = nil

        public var description: String {
            var builder = [
                firstName, secondName,
            ]
            .compactMap { $0 }
            .joined(separator: " ")

            builder.append(": ")
            if let type = type {
                builder.append(type.description)
            }

            if let defaultValue = defaultValue {
                builder.append(" = \(defaultValue)")
            }

            return builder
        }

        public var callSiteName: String? {
            if firstName == "_" {
                return nil
            } else {
                return firstName
            }
        }
    }
}
