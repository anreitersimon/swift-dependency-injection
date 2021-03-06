import CodeGeneration
import SnapshotTesting
import TestHelpers
import XCTest

@testable import DependencyModel
@testable import SourceModel

class DiagnosticsCollector: Diagnostics {
    var diagnostics: [Diagnostic] = []
    var hasErrors: Bool = false

    func record(_ diagnostic: Diagnostic) {
        diagnostics.append(diagnostic)
    }
}

class GeneratedFactoriesTests: XCTestCase {

    let file = try! SourceFile.parse(
        module: "Mock",
        fileName: "MockFile",
        source: """
            import TestModule

            struct ExplicitelyInitialized: Injectable {
                typealias Scope = CustomScope
                
                init(
                    @Inject a: I,
                    bla: Int = 1
                ) {}

                class Nested: Injectable {
                    init() {}
                }
            }

            struct ImplicitInitializer: Injectable {
                @Inject(Qualifiers.MyQualifier.self) var a: I
                @Assisted var b: Int
                var bla: Int = 1
            }

            class CustomScope: DependencyScope {
                typealias ParentScope = GlobalScope
            }

            protocol Protocol {}

            extension Dependencies.Bindings {
                static func bind(a: ImplicitInitializer) -> Protocol where Scope == CustomScope {
                    a
                }
            }

            extension Dependencies.Bindings where Scope == GlobalScope {
                
                @Qualifiers.MyQualifier
                static func bind(a: ImplicitInitializer) -> Protocol {
                    a
                }
            }
            """
    )

    func testFactories() throws {

        let diagnostics = DiagnosticsCollector()

        let graph = try DependencyGraphCollector.extractGraph(
            file: file,
            diagnostics: diagnostics
        )

        let moduleGraph = ModuleDependencyGraph(module: "Example")

        let text = CodeGen.generateSources(fileGraph: graph)
        let moduleText = CodeGen.generateSources(moduleGraph: moduleGraph)

        assertSnapshot(matching: text, as: .lines, record: true)
        assertSnapshot(matching: graph, as: .yaml)

        assertSnapshot(matching: moduleText, as: .lines, record: true)

    }

}
