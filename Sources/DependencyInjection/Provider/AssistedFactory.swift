struct AssistedFactory<Value>: Provider, DependencyDeclaration {

    var typeName: ProviderType { .assistedFactory }
    typealias Provided = Value

    let requirements: [String: TypeID]

    func resolve(provider: DependencyResolver) throws -> Provided {
        throw DependencyErrors.resolvingAssistedInject(type: TypeID(Value.self))
    }

    func checkIsResolvable() -> DependencyErrors? {
        DependencyErrors.resolvingAssistedInject(type: TypeID(Value.self))
    }
    
    func makeProvider() -> _AnyProvider {
        return self
    }
}
