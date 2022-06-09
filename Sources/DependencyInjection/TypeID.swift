struct TypeID:
    Hashable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    let id: ObjectIdentifier
    let type: Any.Type

    init(_ type: Any.Type) {
        self.id = ObjectIdentifier(type)
        self.type = type
    }

    public static func == (lhs: TypeID, rhs: TypeID) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var description: String {
        var str = ""
        debugPrint(self.type, terminator: "", to: &str)
        return str
    }

    var debugDescription: String {
        return description
    }
}

