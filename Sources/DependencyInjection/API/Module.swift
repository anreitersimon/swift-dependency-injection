public protocol DependencyModule {
    static func register(in registry: DependencyRegistry)
}
