#if os(iOS)
import UIKit
#endif

public enum Dependencies {
    private static let singleton = DefaultRegistry()

    public static var sharedResolver: DependencyContainer<GlobalScope> { singleton.container }
    public static var sharedRegistry: DependencyRegistry { singleton }

    public enum Factories<Scope: DependencyScope> {}
    public enum Singletons<Scope: DependencyScope> {}
    public enum WeakSingletons<Scope: DependencyScope> {}
}
