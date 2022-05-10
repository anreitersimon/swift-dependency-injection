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

enum DependencyErrors: Error, CustomDebugStringConvertible, CustomStringConvertible {
    case setupNotFinished(type: TypeID)
    case noProvider(type: TypeID)
    case resolvingAssistedInject(type: TypeID)
    case cycle(type: TypeID, path: [TypeID])
    case scopeNotFound(ScopeID)
    case nested([String: DependencyErrors])

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
        case .scopeNotFound(let scope):
            return "Scope Not Found: \(scope)"
        case .nested:
            return ""
        }
    }

    var debugDescription: String { description }
}
