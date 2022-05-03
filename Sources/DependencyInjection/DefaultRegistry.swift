struct Graph {
    private(set) var keys: [TypeID] = []
    private var factories: [TypeID: _AnyProvider] = [:]

    subscript(_ key: TypeID) -> _AnyProvider? {
        return factories[key]
    }

    mutating func addProvider(_ provider: _AnyProvider, for key: TypeID) {
        keys.append(key)
        factories[key] = provider
    }
}

class DefaultRegistry: DependencyRegistry, DependencyResolver {
    private var isSetupFinished: Bool = false

    private var graph = Graph()

    private var registeredModules: Set<ObjectIdentifier> = []

    private func registerModule(_ module: DependencyModule.Type) {
        if registeredModules.insert(ObjectIdentifier(module)).inserted {
            module.register(in: self)
        }

        for subModule in module.submodules {
            registerModule(subModule)
        }
    }

    func setup(_ modules: DependencyModule.Type...) throws {

        for module in modules {
            self.registerModule(module)
        }
        isSetupFinished = true

        let dotPrinter = DotGraphPrinter(graph: graph)
        try dotPrinter.run()
        
        print(dotPrinter.dotGraph)
        
        //try validator.run()
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

        graph.addProvider(provider, for: TypeID(type))
    }

    func resolve<Value>(_ type: Value.Type) -> Value {
        assert(isSetupFinished)

        let id = TypeID(type)
        let provider = graph[id]!
        return try! provider.resolveAny(provider: self) as! Value
    }

}
