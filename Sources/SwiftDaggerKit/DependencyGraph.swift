import Foundation
import SwiftSyntax

public struct DependencyGraph: Codable {
    var imports: Set<String> = []
    var provides: [ProvidedDependency] = []
    var uses: [Injection] = []

    public init() {}

    public mutating func merge(_ other: DependencyGraph) {
        self.imports.formUnion(other.imports)
        self.provides.append(contentsOf: other.provides)
        self.uses.append(contentsOf: other.uses)
    }
}

struct Initializer: Codable {
    let arguments: [Argument]
    let range: SourceRange
}

struct Argument: Codable {
    let type: TypeDescriptor
    let firstName: String
    let secondName: String?
    let attributes: [String]
    let range: SourceRange
    
    var isAssisted: Bool {
        attributes.contains("Assisted") || attributes.contains("SwiftDagger.Assisted")
    }
}

struct Injection: Codable {
    let range: SourceRange
    let arguments: [Argument]
}

struct TypeDescriptor: Codable {
    let name: String
}

struct ProvidedDependency: Codable {
    let location: SourceLocation
    let type: TypeDescriptor
    let kind: Kind
    let arguments: [Argument]

    enum Kind: Codable {
        case provides
        case bind
        case injectable
    }
}
