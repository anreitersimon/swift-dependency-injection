
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
