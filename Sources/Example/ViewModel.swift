import DependencyInjection
import ExampleCore
import Foundation

class ViewModel: Injectable {
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

extension Dependencies.Factories {
    static func bind(
        impl: AProtocolImplementation,
        apo: AProtocol
    ) -> AProtocol {
        impl
    }
    
    static func bind(
        impl: AProtocolImplementation
    ) -> AProtocol2 {
        impl
    }
}
