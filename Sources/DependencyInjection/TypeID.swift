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

struct ScopeID:
    Hashable,
    CustomStringConvertible,
    CustomDebugStringConvertible
{
    let id: ObjectIdentifier
    let type: Any.Type

    init<T: DependencyScope>(_ type: T.Type) {
        self.id = ObjectIdentifier(type)
        self.type = type
    }

    public static func == (lhs: ScopeID, rhs: ScopeID) -> Bool {
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
        return self.description
    }
}
