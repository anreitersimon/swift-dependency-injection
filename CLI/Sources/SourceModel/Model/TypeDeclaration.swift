@_implementationOnly import SwiftSyntax

public struct TypeDeclaration: Codable, Equatable, DeclarationScope {
    public let kind: Kind
    public let module: String
    public let name: String
    public let scope: String

    @DefaultEmpty
    public var modifiers: [Modifier]
    @DefaultEmpty
    public var generics: Generics = .empty
    @DefaultEmpty
    public var inheritedTypes: [TypeSignature] = []
    @DefaultEmpty
    public var typealiases: [TypeAlias] = []
    @DefaultEmpty
    public var initializers: [Initializer] = []
    @DefaultEmpty
    public var variables: [Variable] = []
    @DefaultEmpty
    public var functions: [Function] = []
    @DefaultEmpty
    public var types: [TypeDeclaration] = []

    public let sourceRange: SourceRange?

    public var allAvailableInitializers: [Initializer] {
        if let i = implicitMemberwiseInitializer {
            return [i]
        } else {
            return self.initializers
        }
    }

    public var implicitMemberwiseInitializer: Initializer? {
        guard self.kind == .struct && self.initializers.isEmpty else {
            return nil
        }

        let storedVariables = self.variables.filter(\.isStored)

        return Initializer(
            arguments: storedVariables.map {
                Function.Argument(
                    firstName: $0.name,
                    secondName: nil,
                    type: $0.type,
                    attributes: $0.attributes,
                    defaultValue: $0.defaultValue,
                    sourceRange: $0.sourceRange
                )
            },
            sourceRange: self.sourceRange
        )
    }

    public enum Kind: String, Codable {
        case `struct`
        case `class`
        case `enum`
        case `protocol`
    }

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
        case `open`
        case `dynamic`
        case `final`
        case `indirect`
    }

    var path: String { name }

    public var fullyQualifiedName: String { "\(scope).\(name)" }
    public var accessLevel: AccessLevel { modifiers.accessLevel }
}

public struct Generics: Equatable, Codable, CanBeEmpty {
    public static func createEmpty() -> Generics {
        return .empty
    }
    
    @DefaultEmpty public var parameters: [Parameter]
    @DefaultEmpty public var requirements: [Requirement]
    public let parametersRange: SourceRange?
    public let requirementsRange: SourceRange?

    public var isEmpty: Bool {
        return parameters.isEmpty && requirements.isEmpty
    }

    public static let empty = Generics(
        parameters: [],
        requirements: [],
        parametersRange: nil,
        requirementsRange: nil
    )

    public struct Requirement: Equatable, Codable {
        public let isSameType: Bool

        public let left: TypeSignature
        public let right: TypeSignature
    }

    public struct Parameter: Equatable, Codable {
        public let name: String
        public let inheritedType: TypeSignature?
    }

    static func from(
        parameterClause: GenericParameterClauseSyntax?,
        whereClause: GenericWhereClauseSyntax?,
        context: Context
    ) -> Generics {
        let params = parameterClause?.genericParameterList.map {
            Parameter(
                name: $0.name.trimmed,
                inheritedType: $0.inheritedType.map(TypeSignature.fromTypeSyntax(_:))
            )
        }

        let requirements: [Requirement]? = whereClause?.requirementList.compactMap {
            if let sameType = $0.body.as(SameTypeRequirementSyntax.self) {
                return .init(
                    isSameType: true,
                    left: .fromTypeSyntax(sameType.leftTypeIdentifier),
                    right: .fromTypeSyntax(sameType.rightTypeIdentifier)
                )

            } else if let conformance = $0.body.as(ConformanceRequirementSyntax.self) {
                return .init(
                    isSameType: false,
                    left: .fromTypeSyntax(conformance.leftTypeIdentifier),
                    right: .fromTypeSyntax(conformance.rightTypeIdentifier)
                )
            } else {
                return nil
            }
        }

        return Generics(
            parameters: params ?? [],
            requirements: requirements ?? [],
            parametersRange: parameterClause?.sourceRange(context: context),
            requirementsRange:
                whereClause?.sourceRange(context: context)
        )
    }
}
