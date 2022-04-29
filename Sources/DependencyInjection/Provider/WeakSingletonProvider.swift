class WeakSingletonProvider<Value: AnyObject>: Provider {
    typealias Provided = Value

    let requirements: [String: TypeID]
    let factory: (DependencyResolver) throws -> Value

    weak var value: Value?

    init(
        requirements: [String: TypeID],
        factory: @escaping (DependencyResolver) throws -> Provided
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
    
}
