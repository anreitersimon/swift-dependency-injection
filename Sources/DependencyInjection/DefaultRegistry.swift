class DefaultRegistry: DependencyRegistry, DependencyResolver {
    private var isSetupFinished: Bool = false
    private var factories: [TypeID: _AnyProvider] = [:]

    func setup(_ modules: DependencyModule.Type...) throws {
        var visited: Set<ObjectIdentifier> = []

        let flatModules = modules.flatMap { [$0] + $0.submodules }
        for module in flatModules where visited.insert(ObjectIdentifier(module)).inserted {
            
            print("Registering: \(module)")

            module.register(in: self)
        }
        isSetupFinished = true

        let validator = Validator(graph: factories)
        try validator.run()
    }

    func registerSingleton<Value>(
        ofType type: Value.Type,
        requirements: [String: Any.Type],
        create: @escaping FactoryClosure<Value>
    ) {
        register(
            as: type,
            provider: SingletonProvider<Value>(
                requirements: requirements.mapValues(TypeID.init),
                factory: create
            )
        )
    }

    func registerWeakSingleton<Value: AnyObject>(
        ofType type: Value.Type,
        requirements: [String: Any.Type],
        create: @escaping FactoryClosure<Value>
    ) {
        register(
            as: type,
            provider: WeakSingletonProvider<Value>(
                requirements: requirements.mapValues(TypeID.init),
                factory: create
            )
        )
    }

    func registerFactory<Value>(
        ofType type: Value.Type,
        requirements: [String: Any.Type],
        create: @escaping FactoryClosure<Value>
    ) {
        register(
            as: type,
            provider: FactoryProvider<Value>(
                requirements: requirements.mapValues(TypeID.init),
                factory: create
            )
        )
    }

    func registerAssistedFactory<Value>(
        ofType type: Value.Type,
        requirements: [String: Any.Type]
    ) {
        register(
            as: type,
            provider: AssistedFactory<Value>(
                requirements: requirements.mapValues(TypeID.init)
            )
        )
    }

    private func register<Value>(
        as type: Value.Type,
        provider: _AnyProvider
    ) {
        assert(!isSetupFinished)
        factories[TypeID(type)] = provider
    }

    func resolve<Value>(_ type: Value.Type) -> Value {
        assert(isSetupFinished)

        let id = TypeID(type)
        let provider = factories[id]!
        return try! provider.resolveAny(provider: self) as! Value
    }

}
