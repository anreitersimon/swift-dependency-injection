import CodeGeneration
import CustomDump
import XCTest

@testable import DependencyAnalyzer
@testable import SourceModel
import SnapshotTesting

class DiagnosticsCollector: Diagnostics {
    var diagnostics: [Diagnostic] = []
    var hasErrors: Bool = false

    func record(_ diagnostic: Diagnostic) {
        diagnostics.append(diagnostic)
    }
}

class GeneratedFactoriesTests: XCTestCase {

    func testFactories() throws {

        let file = try SourceFile.parse(
            module: "Mock",
            fileName: "MockFile",
            source: """
                import TestModule

                struct ExplicitelyInitialized: Injectable {
                    init(
                        @Inject a: I,
                        @Assisted b: Int,
                        bla: Int = 1
                    ) {}


                    class Nested: Injectable {
                        init() {}
                    }
                }

                struct ImplicitInitializer: Injectable {
                    @Inject var a: I
                    @Assisted var b: Int
                    var bla: Int = 1
                }

                extension ImplicitInitializer where Scope == CustomScope, A: B {
                    struct Nested: Injectable {
                        @Inject var a: I
                        @Assisted var b: Int
                        var bla: Int = 1
                    }
                }
                """
        )

        let diagnostics = DiagnosticsCollector()

        let graph = try DependencyAnalysis.extractGraph(
            file: file,
            diagnostics: diagnostics
        )

        let text = CodeGen.generateSources(fileGraph: graph)

        
        assertSnapshot(matching: text, as: .lines)
        
    }

}
