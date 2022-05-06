class FactoryProvider<Value>: Provider, DependencyDeclaration {
    var typeName: ProviderType { .factory }
    
    typealias Provided = Value
    let factory: FactoryClosure<Value>
    let requirements: [String: TypeID]

    init(
        requirements: [String: TypeID],
        factory: @escaping FactoryClosure<Value>
    ) {
        self.requirements = requirements
        self.factory = factory
    }

    func resolve(provider: DependencyResolver) throws -> Provided {
        return try factory(provider)
    }
    
    func makeProvider() -> _AnyProvider {
        return FactoryProvider(requirements: requirements, factory: factory)
    }
}
