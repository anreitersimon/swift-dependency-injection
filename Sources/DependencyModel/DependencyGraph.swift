import Foundation
import SwiftSyntax

public struct DependencyGraph: Codable {
    public var imports: Set<String> = []
    public var provides: [ProvidedDependency] = []
    public var uses: [Injection] = []

    public init() {}

    public mutating func merge(_ other: DependencyGraph) {
        self.imports.formUnion(other.imports)
        self.provides.append(contentsOf: other.provides)
        self.uses.append(contentsOf: other.uses)
    }
}

public struct Initializer: Codable {
    public let arguments: [Argument]
    public let range: SourceRange

    public init(arguments: [Argument], range: SourceRange) {
        self.arguments = arguments
        self.range = range
    }

}

public struct Argument: Codable {
    public let type: TypeDescriptor
    public let firstName: String
    public let secondName: String?
    public let attributes: [String]
    public let range: SourceRange

    public init(
        type: TypeDescriptor,
        firstName: String,
        secondName: String?,
        attributes: [String],
        range: SourceRange
    ) {
        self.type = type
        self.firstName = firstName
        self.secondName = secondName
        self.attributes = attributes
        self.range = range
    }

    public var isAssisted: Bool {
        attributes.contains("Assisted") || attributes.contains("SwiftDagger.Assisted")
    }
}

public struct Injection: Codable {
    public let range: SourceRange
    public let arguments: [Argument]

    public init(range: SourceRange, arguments: [Argument]) {
        self.range = range
        self.arguments = arguments
    }
}

public struct TypeDescriptor: Codable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct ProvidedDependency: Codable {

    public let location: SourceLocation
    public let type: TypeDescriptor
    public let kind: Kind
    public let arguments: [Argument]

    public init(
        location: SourceLocation,
        type: TypeDescriptor,
        kind: ProvidedDependency.Kind,
        arguments: [Argument]
    ) {
        self.location = location
        self.type = type
        self.kind = kind
        self.arguments = arguments
    }

    public enum Kind: Codable {
        case provides
        case bind
        case injectable
    }
}
