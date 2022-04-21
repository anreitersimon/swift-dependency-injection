import Foundation
import SwiftSyntax
import DependencyModel


extension DeclGroupSyntax {
    func extractStoredProperties(converter: SourceLocationConverter) -> [Argument] {

        let scanner = StoredPropertiesScanner(converter: converter)

        self.children.forEach {
            scanner.walk($0)
        }

        return scanner.arguments

    }
}

class StoredPropertiesScanner: SyntaxVisitor {

    init(
        converter: SourceLocationConverter
    ) {
        self.converter = converter
    }

    let converter: SourceLocationConverter
    var arguments: [Argument] = []

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {

        guard
            let binding = node.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
            node.bindings.count == 1,
            let typeName = binding.typeAnnotation?.type.withoutTrivia().description
        else {
            return .skipChildren
        }

        let name = pattern.identifier.withoutTrivia().text

        let attributes =
            node.attributes?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .map { $0.attributeName.withoutTrivia().description }

        self.arguments.append(
            Argument(
                type: TypeDescriptor(name: typeName),
                firstName: name,
                secondName: nil,
                attributes: attributes ?? [],
                range: node.sourceRange(converter: converter)
            )
        )

        return .skipChildren
    }

}

extension VariableDeclSyntax {

    func extractArgument(converter: SourceLocationConverter) throws -> Argument? {

        guard
            let binding = bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
            bindings.count == 1
        else {
            return nil
        }

        guard binding.accessor == nil else {
            return nil
        }

        guard
            let typeName = binding.typeAnnotation?.type.withoutTrivia().description
        else {
            throw VariableDeclarationError.typeAnnotationRequired(
                binding.sourceRange(converter: converter)
            )
        }

        let name = pattern.identifier.withoutTrivia().text

        let attributes =
            attributes?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .map { $0.attributeName.withoutTrivia().description }

        return Argument(
            type: TypeDescriptor(name: typeName),
            firstName: name,
            secondName: nil,
            attributes: attributes ?? [],
            range: binding.sourceRange(converter: converter)
        )
    }

}

enum VariableDeclarationError: LocalizedError {
    case typeAnnotationRequired(SourceRange)
}
