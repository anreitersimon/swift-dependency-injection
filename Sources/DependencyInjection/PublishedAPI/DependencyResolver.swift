public protocol DependencyResolver {
    func resolve<Value>(_ type: Value.Type, qualifier: QualifierDefinition.Type) -> Value
}

extension DependencyResolver {
    public func resolve<Value>(qualifier: QualifierDefinition.Type) -> Value {
        return resolve(Value.self, qualifier: qualifier)
    }
}
