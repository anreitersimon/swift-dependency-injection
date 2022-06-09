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

extension ScopeID {
    static let never = ScopeID(Never.self)
    static let global = ScopeID(GlobalScope.self)
}


extension DependencyScope {

    static func collectType(into parents: inout [ScopeID]) {
        let id = ScopeID(Self.self)

        if id == ScopeID.never {
            return
        }
        if parents.contains(id) {
            return
        }

        parents.append(id)

        ParentScope.collectType(into: &parents)
    }

    static var applicableScopes: [ScopeID] {
        var types: [ScopeID] = []
        Self.collectType(into: &types)

        return types
    }
}
