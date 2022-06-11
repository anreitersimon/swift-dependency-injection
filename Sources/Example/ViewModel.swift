import DependencyInjection
import ExampleCore
import Foundation

public struct ExampleScope: DependencyScope {
    public typealias ParentScope = GlobalScope

    public init() {}
}

class ViewModel: Injectable {
    typealias Scope = ExampleScope

    let injected: CoreRepository

    required init(
        @Inject injected: CoreRepository,
        @Assisted injected2: CoreRepository
    ) {
        self.injected = injected
    }

}

public protocol AProtocol: AnyObject {}

class AProtocolImplementation: Singleton, ExampleCore.AProtocol, AProtocol {
    init() {}
}

extension Dependencies.Bindings {

    @Qualifiers.Public.MyQualifier
    static func aProtocolMyQualifer(impl: AProtocolImplementation) -> AProtocol {
        impl
    }

    @Qualifiers.Public
    static func aProtocol(impl: AProtocolImplementation) -> AProtocol {
        impl
    }

    static func exampleAProtocol(impl: AProtocolImplementation) -> ExampleCore.AProtocol {
        impl
    }
}

public struct MyScope: DependencyScope {
    public typealias ParentScope = GlobalScope
}

extension Qualifiers {
    @resultBuilder public enum MyQualifier: QualifierDefinition {}
    @resultBuilder public enum YourQualifier: QualifierDefinition {}
}

extension Qualifiers.Public {
    public typealias MyQualifier = Qualifiers.MyQualifier
    public typealias YourQualifier = Qualifiers.YourQualifier
}

extension Qualifiers.Singleton {
    public typealias MyQualifier = Qualifiers.MyQualifier
    public typealias YourQualifier = Qualifiers.YourQualifier
}

extension Qualifiers.WeakSingleton {
    public typealias MyQualifier = Qualifiers.MyQualifier
    public typealias YourQualifier = Qualifiers.YourQualifier
}
