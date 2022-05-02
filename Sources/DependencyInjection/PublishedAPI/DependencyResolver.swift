public protocol DependencyResolver {
    func resolve<Value>(_ type: Value.Type) -> Value
}

extension DependencyResolver {
    public func resolve<Value>() -> Value {
        return resolve(Value.self)
    }
}
