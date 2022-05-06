struct ResolvedGraph {
    init(graph: DependencyGraph) {
        self.graph = graph
    }

    let graph: DependencyGraph
    private var resolved: [TypeID: ResolveResult] = [:]

    subscript(_ type: TypeID) -> ResolveResult? {
        get { resolved[type] }
        set { resolved[type] = newValue }
    }
}

typealias ResolveResult = Result<Void, DependencyErrors>

class DependencyVisitor {

    init(graph: DependencyGraph) {
        self.resolved = ResolvedGraph(graph: graph)
    }

    var resolved: ResolvedGraph
    var path: [PathComponent] = []

    func run() throws {

//        for key in resolved.graph.keys {
//            _ = runVisit(PathComponent(name: "<root>", type: key))
//        }
    }

    func visit(_ type: TypeID) {

    }

    func postVisit(_ type: TypeID, result: ResolveResult) {

    }

    func runVisit(
        _ pathComponent: PathComponent
    ) -> ResolveResult {

        let result: ResolveResult

        visit(pathComponent.type)

        if let cached = resolved[pathComponent.type] {
            // Already resolved
            return cached
        }

        defer {
            postVisit(pathComponent.type, result: result)
        }

        if path.contains(where: { $0.type == pathComponent.type }) {
            result = .failure(
                .cycle(
                    type: pathComponent.type,
                    path: path.map(\.type)
                )
            )
        } else {

            path.append(pathComponent)
            defer {
                path.removeLast()
            }
            
            fatalError()
//
//            if let provider = resolved.graph[pathComponent.type] {
//                if let error = provider.checkIsResolvable() {
//                    result = .failure(error)
//                } else {
//                    var errors: [String: DependencyErrors] = [:]
//                    for requirement in provider.requirements {
//                        errors[requirement.key] =
//                            runVisit(
//                                PathComponent(name: requirement.key, type: requirement.value)
//                            ).error
//                    }
//                    result = errors.isEmpty ? .success(()) : .failure(.nested(errors))
//                }
//            } else {
//                result = .failure(.noProvider(type: pathComponent.type))
//            }

        }

        resolved[pathComponent.type] = result

        return result
    }

    struct PathComponent: CustomStringConvertible, CustomDebugStringConvertible {
        let name: String
        let type: TypeID

        var description: String {
            if name == "<root>" {
                return "\(type.description)"
            } else {
                return "\(name): \(type.description)"
            }
        }

        var debugDescription: String {
            return description
        }
    }
}

struct DotGraph: CustomStringConvertible {
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

    var nodes: [Node.ID: Node] = [:]
    var edges: [Edge] = []

    var description: String {
        var builder = "digraph G {\n"

        builder.append("# Nodes\n")

        for (key, node) in nodes {
            builder.append("  \(key)\(node);\n")
        }

        builder.append("# Edges \n")

        for edge in edges {
            builder.append("  \(edge.from) -> \(edge.to);\n")
        }

        builder.append("}")

        return builder
    }
}

class DotGraphPrinter: DependencyVisitor {

    var dotGraph = DotGraph()

    var sourceNode: TypeID? { path.last?.type }

    var referencedNodes: Set<TypeID> = []
    
    override func run() throws {
        try super.run()
        
//        let unreferenced = Set(self.resolved.graph.keys).subtracting(referencedNodes)
//        
//        for node in unreferenced {
//            dotGraph.edges.append(
//                DotGraph.Edge(from: "root", to: node.description)
//            )
//        }
    }

    override func visit(_ type: TypeID) {
        if let sourceNode = sourceNode {
            referencedNodes.insert(type)
            dotGraph.edges.append(
                DotGraph.Edge(from: sourceNode.description, to: type.description)
            )
        }
    }

    override func postVisit(
        _ type: TypeID,
        result: ResolveResult
    ) {
        let id = type.description
        dotGraph.nodes[id] = DotGraph.Node(
            attributes: [
                "color": result.isSuccess ? "green" : "red"
            ]
        )
    }

}

extension Result {
    var error: Failure? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}
