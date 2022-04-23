import Foundation

public protocol DependencyRegistry {
    func register<Value>(
        as type: Value.Type,
        provider: @escaping (DependencyResolver) -> Value
    )

    func setup(_ modules: Module...) throws
}

public protocol DependencyResolver {
    func _tryResolve<Value>(_ type: Value.Type) throws -> Value

    func resolve<Value>(_ type: Value.Type) -> Value
}

extension DependencyResolver {
    public func resolve<Value>(_ type: Value.Type) -> Value {
        return try! _tryResolve(Value.self)
    }
}

class DefaultProvider<Value>: Provider {
    typealias Provided = Value
    let factory: (DependencyResolver) throws -> Value

    init(factory: @escaping (DependencyResolver) throws -> Provided) {
        self.factory = factory
    }

    func resolve(provider: DependencyResolver) throws -> Provided {
        try factory(provider)
    }
}

public enum DependencyInjection {
    public static var resolver: DependencyResolver & DependencyRegistry = DefaultRegistry()
}

class DefaultRegistry: DependencyRegistry, DependencyResolver {

    private var isSetupFinished: Bool = false
    private var factories: [ObjectIdentifier: _AnyProvider] = [:]

    func setup(_ modules: Module...) throws {
        for module in modules {
            module.register(in: self)
        }
        isSetupFinished = true

        for module in modules {
            try module.validate(resolver: self)
        }
    }

    func register<Value>(
        as type: Value.Type,
        provider: @escaping (DependencyResolver) -> Value
    ) {
        assert(!isSetupFinished)
        factories[ObjectIdentifier(type)] = DefaultProvider(factory: provider)
    }

    func _tryResolve<Value>(_ type: Value.Type) throws -> Value {

        guard isSetupFinished else {
            throw DependencyErrors.resolvedBeforeSetup(type: type)
        }

        guard let provider = factories[ObjectIdentifier(type)] else {
            throw DependencyErrors.noProviderRegistered(type: type)
        }

        return try provider.resolveAny(provider: self) as! Value
    }
}

enum DependencyErrors: Error {
    case resolvedBeforeSetup(type: Any.Type)
    case noProviderRegistered(type: Any.Type)
}

public protocol Module {
    func register(in registry: DependencyRegistry)
    func validate(resolver: DependencyResolver) throws
}
