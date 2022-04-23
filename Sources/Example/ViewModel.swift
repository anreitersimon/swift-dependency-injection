import Foundation
import DependencyInjection
import ExampleCore

class ViewModel: Injectable {
    let injected: CoreRepository

    required init(injected: CoreRepository) {
        self.injected = injected
    }

}
