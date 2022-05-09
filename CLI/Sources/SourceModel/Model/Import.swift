public struct Import: Codable, Hashable, CustomStringConvertible {
    @DefaultEmpty public var modifers: [String]
    @DefaultEmpty public var attributes: [String]
    public let kind: TypeDeclaration.Kind?
    public let path: String

    public var description: String {
        var builder = ""

        for modifer in modifers {
            builder.append(modifer)
            builder.append(" ")
        }

        builder.append("import ")
        if let kind = kind {
            builder.append(kind.rawValue)
            builder.append(" ")
        }

        builder.append(path)

        return builder
    }
}
