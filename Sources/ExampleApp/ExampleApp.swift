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
        
        Dependencies.sharedResolver
            .childContainer(scope: ExampleScope())

        //        let customContainer = Dependencies.sharedResolver.childContainer(scope: CustomScope())

        //        let i = customContainer.viewModel2()
        //        let i2 = customContainer.viewModel2()
        //
        //        print(i === i2)
        //        print(i.injected === i2.injected)
        //        print("----")
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
        @Inject a: A
    ) {
        self.injected = injected
    }

}

class A: WeakSingleton {

    typealias Scope = CustomParentScope

    init(@Inject repo: CoreRepository) {

    }
}
