import DependencyModel
import SourceModel
import SwiftSyntax
import SwiftSyntaxBuilder

struct GenerateTypeFactory: CodeGenStep {
    let provided: ProvidedType

    var registration: CodeBlockItemList {
        FunctionCallExpr(
            calledExpression: "\(provided.fullName).register",
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
        ExtensionDecl(
            extendedType: provided.fullName,
            membersBuilder: {
                registrationFunction
            }
        )

        containerExtension
    }

    var registrationFunction: FunctionDecl {
        FunctionDecl(
            identifier: .identifier("register"),
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
                    "registry.\(provided.registryMethod)",
                    trailingClosure: provided.initializer.isAssisted
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
                                    calledExpression: provided.fullName,
                                    resolverBase: "resolver",
                                    arguments: provided.initializer.arguments.filter(
                                        \.isInjectedOrAssisted
                                    )
                                )
                            }
                        ),
                    argumentListBuilder: {
                        CodeGen.registrationCallArguments(
                            typeName: provided.fullName,
                            scope: provided.scope,
                            qualifiers: provided.qualifiers,
                            arguments: provided.initializer.arguments
                        )
                    }
                )
            }),
            modifiersBuilder: {
                TokenSyntax.fileprivate
                TokenSyntax.static
            }
        )
    }

    @CodeBlockItemListBuilder
    var containerExtension: CodeBlockItemList {
        ExtensionDecl(
            extendedType: "DependencyContainer",
            genericWhereClause: GenericWhereClause(requirementListBuilder: {
                GenericRequirement(body: "Scope: Provides_\(provided.scope.description)")
            }),
            membersBuilder: {

                FunctionDecl(
                    identifier: .identifier(provided.factoryFunctionName),
                    signature: FunctionSignature(
                        input: CodeGen.factoryMethodParameters(
                            arguments: provided.initializer.arguments
                        ),
                        output: SimpleTypeIdentifier(provided.fullName)
                    ),
                    modifiersBuilder: {
                        provided.accessLevel.asTokenSyntax
                    },
                    bodyBuilder: {
                        if provided.initializer.isAssisted {
                            InstanceConstruction(
                                calledExpression: provided.fullName,
                                resolverBase: "self",
                                arguments: provided.initializer.arguments.filter(
                                    \.isInjectedOrAssisted
                                )
                            )
                        } else {
                            FunctionCallExpr(
                                "self.resolve",
                                argumentListBuilder: {
                                    TupleExprElement(
                                        label: .identifier("qualifier"),
                                        colon: .colon,
                                        expression: IdentifierExpr(
                                            provided.qualifiers.effectiveQalifier
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

extension AccessLevel {
    var asTokenSyntax: TokenSyntax {
        switch self {
        case .private:
            return .private
        case .fileprivate:
            return .fileprivate
        case .internal:
            return .internal
        case .public:
            return .public
        case .open:
            return .open
        }
    }
}
