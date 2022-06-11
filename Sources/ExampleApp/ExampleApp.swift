import DependencyInjection
import Example
import ExampleCore
import Foundation

@main
struct MainApp {
    static func main() throws {

        try Dependencies.registry.setup(
            ExampleApp_Module.self
        )
    }
}

struct CustomParentScope: DependencyScope {
    typealias ParentScope = GlobalScope
}

struct CustomScope: DependencyScope {
    typealias ParentScope = CustomParentScope
}

class ViewModel2: Injectable {
    typealias Scope = CustomScope

    let injected: CoreRepository

    required init(
        @Inject injected: CoreRepository,
        @Assisted a: A
    ) {
        self.injected = injected
    }

}

class A: WeakSingleton {

    typealias Scope = CustomParentScope

    init(@Inject repo: CoreRepository) {

    }
}
