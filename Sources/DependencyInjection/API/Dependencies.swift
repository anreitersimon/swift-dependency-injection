#if os(iOS)
import UIKit
#endif

public enum Dependencies {
    private static let singleton = DefaultRegistry()

    public static var global: DependencyContainer<GlobalScope> { singleton.container }
    public static var registry: DependencyRegistry { singleton }
    
    public enum Bindings<Scope: DependencyScope> {}
}
