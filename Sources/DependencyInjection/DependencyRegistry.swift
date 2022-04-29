public typealias FactoryClosure<Value> = (DependencyResolver) throws -> Value

public protocol DependencyRegistry {

    func registerSingleton<Value>(
        ofType type: Value.Type,
        requirements: [String: Any.Type],
        create: @escaping FactoryClosure<Value>
    )

    func registerWeakSingleton<Value: AnyObject>(
        ofType type: Value.Type,
        requirements: [String: Any.Type],
        create: @escaping FactoryClosure<Value>
    )

    func registerFactory<Value>(
        ofType type: Value.Type,
        requirements: [String: Any.Type],
        create: @escaping FactoryClosure<Value>
    )

    func registerAssistedFactory<Value>(
        ofType type: Value.Type,
        requirements: [String: Any.Type]
    )

    func setup(_ modules: DependencyModule.Type...) throws
}
