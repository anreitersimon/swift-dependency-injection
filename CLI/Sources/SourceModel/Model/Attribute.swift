@_implementationOnly import SwiftSyntax

public struct Attribute: Codable, Equatable {
    public let name: String
    @DefaultEmpty public var arguments: [Argument] = []
    let sourceRange: SourceRange?

    public struct Argument: Codable, Equatable {
        public let name: String?
        public let argument: String
    }

    static func fromSyntax(
        _ syntax: AttributeListSyntax?,
        context: Context
    ) -> [Attribute] {
        return syntax?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .compactMap { attr in

                let args: [Argument]? = attr.argumentList?.map { arg in
                    return Argument(
                        name: arg.label?.trimmed,
                        argument: arg.expression.trimmed
                    )
                }

                return Attribute(
                    name: attr.attributeName.trimmed,
                    arguments: args ?? [],
                    sourceRange: attr.sourceRange(context: context)
                )

            } ?? []
    }
}
