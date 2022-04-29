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
        return String(describing: self.type)
    }

    var debugDescription: String {
        return String(describing: self.type)

    }
}
