protocol _AnyProvider {
    var requirements: [String: TypeID] { get }

    func resolveAny(provider: DependencyResolver) throws -> Any

    func checkIsResolvable() -> DependencyErrors?
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
