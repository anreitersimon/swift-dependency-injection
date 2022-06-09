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

struct DotGraph: CustomStringConvertible {
    let label: String?
    let isTopLevel: Bool

    struct Node: Equatable, CustomStringConvertible {
        typealias ID = String
        let attributes: [String: String]

        var description: String {
            if attributes.isEmpty {
                return ""
            }

            let formatted =
                attributes
                .map { "\($0.key)=\"\($0.value)\"" }
                .joined(separator: " ")

            return "[\(formatted)]"
        }
    }

    struct Edge: Equatable {
        let from: Node.ID
        let to: Node.ID
    }

    var declaration: String = "digraph G"
    var subgraphs: [DotGraph] = []
    var nodes: [Node.ID: Node] = [:]
    var edges: [Edge] = []

    var description: String {
        var builder = "\(declaration) {\n"

        if let label = label {
            builder.append("label=\"\(label)\"\n")
        }

        for (key, node) in nodes {
            builder.append("  \(key)\(node);\n")
        }

        for (index, subgraph) in subgraphs.enumerated() {
            var s = subgraph
            s.declaration = "subgraph cluster_\(index)"

            builder.append("\n")
            builder.append(s.description)
            builder.append("\n")
        }

        if isTopLevel {
            for edge in recursiveEdges {
                builder.append("  \(edge.from) -> \(edge.to);\n")
            }
        }
        builder.append("}")

        return builder
    }

    var recursiveEdges: [Edge] {
        self.edges + subgraphs.flatMap(\.recursiveEdges)
    }
}

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

        //        let unreferenced = Set(self.resolved.graph.keys).subtracting(referencedNodes)
        //
        //        for node in unreferenced {
        //            dotGraph.edges.append(
        //                DotGraph.Edge(from: "root", to: node.description)
        //            )
        //        }
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

        //        if let sourceNode = source {
        //            currentGraph.edges.append(DotGraph.Edge(from: sourceNode.id, to: coordinate.id))
        //        }

        switch result {
        case .success(let resolved):
            if resolved.scope == currentScope {
                currentGraph.nodes[resolved.id] = DotGraph.Node(
                    attributes: [
                        "label": resolved.type.description,
                        "color": "green"
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
                            "color": "red"
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
    mutating func appendIfNotPresent(_ element: Element) {
        if !self.contains(element) {
            self.append(element)
        }
    }
}
