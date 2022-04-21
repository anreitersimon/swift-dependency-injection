import Foundation
import SwiftDagger
import ExampleCore

class ViewModel: Injectable {
    let injected: CoreRepository

    required init(injected: CoreRepository) {
        self.injected = injected
    }

}
