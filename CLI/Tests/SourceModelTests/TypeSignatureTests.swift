import SnapshotTesting
import TestHelpers
import XCTest

@testable import SourceModel

class TypeSignatureTests: XCTestCase {

    func expectInitializer(
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

        try expectInitializer("class Class {}")
        try expectInitializer("class GenericClass<A> {}")
        try expectInitializer("class GenericClass<A> where A: Protocol {}")
        try expectInitializer("class A {}")

    }

}
