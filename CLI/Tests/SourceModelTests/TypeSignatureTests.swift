import SnapshotTesting
import TestHelpers
import XCTest

@testable import SourceModel

class TypeSignatureTests: XCTestCase {

    func check(
        _ input: String,
        file: StaticString = #filePath,
        line: UInt = #line,
        testName: String = #function
    ) throws {
        let parsed =
            try SourceFile.parse(
                module: "Mock",
                source: input
            )
        assertSnapshot(
            matching: parsed,
            as: .yaml,
            file: file,
            testName: testName,
            line: line
        )
    }

    func testTypeSignatures() throws {
        try check("class Class {}")
        try check("class Generic<A: Equatable> {}")
        try check("class Generic<A> where A: Protocol {}")
        try check("class A {}")

    }

}
