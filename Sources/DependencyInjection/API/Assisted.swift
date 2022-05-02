@propertyWrapper
public struct Assisted<V> {
    public let wrappedValue: V

    public init(wrappedValue: V, _ name: StaticString? = nil) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct Inject<V> {
    public let wrappedValue: V

    public init(wrappedValue: V, _ name: StaticString? = nil) {
        self.wrappedValue = wrappedValue
    }
}
