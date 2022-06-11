public protocol QualifierDefinition {
    static func buildBlock<Value>(_ components: Value) -> Value
}
//
//extension QualifierDefinition {
//    public typealias Public = Self
//}

extension QualifierDefinition {
    public static func buildBlock<Value>(_ components: Value) -> Value { components }
}

@resultBuilder struct MyQualifier: QualifierDefinition {}

public enum Qualifiers {
    @resultBuilder public struct Default: QualifierDefinition {}

    @resultBuilder public struct Public: QualifierDefinition {
        public typealias Singleton = Qualifiers.Singleton
        public typealias WeakSingleton = Qualifiers.WeakSingleton
    }
    @resultBuilder public struct Singleton: QualifierDefinition {}
    @resultBuilder public struct WeakSingleton: QualifierDefinition {}
}
