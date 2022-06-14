import SwiftSyntaxBuilder
import SourceModel

struct InjectionRequirements: ExpressibleAsExprBuildable {
    let arguments: [Function.Argument]

    func createExprBuildable() -> ExprBuildable {
        DictionaryExpr(contentBuilder: {
            for argument in arguments where argument.isInjected {

                DictionaryElement(
                    keyExpression: StringLiteralExpr(
                        argument.firstName ?? argument.secondName ?? "-"
                    ),
                    valueExpression: FunctionCallExpr(
                        "TypeID",
                        argumentListBuilder: {
                            TupleExprElement(
                                label: nil,
                                colon: nil,
                                expression: TypeExpr(
                                    type: argument.type?.asMetatype()?.description ?? "Never.self"
                                ),
                                trailingComma: .comma
                            )

                            TupleExprElement(
                                label: .identifier("qualifier").withTrailingTrivia(.spaces(1)),
                                colon: .colon,
                                expression: IdentifierExpr(
                                    argument.qualifiers.effectiveQalifier
                                )
                            )
                        }
                    ),
                    trailingComma: .comma
                )

            }
        })
    }
}
