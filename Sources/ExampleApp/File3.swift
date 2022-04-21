import Example
import ExampleCore
import Foundation
import SwiftDagger

@main
struct MainApp {

    static func main() throws {
        try DependencyInjection.resolver.setup(
            ExampleAppModule(),
            ExampleCoreModule(),
            ExampleModule()
        )
    }

}

class ViewModel2: Injectable {
    let injected: CoreRepository

    required init(injected: CoreRepository) {
        self.injected = injected
    }

}
