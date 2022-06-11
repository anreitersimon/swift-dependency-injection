class DependencyGraph {

    subscript(coordinate: Coordinate) -> DependencyDeclaration? {
        return self.scopeToGraph[coordinate.scope]?[coordinate.type]
    }

    struct Coordinate: Hashable {
        let scope: ScopeID
        let type: TypeID

        var id: String {
            return "\(scope.description).\(type.id)"
                .replacingOccurrences(of: ".", with: "_")
        }
    }

    var scopeToGraph: [ScopeID: ScopeGraph] = [:]

    func providers<Scope: DependencyScope>(for scope: Scope.Type) -> [TypeID: _AnyProvider] {
        return self.scopeToGraph[ScopeID(scope)]?.declarations.mapValues {
            $0.makeProvider()
        } ?? [:]
    }

    class ScopeGraph {

        init(id: ScopeID, parent: ScopeGraph?) {
            self.id = id
            self.parent = parent
        }

        let id: ScopeID
        let parent: ScopeGraph?
        private(set) var keys: [TypeID] = []
        fileprivate var declarations: [TypeID: DependencyDeclaration] = [:]

        subscript(_ key: TypeID) -> DependencyDeclaration? {
            return declarations[key]
        }

        func addProvider(_ declaration: DependencyDeclaration, for key: TypeID) {
            keys.append(key)
            declarations[key] = declaration
        }
    }

    func addProvider<Scope: DependencyScope>(
        _ declaration: DependencyDeclaration,
        in scope: Scope.Type,
        for key: TypeID
    ) {
        self.registerScope(scope)

        scopeToGraph[ScopeID(scope)]!.addProvider(declaration, for: key)
    }

    @discardableResult
    func registerScope<Scope: DependencyScope>(_ scope: Scope.Type) -> ScopeGraph {

        let id = ScopeID(Scope.self)

        if let graph = scopeToGraph[id] {
            return graph
        }

        let parent: ScopeGraph?

        if Scope.ParentScope.self == Never.self {
            parent = nil
        } else {
            parent = registerScope(Scope.ParentScope.self)
        }

        let graph = ScopeGraph(id: id, parent: parent)

        scopeToGraph[id] = graph

        return graph
    }

}
