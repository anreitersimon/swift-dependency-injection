import SourceModel
import SwiftSyntax
import SwiftSyntaxBuilder

struct InstanceConstruction: ExpressibleAsFunctionCallExpr {
    let calledExpression: String
    let arguments: [Function.Argument]

    func createExprBuildable() -> ExprBuildable {
        return createFunctionCallExpr()
    }

    func createSyntaxBuildable() -> SyntaxBuildable {
        createFunctionCallExpr().createSyntaxBuildable()
    }

    func createFunctionCallExpr() -> FunctionCallExpr {
        FunctionCallExpr(
            calledExpression,
            argumentListBuilder: {
                for (argument, isLast) in arguments.filter(\.isInjectedOrAssisted).withIsLast() {
                    TupleExprElement(
                        label: argument.firstName.map(TokenSyntax.identifier(_:)),
                        colon: argument.firstName != nil ? .colon : nil,
                        expression: argumentExpression(for: argument),
                        trailingComma: isLast ? nil : .comma
                    )
                }
            }
        )
    }

    private func argumentExpression(for argument: Function.Argument) -> ExpressibleAsExprBuildable {
        if argument.isAssisted {
            return IdentifierExpr(argument.secondName ?? argument.firstName ?? "")
        } else {
            return FunctionCallExpr(
                "resolver.resolve",
                argumentListBuilder: {
                    TupleExprElement(
                        label: .identifier("qualifier"),
                        colon: .colon,
                        expression: IdentifierExpr(
                            argument.qualifiers.effectiveQalifier
                        ),
                        trailingComma: nil
                    )
                }
            )
        }
    }
}
