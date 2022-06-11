import SourceModel

extension DependencyGraphCollector {

    mutating func collectScopeDeclaration(_ type: TypeDeclaration) {

        guard type.inheritedTypes.contains(where: { $0.description == "DependencyScope" }) else {
            return
        }

        guard type.kind != .protocol else {
            return diagnostics.error("ScopeDeclaration must be a concrete type")
        }

        guard
            let parentScope = type.parentScope
        else {
            return diagnostics.error("Could not find ParentScope", at: type.sourceRange?.start)
        }

        graph.scopes.append(
            ScopeDefinition(name: type.name, parent: parentScope)
        )

    }

}

extension TypeDeclaration {

    public var parentScope: TypeSignature? {
        typealiases.first(where: { $0.identifier == "ParentScope" })?.type
    }
    
    public var scope: TypeSignature? {
        typealiases.first(where: { $0.identifier == "Scope" })?.type
    }
    
    public var qualifiers: Qualifiers {
        let name = typealiases.first(where: { $0.identifier == "Qualifier" })?.type?.description
        
        return Qualifiers(raw: name ?? "")
    }
}
