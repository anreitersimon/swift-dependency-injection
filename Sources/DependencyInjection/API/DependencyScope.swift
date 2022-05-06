public protocol DependencyScope {
    associatedtype Parent: DependencyScope = Never
}
extension Never: DependencyScope {
    static let scopeID = ScopeID(Never.self)
}

public struct GlobalScope: DependencyScope {}
public struct ApplicationScope: DependencyScope {}

extension DependencyScope {

    static func collectType(into parents: inout [ScopeID]) {
        let id = ScopeID(Self.self)

        if id == Never.scopeID {
            return
        }
        if parents.contains(id) {
            return
        }

        parents.append(id)

        Parent.collectType(into: &parents)
    }

    static var applicableScopes: [ScopeID] {
        var types: [ScopeID] = []
        Self.collectType(into: &types)

        return types
    }
}
