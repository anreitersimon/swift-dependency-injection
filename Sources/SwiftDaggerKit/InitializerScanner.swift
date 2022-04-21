import DependencyModel
import SwiftSyntax

func collectInitializers<T: SyntaxProtocol>(
    node: T,
    converter: SourceLocationConverter
) -> [Initializer] {
    let scanner = InitializerScanner(converter: converter)

    node.children.forEach {
        scanner.walk($0)
    }

    return scanner.initializers
}

/// Scans a TypeDeclaration for all Initializers
/// ```
/// class AClass {
///     init(name: String)
/// }
/// ```
class InitializerScanner: SyntaxVisitor {

    init(
        converter: SourceLocationConverter
    ) {
        self.converter = converter
    }

    let converter: SourceLocationConverter
    var initializers: [Initializer] = []

    override func visit(
        _ node: InitializerDeclSyntax
    ) -> SyntaxVisitorContinueKind {
        initializers.append(
            Initializer(
                arguments: node.extractArguments(converter: converter),
                range: node.sourceRange(converter: converter)
            )
        )
        return .skipChildren
    }

}
