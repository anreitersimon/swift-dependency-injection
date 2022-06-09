public protocol DependencyScope {
    associatedtype ParentScope: DependencyScope
}

// MARK: - Default Scopes -

extension Never: DependencyScope {
    public typealias ParentScope = Never
    static let scopeID = ScopeID(Never.self)
}

public struct GlobalScope: DependencyScope, Provides_GlobalScope {
    public typealias ParentScope = Never
}

public protocol Provides_GlobalScope {}
