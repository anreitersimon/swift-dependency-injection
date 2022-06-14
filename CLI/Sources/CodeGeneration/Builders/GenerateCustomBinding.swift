import DependencyModel
import SourceModel
import SwiftSyntax
import SwiftSyntaxBuilder

struct GenerateCustomBinding: CodeGenStep {

    let binding: Binding

    var registration: CodeBlockItemList {
        FunctionCallExpr(
            calledExpression: binding.registrationFunctionName,
            leftParen: .leftParen,
            rightParen: .rightParen,
            argumentListBuilder: {
                TupleExprElement(
                    label: .identifier("in"),
                    colon: .colon,
                    expression: IdentifierExpr("registry")
                )
            }
        )
    }

    var declaration: CodeBlockItemList {
        registrationFunction
        containerExtension
    }

    var registrationFunction: FunctionDecl {
        FunctionDecl(
            identifier: .identifier(binding.registrationFunctionName),
            genericParameterClause: nil,
            signature: FunctionSignature(
                input: ParameterClause {
                    FunctionParameter(
                        attributes: nil,
                        firstName: .identifier("in").withTrailingTrivia(.spaces(1)),
                        secondName: .identifier("registry"),
                        colon: .colon,
                        type: "DependencyRegistry"
                    )
                }
            ),
            genericWhereClause: nil,
            body: CodeBlock(statementsBuilder: {
                FunctionCallExpr(
                    "registry.\(binding.registryMethod)",
                    trailingClosure: binding.factoryMethod.isAssisted
                        ? nil
                        : ClosureExpr(
                            leftBrace: .leftBrace,
                            signature: ClosureSignature(
                                input: IdentifierExpr("resolver"),
                                inTok: .in
                            ),
                            rightBrace: .rightBrace,
                            statementsBuilder: {
                                InstanceConstruction(
                                    calledExpression:
                                        "Dependencies.Bindings<\(binding.scope.description)>.\(binding.factoryMethod.name)",
                                    resolverBase: "resolver",
                                    arguments: binding.factoryMethod.arguments
                                )
                            }
                        ),
                    argumentListBuilder: {
                        CodeGen.registrationCallArguments(
                            typeName: binding.type.description,
                            scope: binding.scope,
                            qualifiers: binding.qualifiers,
                            arguments: binding.factoryMethod.arguments
                        )
                    }
                )
            }),
            modifiersBuilder: {
                TokenSyntax.fileprivate
            }
        )
    }

    @CodeBlockItemListBuilder
    var containerExtension: CodeBlockItemList {
        ExtensionDecl(
            extendedType: "DependencyContainer",
            genericWhereClause: GenericWhereClause(requirementListBuilder: {
                GenericRequirement(body: "Scope: Provides_\(binding.scope.description)")
            }),
            membersBuilder: {

                FunctionDecl.init(
                    identifier: .identifier(binding.factoryFunctionName),
                    signature: FunctionSignature(
                        input: CodeGen.factoryMethodParameters(
                            arguments: binding.factoryMethod.arguments
                        ),
                        output: SimpleTypeIdentifier(binding.type.description)
                    ),
                    modifiersBuilder: {
                        if binding.qualifiers.builtIn.contains(.Public) {
                            TokenSyntax.public
                        } else {
                            TokenSyntax.internal
                        }
                    },
                    bodyBuilder: {
                        if binding.factoryMethod.isAssisted {
                            InstanceConstruction(
                                calledExpression:
                                    "Dependencies.Bindings<\(binding.scope.description)>.\(binding.factoryMethod.name)",
                                resolverBase: "self",
                                arguments: binding.factoryMethod.arguments
                            )
                        } else {
                            FunctionCallExpr(
                                "self.resolve",
                                argumentListBuilder: {
                                    TupleExprElement(
                                        label: .identifier("qualifier"),
                                        colon: .colon,
                                        expression: IdentifierExpr(
                                            binding.qualifiers.effectiveQalifier
                                        )
                                    )
                                }
                            )
                        }
                    }
                )

            }
        )
    }

}
