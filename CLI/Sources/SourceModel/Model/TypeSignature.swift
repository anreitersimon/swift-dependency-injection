@_implementationOnly import SwiftSyntax

public indirect enum TypeSignature: Equatable, Codable {
    case simple(SimpleSignature)
    case tuple(TupleSignature)
    case function(FunctionSignature)
    case metatype(MetaTypeSignature)
    case dictionary(DictionarySignature)
    case array(ArraySignature)
    case optional(OptionalSignature)
    case implicitlyUnwrappedOptional(ImplicitlyUnwrappedOptionalSignature)
    case attributed(AttributedTypeSignature)
    case unknown(UnknownSignature)
    case composition(CompositionSignature)
    case memberType(MemberTypeSignature)
    case classRestriction(ClassRestrictionSignature)

    private enum CodingKeys: String, CodingKey {
        case simple
        case tuple
        case function
        case metatype
        case dictionary
        case array
        case optional
        case implicitlyUnwrappedOptional
        case attributed
        case unknown
        case composition
        case memberType
        case classRestriction
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.count != 1 {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid number of keys found, expected one."
            )
            throw DecodingError.typeMismatch(TypeSignature.self, context)
        }

        let key = container.allKeys[0]
        switch key {
        case .simple:
            self = .simple(try container.decode(SimpleSignature.self, forKey: key))
        case .tuple:
            self = .tuple(try container.decode(TupleSignature.self, forKey: key))
        case .function:
            self = .function(try container.decode(FunctionSignature.self, forKey: key))
        case .metatype:
            self = .metatype(try container.decode(MetaTypeSignature.self, forKey: key))
        case .dictionary:
            self = .dictionary(try container.decode(DictionarySignature.self, forKey: key))
        case .array:
            self = .array(try container.decode(ArraySignature.self, forKey: key))
        case .optional:
            self = .optional(try container.decode(OptionalSignature.self, forKey: key))
        case .implicitlyUnwrappedOptional:
            self = .implicitlyUnwrappedOptional(
                try container.decode(ImplicitlyUnwrappedOptionalSignature.self, forKey: key)
            )
        case .attributed:
            self = .attributed(try container.decode(AttributedTypeSignature.self, forKey: key))
        case .unknown:
            self = .unknown(try container.decode(UnknownSignature.self, forKey: key))
        case .composition:
            self = .composition(try container.decode(CompositionSignature.self, forKey: key))
        case .memberType:
            self = .memberType(try container.decode(MemberTypeSignature.self, forKey: key))
        case .classRestriction:
            self = .classRestriction(
                try container.decode(ClassRestrictionSignature.self, forKey: key)
            )
        }

    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .simple(let simpleSignature):
            try container.encode(simpleSignature, forKey: .simple)
        case .tuple(let tupleSignature):
            try container.encode(tupleSignature, forKey: .tuple)
        case .function(let functionSignature):
            try container.encode(functionSignature, forKey: .function)
        case .metatype(let metaTypeSignature):
            try container.encode(metaTypeSignature, forKey: .metatype)
        case .dictionary(let dictionarySignature):
            try container.encode(dictionarySignature, forKey: .dictionary)
        case .array(let arraySignature):
            try container.encode(arraySignature, forKey: .array)
        case .optional(let optionalSignature):
            try container.encode(optionalSignature, forKey: .optional)
        case .implicitlyUnwrappedOptional(let implicitlyUnwrappedOptionalSignature):
            try container.encode(
                implicitlyUnwrappedOptionalSignature,
                forKey: .implicitlyUnwrappedOptional
            )
        case .attributed(let attributedTypeSignature):
            try container.encode(attributedTypeSignature, forKey: .attributed)
        case .unknown(let unknownSignature):
            try container.encode(unknownSignature, forKey: .unknown)
        case .composition(let compositionSignature):
            try container.encode(compositionSignature, forKey: .composition)
        case .memberType(let memberTypeSignature):
            try container.encode(memberTypeSignature, forKey: .memberType)
        case .classRestriction(let classRestrictionSignature):
            try container.encode(classRestrictionSignature, forKey: .classRestriction)
        }

    }

    public static func simple(name: String, genericArguments: [TypeSignature] = []) -> TypeSignature
    {
        .simple(SimpleSignature(name: name, genericArguments: genericArguments))
    }

    public static func optional(_ base: TypeSignature) -> TypeSignature {
        .optional(OptionalSignature(baseType: base))
    }

    var base: AnyTypeSignatureProtocol {
        switch self {
        case .simple(let simpleSignature): return simpleSignature
        case .tuple(let tupleSignature): return tupleSignature
        case .function(let functionSignature): return functionSignature
        case .metatype(let metaTypeSignature): return metaTypeSignature
        case .dictionary(let dictionarySignature): return dictionarySignature
        case .array(let arraySignature): return arraySignature
        case .optional(let optionalSignature): return optionalSignature
        case .implicitlyUnwrappedOptional(let implicitlyUnwrappedOptionalSignature):
            return implicitlyUnwrappedOptionalSignature
        case .attributed(let attributedTypeSignature): return attributedTypeSignature
        case .unknown(let unknownSignature): return unknownSignature
        case .composition(let compositionSignature): return compositionSignature
        case .memberType(let memberTypeSignature): return memberTypeSignature
        case .classRestriction(let classRestrictionSignature): return classRestrictionSignature
        }
    }

    public var description: String {
        return base.description
    }

    public func asMetatype() -> String? {
        switch self {
        case .metatype: return nil
        default: return "\(description).self"
        }
    }

    func inferLiteralTypes() -> Self {

        return self.base.inferLiteralTypes().asTypeSignature()

    }

    static func fromTypeSyntax(_ type: TypeSyntax) -> TypeSignature {
        let typeProtocol = type.asProtocol(TypeSyntaxProtocol.self)

        switch typeProtocol {
        case let underlying as SimpleTypeIdentifierSyntax:

            return .simple(
                SimpleSignature(
                    name: underlying.name.withoutTrivia().text,
                    genericArguments: underlying.genericArgumentClause?.arguments
                        .map { arg in
                            .fromTypeSyntax(arg.argumentType)
                        } ?? []
                )
            )

        case let underlying as MemberTypeIdentifierSyntax:
            return .memberType(
                MemberTypeSignature(
                    name: underlying.name.trimmed,
                    base: .fromTypeSyntax(underlying.baseType)
                )
            )

        case let underlying as MetatypeTypeSyntax:
            return .metatype(MetaTypeSignature(baseType: .fromTypeSyntax(underlying.baseType)))

        case let underlying as TupleTypeSyntax:
            return .tuple(TupleSignature(raw: underlying.trimmed))

        case let underlying as ArrayTypeSyntax:
            return .array(ArraySignature(element: .fromTypeSyntax(underlying.elementType)))

        case let underlying as DictionaryTypeSyntax:
            return .dictionary(
                DictionarySignature(
                    key: .fromTypeSyntax(underlying.keyType),
                    value: .fromTypeSyntax(underlying.valueType)
                )
            )

        case let underlying as OptionalTypeSyntax:
            return .optional(OptionalSignature(baseType: .fromTypeSyntax(underlying.wrappedType)))

        case let underlying as ImplicitlyUnwrappedOptionalTypeSyntax:
            return .implicitlyUnwrappedOptional(
                ImplicitlyUnwrappedOptionalSignature(
                    baseType: .fromTypeSyntax(underlying.wrappedType)
                )
            )
        case let underlying as CompositionTypeSyntax:
            return .composition(
                CompositionSignature(
                    elements: underlying.elements.map { TypeSignature.fromTypeSyntax($0.type) }
                )
            )

        case let underlying as AttributedTypeSyntax:
            return .attributed(
                AttributedTypeSignature(
                    base: .fromTypeSyntax(underlying.baseType),
                    attributes: underlying.attributes?.map(\.trimmed) ?? []
                )
            )

        case is ClassRestrictionTypeSyntax:
            return .classRestriction(ClassRestrictionSignature())

        default:
            return .unknown(
                UnknownSignature(
                    type: "\(type.syntaxNodeType)",
                    value: type.trimmed
                )
            )
        }
    }
}

protocol AnyTypeSignatureProtocol: CustomStringConvertible {
    func inferLiteralTypes() -> AnyTypeSignatureProtocol
    func asTypeSignature() -> TypeSignature
}
protocol TypeSignatureProtocol: AnyTypeSignatureProtocol, Equatable, Codable {}

extension TypeSignature {
    public struct SimpleSignature: TypeSignatureProtocol {
        public let name: String
        @DefaultEmpty public var genericArguments: [TypeSignature]

        public var description: String {
            if !genericArguments.isEmpty {
                let args = genericArguments.map { $0.description }.joined(separator: ", ")

                return "\(name)<\(args)>"
            } else {
                return name
            }
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            switch name {
            case "Optional", "Swift.Optional":
                if genericArguments.count == 1 {
                    return OptionalSignature(baseType: genericArguments[0])
                } else {
                    return self
                }

            case "Array", "Swift.Array":
                if genericArguments.count == 1 {
                    return ArraySignature(element: genericArguments[0])
                } else {
                    return self
                }

            case "Dictionary", "Swift.Dictionary":
                if genericArguments.count == 2 {
                    return DictionarySignature(
                        key: genericArguments[0],
                        value: genericArguments[1]
                    )
                } else {
                    return self
                }

            default:
                return self
            }
        }

        func asTypeSignature() -> TypeSignature {
            .simple(self)
        }
    }

    /// * `(Type1, Type2, ...)`
    /// * `(a: Type1, b: Type1, ...)`
    public struct TupleSignature: TypeSignatureProtocol {
        public let raw: String

        public var description: String {
            return raw
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            self
        }

        func asTypeSignature() -> TypeSignature {
            .tuple(self)
        }
    }

    /// * `(Type1, Type2, ...) -> ReturnType`
    /// * `(label1: Type1, label2: Type2, ...) -> ReturnType`
    public struct FunctionSignature: TypeSignatureProtocol {
        public let raw: String

        public var description: String {
            return raw
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            self
        }

        func asTypeSignature() -> TypeSignature {
            .function(self)
        }
    }

    /// * `Type.self`
    public struct MetaTypeSignature: TypeSignatureProtocol {
        public let baseType: TypeSignature

        public var description: String {
            return "\(baseType.description).self"
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            MetaTypeSignature(baseType: baseType.inferLiteralTypes())
        }

        func asTypeSignature() -> TypeSignature {
            .metatype(self)
        }
    }

    /// * `[Key: Type]`
    public struct DictionarySignature: TypeSignatureProtocol {
        public let key: TypeSignature
        public let value: TypeSignature

        public var description: String {
            return "[\(key.description): \(value.description)]"
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            DictionarySignature(key: key.inferLiteralTypes(), value: value.inferLiteralTypes())
        }

        func asTypeSignature() -> TypeSignature {
            .dictionary(self)
        }
    }

    /// * `[Element]`
    public struct ArraySignature: TypeSignatureProtocol {
        public let element: TypeSignature

        public var description: String {
            return "[\(element.description)]"
        }
        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            ArraySignature(element: element.inferLiteralTypes())
        }

        func asTypeSignature() -> TypeSignature {
            .array(self)
        }
    }

    /// * `Element?`
    public struct OptionalSignature: TypeSignatureProtocol {
        public let baseType: TypeSignature

        public var description: String {
            return "\(baseType.description)?"
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            OptionalSignature(baseType: baseType.inferLiteralTypes())
        }

        func asTypeSignature() -> TypeSignature {
            .optional(self)
        }
    }

    /// * `Element!`
    public struct ImplicitlyUnwrappedOptionalSignature: TypeSignatureProtocol {
        public let baseType: TypeSignature

        public var description: String {
            return "\(baseType.description)?"
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            ImplicitlyUnwrappedOptionalSignature(baseType: baseType.inferLiteralTypes())
        }

        func asTypeSignature() -> TypeSignature {
            .implicitlyUnwrappedOptional(self)
        }
    }
    public struct AttributedTypeSignature: TypeSignatureProtocol {
        public let base: TypeSignature
        public var attributes: [String]

        public var description: String {
            fatalError()
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            AttributedTypeSignature(base: base.inferLiteralTypes(), attributes: attributes)
        }

        func asTypeSignature() -> TypeSignature {
            .attributed(self)
        }
    }

    public struct UnknownSignature: TypeSignatureProtocol {
        public let type: String
        public let value: String

        public var description: String {
            return "\(value)"
        }
        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            self
        }

        func asTypeSignature() -> TypeSignature {
            .unknown(self)
        }
    }

    public struct CompositionSignature: TypeSignatureProtocol {
        public let elements: [TypeSignature]

        public var description: String {
            return elements.map(\.description).joined(separator: " & ")
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            CompositionSignature(elements: elements.map { $0.inferLiteralTypes() })
        }

        func asTypeSignature() -> TypeSignature {
            .composition(self)
        }
    }

    public struct MemberTypeSignature: TypeSignatureProtocol {
        public let name: String
        public let base: TypeSignature

        public var description: String {
            return "\(base.description).\(name)"
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            self
        }

        func asTypeSignature() -> TypeSignature {
            .memberType(self)
        }
    }

    public struct ClassRestrictionSignature: TypeSignatureProtocol {
        public var description: String {
            return "class"
        }

        func inferLiteralTypes() -> AnyTypeSignatureProtocol {
            self
        }

        func asTypeSignature() -> TypeSignature {
            .classRestriction(self)
        }
    }

}
