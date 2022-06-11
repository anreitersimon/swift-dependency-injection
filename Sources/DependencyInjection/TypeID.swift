public struct TypeID:
    Hashable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    let typeID: ObjectIdentifier
    let qualifierID: ObjectIdentifier

    let type: Any.Type
    let qualifier: QualifierDefinition.Type
    
    var qualifierName: String {
        prettyTypeName(of: qualifier).replacingOccurrences(of: "DependencyInjection.Qualifiers.", with: "")
    }
    var typeName: String {
        prettyTypeName(of: type)
    }

    public init(_ type: Any.Type, qualifier: QualifierDefinition.Type) {
        self.typeID = ObjectIdentifier(type)
        self.type = type
        self.qualifierID = ObjectIdentifier(qualifier)
        self.qualifier = qualifier
    }

    public static func == (lhs: TypeID, rhs: TypeID) -> Bool {
        return lhs.typeID == rhs.typeID && lhs.qualifierID == rhs.qualifierID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(typeID)
        hasher.combine(qualifierID)
    }

    public var id: String {
        return "\(typeName)__\(qualifierName)"
    }

    public var description: String {
        if qualifier == Qualifiers.Default.self {
            return "\(typeName)"
        } else {
            return "@\(qualifierName)\n\(typeName)"
        }
    }

    public var debugDescription: String {
        return id
    }
}

func prettyTypeName(of type: Any.Type) -> String {
    
    var str = ""
    debugPrint(type, terminator: "", to: &str)
    
    return str.sanitizeTypeName
}

extension String {
    fileprivate var sanitizeTypeName: String {
        if let range = self.range(of: "(extension in ") {
            let prefix = self[..<range.lowerBound]
            var suffix = self[range.upperBound...]
            suffix = suffix.drop(while: { $0 != ":" })
            suffix = suffix.dropFirst()

            return "\(prefix)\(suffix)".sanitizeTypeName

        } else {
            return self
        }
    }
}
