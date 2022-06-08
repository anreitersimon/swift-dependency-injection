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

public protocol AProtocol {}

struct AProtocolImplementation: Singleton, ExampleCore.AProtocol, AProtocol {}

extension Dependencies.Factories where Scope == ExampleScope {

    static func bindPublic(impl: AProtocolImplementation) -> AProtocol {
        impl
    }

    static func bindPublic(impl: AProtocolImplementation) -> ExampleCore.AProtocol {
        impl
    }
}
