@propertyWrapper
public struct Assisted<V> {
    public let wrappedValue: V

    public init(wrappedValue: V) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Inject<V> {
    public let wrappedValue: V

    public init(wrappedValue: V, _ qualifier: QualifierDefinition.Type? = nil) {
        self.wrappedValue = wrappedValue
    }
}
