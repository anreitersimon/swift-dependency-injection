import CodeGeneration
import CustomDump
import XCTest

@testable import DependencyAnalyzer
@testable import SourceModel

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

                extension ImplicitInitializer {
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

        XCTAssertNoDifference(
            text,
            """
            // Automatically generated DO NOT MODIFY

            import TestModule
            import DependencyInjection
            extension Mock_Module {
                static func register_MockFile(in registry: DependencyRegistry) {
                    Mock.ExplicitelyInitialized.Nested.register(in: registry)
                }
            }
            extension Mock_Module {
            }
            extension Mock.ExplicitelyInitialized {
                fileprivate static func register(in registry: DependencyRegistry) {
                    let requirements: [String: Any.Type] = [
                        "a": I.self,
                    ]

                    registry.registerAssistedFactory(
                        ofType: Mock.ExplicitelyInitialized.self,
                        requirements: requirements
                    )
                }
                public static func newInstance(
                    resolver: DependencyResolver = Dependencies.sharedResolver,
                    b: Int
                ) -> Mock.ExplicitelyInitialized {
                    Mock.ExplicitelyInitialized(
                        a: resolver.resolve(),
                        b: b
                    )
                }
            }
            extension Mock.ExplicitelyInitialized.Nested {
                fileprivate static func register(in registry: DependencyRegistry) {
                    let requirements: [String: Any.Type] = [:]

                    registry.registerFactory(
                        ofType: Mock.ExplicitelyInitialized.Nested.self,
                        requirements: requirements
                    ) { resolver in
                        Mock.ExplicitelyInitialized.Nested.newInstance(resolver: resolver)
                    }
                }
                public static func newInstance(
                    resolver: DependencyResolver = Dependencies.sharedResolver
                ) -> Mock.ExplicitelyInitialized.Nested {
                    Mock.ExplicitelyInitialized.Nested()
                }
            }
            extension Mock.ImplicitInitializer {
                fileprivate static func register(in registry: DependencyRegistry) {
                    let requirements: [String: Any.Type] = [
                        "a": I.self,
                    ]

                    registry.registerAssistedFactory(
                        ofType: Mock.ImplicitInitializer.self,
                        requirements: requirements
                    )
                }
                public static func newInstance(
                    resolver: DependencyResolver = Dependencies.sharedResolver,
                    b: Int
                ) -> Mock.ImplicitInitializer {
                    Mock.ImplicitInitializer(
                        a: resolver.resolve(),
                        b: b
                    )
                }
            }
            extension Mock.ImplicitInitializer.Nested {
                fileprivate static func register(in registry: DependencyRegistry) {
                    let requirements: [String: Any.Type] = [
                        "a": I.self,
                    ]

                    registry.registerAssistedFactory(
                        ofType: Mock.ImplicitInitializer.Nested.self,
                        requirements: requirements
                    )
                }
                public static func newInstance(
                    resolver: DependencyResolver = Dependencies.sharedResolver,
                    b: Int
                ) -> Mock.ImplicitInitializer.Nested {
                    Mock.ImplicitInitializer.Nested(
                        a: resolver.resolve(),
                        b: b
                    )
                }
            }


            """
        )
    }

}
