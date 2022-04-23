public protocol Injectable {}

/// Only one Instance will be created
public protocol Singleton {}

public protocol ProviderProtocol {
    associatedtype Value

    func get() -> Value
}

public class SingletonProvider<Value>: ProviderProtocol {
    let factory: () -> Value
    private var value: Value?

    init(factory: @escaping () -> Value) {
        self.factory = factory
    }

    public func get() -> Value {
        let result: Value

        if let value = self.value {
            result = value
        } else {
            result = factory()
            self.value = result
        }

        return result
    }
}

public class WeakSingletonProvider<Value: AnyObject>: ProviderProtocol {
    let factory: () -> Value
    private weak var value: Value?

    init(factory: @escaping () -> Value) {
        self.factory = factory
    }

    public func get() -> Value {
        let result: Value

        if let value = self.value {
            result = value
        } else {
            result = factory()
            self.value = result
        }

        return result
    }
}
