import SnapshotTesting
import XCTest

@testable import SourceModel

class TypeInferenceTests: XCTestCase {

    func testInferOptionalLiteral() {
        let inputs: [TypeSignature] = [
            .simple(
                name: "Optional",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
            .simple(
                name: "Swift.Optional",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
        ]

        assertSnapshot(
            matching: inputs.map { $0.inferLiteralTypes() },
            as: .yaml
        )

    }

    func testInferDictionaryLiteral() {
        let inputs: [TypeSignature] = [
            .simple(
                name: "Dictionary",
                genericArguments: [
                    .simple(name: "Int"),
                    .simple(name: "String"),
                ]
            ),
            .simple(
                name: "Swift.Dictionary",
                genericArguments: [
                    .simple(name: "Int"),
                    .simple(name: "String"),
                ]
            ),
        ]

        assertSnapshot(
            matching: inputs.map { $0.inferLiteralTypes() },
            as: .yaml
        )

    }

    func testInferArrayLiteral() {
        let inputs: [TypeSignature] = [
            .simple(
                name: "Array",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
            .simple(
                name: "Swift.Array",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
        ]

        assertSnapshot(
            matching: inputs.map { $0.inferLiteralTypes() },
            as: .yaml
        )

    }

}
