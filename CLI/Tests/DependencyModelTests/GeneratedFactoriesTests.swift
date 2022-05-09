import SnapshotTesting
import SourceModel
import TestHelpers
import XCTest

@testable import DependencyModel

class AnalizerTests: XCTestCase {

    class DiagnosticsCollector: Diagnostics {
        var diagnostics: [Diagnostic] = []
        var hasErrors: Bool = false

        func record(_ diagnostic: Diagnostic) {
            diagnostics.append(diagnostic)
        }

    }

    func testFactories() throws {

        let file = try SourceFile.parse(
            module: "Mock",
            fileName: "MockFile",
            source: """
                struct ExplicitelyInitialized: Injectable {
                    init(
                        @Inject a: I,
                        @Assisted b: Int,
                        bla: Int = 1
                    ) {}
                }
                """
        )

        assertSnapshot(matching: file, as: .yaml)
    }

}
