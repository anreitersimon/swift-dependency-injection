public protocol DependencyScope {
    associatedtype ParentScope: DependencyScope
}
extension Never: DependencyScope {
    public typealias ParentScope = Never
    static let scopeID = ScopeID(Never.self)
}

extension ScopeID {
    static let never = ScopeID(Never.self)
    static let global = ScopeID(GlobalScope.self)
}

public protocol Provides_GlobalScope {}
public protocol Provides_ApplicationScope: Provides_GlobalScope {}

public struct GlobalScope: DependencyScope, Provides_GlobalScope {
    public typealias ParentScope = Never
}
public struct ApplicationScope: DependencyScope, Provides_ApplicationScope {
    public typealias ParentScope = GlobalScope
}

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

        ParentScope.collectType(into: &parents)
    }

    static var applicableScopes: [ScopeID] {
        var types: [ScopeID] = []
        Self.collectType(into: &types)

        return types
    }
}
