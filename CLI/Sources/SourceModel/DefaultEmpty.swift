
public protocol CanBeEmpty {
    static func createEmpty() -> Self

    var isEmpty: Bool { get }
}

extension Array: CanBeEmpty {
    public static func createEmpty() -> [Element] {
        return []
    }
}

@propertyWrapper
public struct DefaultEmpty<Element> where Element: CanBeEmpty {
    public var wrappedValue: Element

    public init(wrappedValue: Element) {
        self.wrappedValue = wrappedValue
    }
}

extension DefaultEmpty: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.wrappedValue)
    }

}
extension DefaultEmpty: Decodable where Element: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try container.decode(Element.self)
    }
}
extension DefaultEmpty: Equatable where Element: Equatable {}
extension DefaultEmpty: Hashable where Element: Hashable {}

extension KeyedDecodingContainer {
    public func decode<Element: Decodable>(
        _ type: DefaultEmpty<Element>.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> DefaultEmpty<Element> {
        if !contains(key) {
            return DefaultEmpty(wrappedValue: .createEmpty())
        } else {
            return DefaultEmpty(wrappedValue: try self.decode(Element.self, forKey: key))
        }
    }
}

extension KeyedEncodingContainer {
    public mutating func encode<Element: Encodable>(
        _ value: DefaultEmpty<Element>,
        forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        if !value.wrappedValue.isEmpty {
            try encode(value.wrappedValue, forKey: key)
        }
    }
}
