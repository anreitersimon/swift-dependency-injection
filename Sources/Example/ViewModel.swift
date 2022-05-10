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

protocol AProtocol2 {}

struct AProtocolImplementation: Singleton, AProtocol, AProtocol2 {}

extension AProtocol {
    static func bind(impl: AProtocolImplementation) -> AProtocol {
        impl
    }
}

extension Dependencies.Factories where Scope == ExampleScope {

    static func bind(impl: AProtocolImplementation) -> AProtocol {
        impl
    }

    static func bind(impl: AProtocolImplementation) -> AProtocol2 {
        impl
    }
}
