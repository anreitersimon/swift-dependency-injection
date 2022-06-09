public protocol DependencyModule {
    static var submodules: [DependencyModule.Type] { get }
    
    static func register(in registry: DependencyRegistry)
}
