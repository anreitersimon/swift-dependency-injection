class DotGraphPrinter: DependencyVisitor {

    var graphs: [DotGraph] = [DotGraph(label: nil, isTopLevel: true)]
    var edges: [DotGraph.Edge] = []
    var referencedNodes: Set<DependencyGraph.Coordinate> = []

    var currentGraph: DotGraph {
        get { graphs[graphs.count - 1] }
        set { graphs[graphs.count - 1] = newValue }
    }

    override func run() throws {
        try super.run()

        self.currentGraph.edges = self.edges
    }

    override func visit(_ scope: ScopeID) {
        graphs.append(DotGraph(label: scope.description, isTopLevel: false))
    }

    override func postVisit(_ scope: ScopeID) {

        let graph = graphs.removeLast()

        currentGraph.subgraphs.append(graph)
    }

    override func visit(_ coordinate: DependencyGraph.Coordinate) {

    }

    override func postVisit(
        _ coordinate: DependencyGraph.Coordinate,
        source: DependencyGraph.Coordinate?,
        result: ResolveResult
    ) {
        switch result {
        case .success(let resolved):
            if resolved.scope == currentScope {
                currentGraph.nodes[resolved.id] = DotGraph.Node(
                    attributes: [
                        "label": resolved.type.description
                    ]
                )
            }
            if let sourceNode = source {
                edges.appendIfNotPresent(
                    DotGraph.Edge(from: sourceNode.id, to: resolved.id)
                )
            }

        case .failure:

            if graph[coordinate] != nil {
                if currentScope == coordinate.scope {
                    currentGraph.nodes[coordinate.id] = DotGraph.Node(
                        attributes: [
                            "label": coordinate.type.description,
                            "color": "red",
                        ]
                    )
                }
                if let sourceNode = source {
                    edges.appendIfNotPresent(
                        DotGraph.Edge(from: sourceNode.id, to: coordinate.id)
                    )
                }
            }
        }
        super.postVisit(coordinate, source: source, result: result)

    }

}

extension Result {
    var error: Failure? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }

    var success: Success? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

extension Array where Element: Equatable {
    fileprivate mutating func appendIfNotPresent(_ element: Element) {
        if !self.contains(element) {
            self.append(element)
        }
    }
}
