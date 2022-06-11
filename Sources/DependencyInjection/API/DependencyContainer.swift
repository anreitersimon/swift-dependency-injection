public class DependencyContainer<Scope: DependencyScope> {

    init(
        graph: DependencyGraph,
        scope: Scope,
        parent: DependencyContainer<Scope.ParentScope>?
    ) {
        self.graph = graph
        self.scope = scope
        self.parent = parent
        self.providers = graph.providers(for: Scope.self)
    }

    let graph: DependencyGraph
    let providers: [TypeID: _AnyProvider]
    let scope: Scope
    let parent: DependencyContainer<Scope.ParentScope>?

    public func childContainer<ChildScope: DependencyScope>(
        scope: ChildScope
    ) -> DependencyContainer<ChildScope> where ChildScope.ParentScope == Scope {
        DependencyContainer<ChildScope>(
            graph: graph,
            scope: scope,
            parent: self
        )
    }
}

extension DependencyContainer: DependencyResolver {

    public func resolve<Value>(_ type: Value.Type, qualifier: QualifierDefinition.Type) -> Value {
        if let provider = self.providers[TypeID(type, qualifier: qualifier)] {
            return try! provider.resolveAny(provider: self) as! Value
        } else {
            return parent!.resolve(type, qualifier: qualifier)
        }
    }
}
