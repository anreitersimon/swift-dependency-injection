protocol _AnyProvider {
    func resolveAny(provider: DependencyResolver) throws -> Any
}

protocol DependencyDeclaration {
    var typeName: ProviderType { get }
    var requirements: [String: TypeID] { get }

    func checkIsResolvable() -> DependencyErrors?

    func makeProvider() -> _AnyProvider
}

enum ProviderType: Int, Comparable, CustomStringConvertible {
    case singleton, weakSingleton, factory, assistedFactory

    static func < (lhs: ProviderType, rhs: ProviderType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    var description: String {
        switch self {
        case .singleton:
            return "Singleton"
        case .weakSingleton:
            return "WeakSingleton"
        case .factory:
            return "Factory"
        case .assistedFactory:
            return "AssistedFactory"
        }
    }

}

extension _AnyProvider {
    func checkIsResolvable() -> DependencyErrors? {
        nil
    }
}

protocol Provider: _AnyProvider {
    associatedtype Provided

    func resolve(provider: DependencyResolver) throws -> Provided
}

extension Provider {
    func resolveAny(provider: DependencyResolver) throws -> Any {
        return try resolve(provider: provider)
    }
}
