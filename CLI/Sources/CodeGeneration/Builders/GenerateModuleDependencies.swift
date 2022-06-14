import DependencyModel
import SwiftSyntax
import SwiftSyntaxBuilder

struct GenerateModuleDependencies: ExpressibleAsSourceFile {
    let graph: ModuleDependencyGraph

    init(graph: ModuleDependencyGraph) {
        self.graph = graph
    }

    var submodulesVariable: VariableDecl {

        VariableDecl(
            letOrVarKeyword: .let,
            modifiersBuilder: { TokenSyntax.public },
            bindingsBuilder: {
                PatternBinding(
                    pattern: "submodules",
                    initializer: InitializerClause(

                        value: ArrayExpr(elementsBuilder: {
                            for module in graph.modules {
                                ArrayElement(
                                    expression: SimpleTypeIdentifier("\(module)_Module.self"),
                                    trailingComma: .comma
                                )
                            }
                        })
                    )

                )
            }
        )
    }

    var registrationFunction: FunctionDecl {
        FunctionDecl(
            identifier: .identifier("register"),
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
                for file in graph.files {
                    let fileName = file.deletingPathExtension().lastPathComponent.swiftIdentifier()

                    FunctionCallExpr(
                        "register_\(fileName)",
                        argumentListBuilder: {
                            TupleExprElement(
                                label: .identifier("in"),
                                colon: .colon,
                                expression: IdentifierExpr("registry")
                            )

                        }
                    )
                }
            },
            modifiersBuilder: {
                TokenSyntax.public
                TokenSyntax.static
            }
        )
    }

    func createSourceFile() -> SwiftSyntaxBuilder.SourceFile {
        return SwiftSyntaxBuilder.SourceFile(eofToken: .eof) {
            for module in graph.modules {
                ImportDecl(path: module)
            }
            ImportDecl(path: Constants.runtimeLibraryName)

            EnumDecl(
                identifier: "\(graph.module)_Module",
                inheritanceClause: TypeInheritanceClause(inheritedTypeCollectionBuilder: {
                    InheritedType(
                        typeName: SimpleTypeIdentifier("DependencyInjection.DependencyModule")
                    )
                }),
                modifiersBuilder: { TokenSyntax.public },
                membersBuilder: {
                    submodulesVariable

                    registrationFunction
                }
            )
        }

    }
}
