import Foundation
import SnapshotTesting
import Yams

extension Snapshotting where Value: Encodable, Format == String {
    public static var yaml: Snapshotting {
        let encoder = YAMLEncoder()
        encoder.options.sortKeys = true
        encoder.options.allowUnicode = true
        return .yaml(encoder)
    }

    /// A snapshot strategy for comparing encodable structures based on their property list representation.
    ///
    /// - Parameter encoder: A property list encoder.
    public static func yaml(_ encoder: YAMLEncoder) -> Snapshotting {
        var snapshotting = SimplySnapshotting.lines.pullback { (encodable: Value) in
            return try! encoder.encode(encodable)
        }
        snapshotting.pathExtension = "yml"
        return snapshotting
    }
}
