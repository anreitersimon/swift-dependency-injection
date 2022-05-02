import DependencyInjection
import ExampleCore
import Foundation

class ViewModel: Injectable {
    let injected: CoreRepository

    required init(
        @Inject injected: CoreRepository,
        @Inject injected2: CoreRepository
    ) {
        self.injected = injected
    }

}
