class DefaultRegistry: DependencyRegistry {
    private var isSetupFinished: Bool = false

    private let graph: DependencyGraph = DependencyGraph()

    private var registeredModules: Set<ObjectIdentifier> = []

    private(set) var container: DependencyContainer<GlobalScope>!

    private func registerModule(_ module: DependencyModule.Type) {
        if registeredModules.insert(ObjectIdentifier(module)).inserted {
            module.register(in: self)
        }

        for subModule in module.submodules {
            registerModule(subModule)
        }
    }

    func registerScope<Scope>(_ type: Scope.Type) where Scope: DependencyScope {
        self.graph.registerScope(type)
    }

    func setup(_ modules: DependencyModule.Type...) throws {

        for module in modules {
            self.registerModule(module)
        }
        isSetupFinished = true

        let dotPrinter = DotGraphPrinter(graph: graph)
        try dotPrinter.run()
        
        let errors = dotPrinter.resolved.errors
        for error in errors {
            print(error)
        }
        if !errors.isEmpty {
            fatalError()
        }

        print(dotPrinter.currentGraph)

        container = DependencyContainer(
            graph: self.graph,
            scope: GlobalScope(),
            parent: nil
        )
    }

    func registerSingleton<Value, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID],
        create: @escaping FactoryClosure<Value>
    ) {
        register(
            as: type,
            in: scope,
            qualifier: qualifier,
            provider: SingletonProvider<Value>(
                requirements: requirements,
                factory: create
            )
        )
    }

    func registerWeakSingleton<Value: AnyObject, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID],
        create: @escaping FactoryClosure<Value>
    ) {
        register(
            as: type,
            in: scope,
            qualifier: qualifier,
            provider: WeakSingletonProvider<Value>(
                requirements: requirements,
                factory: create
            )
        )
    }

    func registerFactory<Value, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID],
        create: @escaping FactoryClosure<Value>
    ) {
        register(
            as: type,
            in: scope,
            qualifier: qualifier,
            provider: FactoryProvider<Value>(
                requirements: requirements,
                factory: create
            )
        )
    }

    func registerAssistedFactory<Value, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID]
    ) {
        register(
            as: type,
            in: scope,
            qualifier: qualifier,
            provider: AssistedFactory<Value>(
                requirements: requirements
            )
        )
    }

    private func register<Value, Scope: DependencyScope>(
        as type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        provider: DependencyDeclaration
    ) {
        assert(!isSetupFinished)
        
        let typeID = TypeID(type, qualifier: qualifier)

        graph.addProvider(provider, in: scope, for: typeID)

    }

}
