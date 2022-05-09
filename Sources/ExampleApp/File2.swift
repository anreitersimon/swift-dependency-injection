import DependencyInjection
import Example
import ExampleCore
import Foundation

@main
struct MainApp {
    static func main() throws {

        try Dependencies.sharedRegistry.setup(
            ExampleApp_Module.self
        )

        let customContainer = Dependencies.sharedResolver.childContainer(scope: CustomScope())

        let i = customContainer.viewModel2()
        let i2 = customContainer.viewModel2()

        print(i === i2)
        print(i.injected === i2.injected)
        print("----")
    }
}

struct CustomScope: DependencyScope {
    typealias ParentScope = GlobalScope
}

class ViewModel2: Injectable {
    typealias Scope = CustomScope

    let injected: CoreRepository

    required init(
        @Inject injected: CoreRepository
    ) {
        self.injected = injected
    }

}

class A: WeakSingleton {
    init(@Inject repo: CoreRepository) {

    }
}
