import DependencyModel
import Foundation
import SourceModel
import SwiftFormat
import SwiftFormatConfiguration
import SwiftSyntax
import SwiftSyntaxBuilder

extension Initializer {
    public var isAssisted: Bool {
        return arguments.contains(where: \.isAssisted)
    }
}

extension Function {
    public var isAssisted: Bool {
        return arguments.contains(where: \.isAssisted)
    }
}

public enum CodeGen {

    static let header = "// Automatically generated DO NOT MODIFY"

    @TupleExprElementListBuilder
    static func registrationCallArguments(
        typeName: String,
        scope: TypeSignature?,
        qualifiers: Qualifiers,
        arguments: [Function.Argument]
    ) -> TupleExprElementList {
        TupleExprElement(
            label: .identifier("ofType"),
            colon: .colon,
            expression: IdentifierExpr("\(typeName).self"),
            trailingComma: .comma
        )
        TupleExprElement(
            label: .identifier("in"),
            colon: .colon,
            expression: IdentifierExpr(
                scope?.asMetatype()?.description ?? "Never.self"
            ),
            trailingComma: .comma
        )
        TupleExprElement(
            label: .identifier("qualifier"),
            colon: .colon,
            expression: IdentifierExpr(qualifiers.effectiveQalifier),
            trailingComma: .comma
        )
        TupleExprElement(
            label: .identifier("requirements"),
            colon: .colon,
            expression: InjectionRequirements(arguments: arguments),
            trailingComma: nil
        )
    }

    static func factoryMethodParameters(
        arguments: [Function.Argument]
    ) -> ParameterClause {
        ParameterClause(parameterListBuilder: {
            for (argument, isLast) in arguments.filter(\.isAssisted).withIsLast() {
                FunctionParameter(
                    firstName: argument.firstName.map(TokenSyntax.identifier(_:)),
                    secondName: argument.secondName.map(TokenSyntax.identifier(_:)),
                    colon: .colon,
                    type: SimpleTypeIdentifier(argument.type?.description ?? "Never"),
                    ellipsis: nil,
                    defaultArgument: nil,
                    trailingComma: isLast ? nil : .comma,
                    attributesBuilder: {}
                )
            }
        })
    }

    public static func generateSources(
        moduleGraph graph: ModuleDependencyGraph
    ) -> String {
        let file = GenerateModuleDependencies(graph: graph)

        return file.formattedText()
    }

    public static func generateSources(
        fileGraph graph: FileDependencyGraph
    ) -> String {

        let file = GenerateFileDependencies(graph: graph)

        return file.formattedText()
    }
}


extension ExpressibleAsSourceFile {
    func formattedText() -> String {
        let syntax = self.createSourceFile().buildSyntax(format: Format())

        var config = Configuration()
        config.indentation = .spaces(4)
        config.lineLength = 80
        config.respectsExistingLineBreaks = false
        config.lineBreakAroundMultilineExpressionChainComponents = true
        config.lineBreakBeforeEachArgument = true

        let formatter = SwiftFormatter(configuration: config)

        var formatted = ""
        try! formatter.format(
            syntax: syntax.as(SourceFileSyntax.self)!,
            assumingFileURL: nil,
            to: &formatted
        )
        return formatted
    }
}

extension String {

    func removingSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(dropLast(suffix.count))
        } else {
            return self
        }
    }
}

extension Array {

    func withIsLast() -> [(element: Element, isLast: Bool)] {
        zip(0..., self).map { (index, element) in
            (element, index == self.count - 1)
        }
    }
}
