protocol DependencyDeclaration {
    var typeName: ProviderType { get }
    var requirements: [String: TypeID] { get }

    func checkIsResolvable() -> DependencyErrors?

    func makeProvider() -> _AnyProvider
}
