public enum Dependencies {
    private static let singleton = DefaultRegistry()

    public static var sharedResolver: DependencyResolver { singleton }
    public static var sharedRegistry: DependencyRegistry { singleton }
    
    public enum Factories {}
    public enum Singletons {}
    public enum WeakSingletons {}
}
