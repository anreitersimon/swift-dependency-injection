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

struct AProtocolImplementation: Singleton, AProtocol {}

extension Dependencies.Factories {
    static func bind(
        impl: AProtocolImplementation,
        apo: AProtocol
    ) -> AProtocol {
        impl
    }
}
