import DependencyInjection
import Example
import ExampleCore
import Foundation

@main
struct MainApp {
    static func main() throws {
        try Dependencies.sharedRegistry.setup(
            ExampleApp_Module.self,
            ExampleCore_Module.self,
            Example_Module.self
        )
    }
}


class ViewModel2: Injectable {
    let injected: CoreRepository

    required init(
        
        @Inject injected: CoreRepository,
        @Inject protocol: AProtocol
    ) {
        self.injected = injected
    }

}

class A: WeakSingleton {
    init(@Inject repo: CoreRepository) {

    }
}
