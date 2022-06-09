struct ResolvedGraph {
    init(graph: DependencyGraph) {
        self.graph = graph
    }

    let graph: DependencyGraph
    private var resolved: [DependencyGraph.Coordinate: ResolveResult] = [:]

    subscript(_ type: DependencyGraph.Coordinate) -> ResolveResult? {
        get { resolved[type] }
        set { resolved[type] = newValue }
    }
}

typealias ResolveResult = Result<DependencyGraph.Coordinate, DependencyErrors>

class DependencyVisitor {
    typealias Coordinate = DependencyGraph.Coordinate

    init(graph: DependencyGraph) {
        self.resolved = ResolvedGraph(graph: graph)
    }

    var currentScope: ScopeID = .global
    var graph: DependencyGraph { resolved.graph }
    var resolved: ResolvedGraph
    var path: [Coordinate] = []

    func run() throws {
        runVisit(ScopeID.global)
    }

    func runVisit(_ scope: ScopeID) {
        guard let scopeGraph = graph.scopeToGraph[scope] else {
            return
        }
        let oldScope = currentScope

        currentScope = scope
        defer { currentScope = oldScope }

        visit(scope)

        let childScopes = graph.scopeToGraph.values.filter { $0.parent?.id == scope }

        for key in scopeGraph.keys {
            runVisit(Coordinate(scope: scope, type: key), source: nil)
        }

        for childScope in childScopes {
            runVisit(childScope.id)
        }

        postVisit(scope)

    }

    func visit(_ scope: ScopeID) {

    }

    func postVisit(_ scope: ScopeID) {

    }

    func visit(_ coordinate: DependencyGraph.Coordinate) {

    }

    func postVisit(
        _ coordinate: DependencyGraph.Coordinate,
        source: DependencyGraph.Coordinate?,
        result: ResolveResult
    ) {

    }

    @discardableResult
    func runVisit(
        _ coordinate: DependencyGraph.Coordinate,
        source: DependencyGraph.Coordinate?
    ) -> ResolveResult {
        let result: ResolveResult

        visit(coordinate)

        if let cached = resolved[coordinate] {
            postVisit(coordinate, source: source, result: cached)
            // Already resolved
            return cached
        }

        defer {
            postVisit(coordinate, source: source, result: result)
        }

        if path.contains(coordinate) {
            result = .failure(
                .cycle(
                    type: coordinate.type,
                    path: path.map(\.type)
                )
            )
        } else {

            path.append(coordinate)

            defer {
                path.removeLast()
            }

            if let scopeGraph = graph.scopeToGraph[coordinate.scope] {

                if let (effectiveScope, provider) = scopeGraph.findProvider(for: coordinate.type) {
                    if let error = provider.checkIsResolvable() {
                        result = .failure(error)
                    } else {
                        var errors: [String: DependencyErrors] = [:]
                        let source = Coordinate(scope: effectiveScope.id, type: coordinate.type)
                        for requirement in provider.requirements {
                            errors[requirement.key] =
                                runVisit(
                                    Coordinate(scope: effectiveScope.id, type: requirement.value),
                                    source: source
                                ).error
                        }
                        result =
                            errors.isEmpty
                            ? .success(Coordinate(scope: effectiveScope.id, type: coordinate.type))
                            : .failure(.nested(errors))
                    }
                } else {
                    result = .failure(.noProvider(type: coordinate.type))
                }
            } else {
                result = .failure(.scopeNotFound(coordinate.scope))
            }
        }

        resolved[coordinate] = result

        return result
    }

}
extension DependencyGraph.ScopeGraph {
    func findProvider(for type: TypeID) -> (DependencyGraph.ScopeGraph, DependencyDeclaration)? {
        sequence(first: self, next: { $0.parent }).lazy
            .compactMap { sg in
                guard let p = sg[type] else { return nil }
                return (sg, p)
            }
            .first
    }
}
