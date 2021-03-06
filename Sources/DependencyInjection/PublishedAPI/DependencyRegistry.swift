public typealias FactoryClosure<Value> = (DependencyResolver) throws -> Value

public protocol DependencyRegistry {
    
    func registerScope<Scope: DependencyScope>(_ type: Scope.Type)

    func registerSingleton<Value, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID],
        create: @escaping FactoryClosure<Value>
    )

    func registerWeakSingleton<Value: AnyObject, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID],
        create: @escaping FactoryClosure<Value>
    )

    func registerFactory<Value, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID],
        create: @escaping FactoryClosure<Value>
    )

    func registerAssistedFactory<Value, Scope: DependencyScope>(
        ofType type: Value.Type,
        in scope: Scope.Type,
        qualifier: QualifierDefinition.Type,
        requirements: [String: TypeID]
    )

    func setup(_ modules: DependencyModule.Type...) throws
}
