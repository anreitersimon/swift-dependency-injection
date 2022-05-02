import Foundation

public struct DependencyValidationError: Error {
    public let issues: [Error]
}

extension Collection {
    func withIsLast() -> [(isLast: Bool, element: Element)] {
        let count = self.count
        return zip(0..., self).map { (index, element) in
            (index == count - 1, element)
        }
    }
}

class Validator {
    struct PathComponent: CustomStringConvertible, CustomDebugStringConvertible {
        let name: String
        let type: TypeID

        var description: String {
            if name == "*" {
                return "\(type.description)"
            } else {
                return "\(name): \(type.description)"
            }
        }

        var debugDescription: String {
            return description
        }
    }

    init(graph: [TypeID: _AnyProvider]) {
        self.graph = graph
    }

    let graph: [TypeID: _AnyProvider]
    var path: [PathComponent] = []
    var issues: [DependencyErrors] = []
    var visited: Set<TypeID> = []

    func run() throws {
        for (isLast, type) in self.graph.keys.withIsLast() {
            check(type, prefix: "", isLast: isLast)
        }

        if !issues.isEmpty {

            for issue in issues {
                print(issue.description)
            }

            throw DependencyValidationError(issues: issues)
        }
    }

    func check(
        _ type: TypeID,
        name: String = "*",
        prefix outerPrefix: String,
        isLast: Bool
    ) {

        let inserted = visited.insert(type).inserted

        //▼▶
        func log(_ msg: String) {
            let symbol = (inserted && !isLast) ? "▼" : "▶"
            print("\(outerPrefix)\(symbol) \(type) \(msg)")
        }

        let prefix = isLast ? "\(outerPrefix)   " : "\(outerPrefix)   "
        
        guard inserted else {
            log("")
            return
        }

        guard !path.contains(where: { $0.type == type }) else {

            log("💥 Cycle")
            issues.append(.cycle(type: type.type, path: path))
            return
        }

        path.append(PathComponent(name: name, type: type))
        defer {
            path.removeLast()
        }

        if let provider = graph[type] {
            if let error = provider.checkIsResolvable() {
                log("💥 \(error)")
                issues.append(error)
            } else {
                log("")
                for (isLast, requirement) in provider.requirements.withIsLast() {
                    check(
                        requirement.value,
                        name: requirement.key,
                        prefix: prefix,
                        isLast: isLast
                    )
                }

            }
        } else {
            issues.append(DependencyErrors.noProvider(type: type.type))
        }
    }
}

enum DependencyErrors: Error, CustomDebugStringConvertible, CustomStringConvertible {
    case setupNotFinished(type: Any.Type)
    case noProvider(type: Any.Type)
    case resolvingAssistedInject(type: Any.Type)
    case cycle(type: Any.Type, path: [Validator.PathComponent])

    var description: String {
        switch self {
        case .setupNotFinished:
            return "Setup Not Finished"
        case .noProvider(let type):
            return "No Provider registered for \(type)"
        case .resolvingAssistedInject(let type):
            return "Types using @Assisted annotation cannot be directly Injected \(type)"
        case .cycle(let type, let path):
            return "Cycle \(type) Path: \(path.map(\.description).joined(separator: " -> "))"
        }
    }

    var debugDescription: String { description }
}
