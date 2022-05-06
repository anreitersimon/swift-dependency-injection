import DependencyInjection
import ExampleCore
import Foundation

struct CustomScope: DependencyScope {}

class ViewModel: Injectable {
    typealias Scope = CustomScope

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

extension Dependencies.Factories where Scope == CustomScope {
    static func bind(
        impl: AProtocolImplementation,
        api: AProtocol
    ) -> AProtocol {
        impl
    }

    static func bind(
        impl: AProtocolImplementation
    ) -> AProtocol2 {
        impl
    }
}
