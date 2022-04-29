import Foundation
import DependencyInjection
import ExampleCore

class ViewModel: Injectable {
    let injected: CoreRepository

    required init(@Inject injected: CoreRepository) {
        self.injected = injected
    }

}
