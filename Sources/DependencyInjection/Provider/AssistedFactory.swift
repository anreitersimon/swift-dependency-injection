struct AssistedFactory<Value>: Provider {
    typealias Provided = Value

    let requirements: [String: TypeID]

    func resolve(provider: DependencyResolver) throws -> Provided {
        throw DependencyErrors.resolvingAssistedInject(type: Value.self)
    }

    func checkIsResolvable() -> DependencyErrors? {
        DependencyErrors.resolvingAssistedInject(type: Value.self)
    }
}
