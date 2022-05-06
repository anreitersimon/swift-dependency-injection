public class DependencyContainer<Scope: DependencyScope> {

    init(
        graph: DependencyGraph,
        scope: Scope,
        parent: DependencyContainer<Scope.Parent>?
    ) {
        self.graph = graph
        self.scope = scope
        self.parent = parent
        self.providers = graph.providers(for: Scope.self)
    }

    let graph: DependencyGraph
    let providers: [TypeID: _AnyProvider]
    let scope: Scope
    let parent: DependencyContainer<Scope.Parent>?

    func childContainer<ChildScope: DependencyScope>(
        scope: ChildScope
    ) -> DependencyContainer<ChildScope> where ChildScope.Parent == Scope {
        DependencyContainer<ChildScope>(
            graph: graph,
            scope: scope,
            parent: self
        )
    }
}

extension DependencyContainer: DependencyResolver {

    public func resolve<Value>(_ type: Value.Type) -> Value {
        if let provider = self.providers[TypeID(type)] {
            return try! provider.resolveAny(provider: self) as! Value
        } else {
            return parent!.resolve(type)
        }
    }
}
