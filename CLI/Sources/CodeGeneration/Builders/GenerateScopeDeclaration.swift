import DependencyModel
import SwiftSyntax
import SwiftSyntaxBuilder

struct GenerateScopeDeclaration: CodeGenStep {
    let scope: ScopeDefinition

    var registration: CodeBlockItemList {
        FunctionCallExpr(
            "registry.registerScope",
            argumentListBuilder: {
                TupleExprElement(
                    label: nil,
                    colon: nil,
                    expression: IdentifierExpr("\(scope.name).self")
                )
            }
        )
    }

    var declaration: CodeBlockItemList {
        ProtocolDecl(
            identifier: "Provides_\(scope.name)",
            inheritanceClause: TypeInheritanceClause(
                inheritedTypeCollectionBuilder: {
                    InheritedType(
                        typeName: SimpleTypeIdentifier("Provides_\(scope.parent.description)")
                    )
                }
            ),
            members: MemberDeclBlock(),
            modifiersBuilder: { TokenSyntax.public }
        )

        ExtensionDecl(
            extendedType: SimpleTypeIdentifier(scope.name),
            inheritanceClause: TypeInheritanceClause(
                inheritedTypeCollectionBuilder: {
                    InheritedType(
                        typeName: SimpleTypeIdentifier("Provides_\(scope.name)")
                    )
                }
            )
        )
    }

}
