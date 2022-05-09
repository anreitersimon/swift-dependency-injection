import SnapshotTesting
import XCTest

@testable import SourceModel

class VariableDeclarationTests: XCTestCase {

    func expectVariable(
        _ input: String,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) throws {
        let parsed = try SourceFile.parse(
            module: "Mock",
            source: input
        )

        XCTAssertEqual(parsed.variables.count, 1, file: file)

        assertSnapshot(
            matching: parsed,
            as: .yaml,
            file: file,
            testName: testName,
            line: line
        )
    }

    func testVariableDeclarations() throws {

        try expectVariable("let variable: Int")

        try expectVariable("let variable_InferredType = 1")

        try expectVariable(
            "let variable_Optional: Int?"
        )

        try expectVariable(
            "let variable_ImplicitlyUnwrappedOptional: Int!"
        )

        try expectVariable(
            "let variable_ExplicitOptional: Optional<Int>"
        )

    }

    func testVariableAttributes() throws {

        try expectVariable(
            "@Inject var variable: Int"
        )

    }

}
