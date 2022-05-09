import SnapshotTesting
import SwiftUI
import TestHelpers
import XCTest

@testable import SourceModel

class InitializerDeclarationTests: XCTestCase {

    func expectInitializer(
        _ input: String,
        _ expected: Initializer,
        file: StaticString = #filePath,
        line: UInt = #line,
        testName: String = #function
    ) throws {
        let parsed = try SourceFile.parse(
            module: "Mock",
            source: input
        )

        XCTAssertEqual(parsed.initializers.count, 1, file: file)

        assertSnapshot(
            matching: parsed,
            as: .yaml,
            file: file,
            testName: testName,
            line: line
        )
    }

    func testVariableDeclarations() throws {

        try expectInitializer(
            "init() {}",
            Initializer()
        )

        try expectInitializer(
            "init(a: Int, b: Int? = nil) {}",
            Initializer(arguments: [
                .init(
                    firstName: "a",
                    secondName: nil,
                    type: .simple(name: "Int")
                ),
                .init(
                    firstName: "b",
                    secondName: nil,
                    type: .optional(.simple(name: "Int")),
                    defaultValue: "nil"
                ),
            ])
        )
    }

}
