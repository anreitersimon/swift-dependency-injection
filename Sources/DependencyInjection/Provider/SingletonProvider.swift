class SingletonProvider<Value>: Provider, DependencyDeclaration {

    var typeName: ProviderType { .singleton }
    
    typealias Provided = Value
    let factory: FactoryClosure<Value>
    let requirements: [String: TypeID]
 
    var value: Value?

    init(
        requirements: [String: TypeID],
        factory: @escaping FactoryClosure<Value>
    ) {
        self.requirements = requirements
        self.factory = factory
    }

    func resolve(provider: DependencyResolver) throws -> Provided {
        let resolved: Value

        if let value = value {
            resolved = value
        } else {
            resolved = try factory(provider)
            self.value = resolved
        }
        return resolved
    }
    
    func makeProvider() -> _AnyProvider {
        SingletonProvider(requirements: requirements, factory: factory)
    }
}
