import DependencyModel
import SwiftSyntax
import SwiftSyntaxBuilder

struct GenerateFileDependencies: ExpressibleAsSourceFile {
    let graph: FileDependencyGraph
    let steps: [CodeGenStep]

    init(graph: FileDependencyGraph) {
        self.graph = graph
        self.steps =
            graph.scopes.map(GenerateScopeDeclaration.init(scope:))
            + graph.provides.map(GenerateTypeFactory.init(provided:))
            + graph.bindings.map(GenerateCustomBinding.init(binding:))
    }

    var fileRegistrationFunction: FunctionDecl {
        FunctionDecl(
            identifier: .identifier("register_\(graph.fileName)"),
            signature: FunctionSignature(
                input: ParameterClause {
                    FunctionParameter(
                        firstName: .identifier("in").withTrailingTrivia(.spaces(1)),
                        secondName: .identifier("registry"),
                        colon: .colon,
                        type: "DependencyRegistry",
                        attributesBuilder: {}
                    )
                }
            ),
            body: CodeBlock {
                for step in steps {
                    step.registration
                }
            },
            modifiersBuilder: {
                TokenSyntax.internal
                TokenSyntax.static
            }
        )
    }

    func createSourceFile() -> SwiftSyntaxBuilder.SourceFile {
        return SwiftSyntaxBuilder.SourceFile(eofToken: .eof) {
            for imp in graph.imports {
                ImportDecl(path: imp.path)
            }
            if !graph.imports.contains(where: { $0.path == Constants.runtimeLibraryName }) {
                ImportDecl(path: Constants.runtimeLibraryName)
            }

            ExtensionDecl.init(
                extendedType: "\(graph.fileName)_Module",
                membersBuilder: {
                    fileRegistrationFunction
                }
            )

            for step in steps {
                step.declaration
            }
        }

    }
}
