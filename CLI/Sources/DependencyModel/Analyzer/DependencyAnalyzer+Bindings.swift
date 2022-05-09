import SourceModel

extension DependencyGraphCollector {

    mutating func collectBindingExtensions(
        _ ext: Extension
    ) {
        guard let extendedFactoryType = ext.extendedFactoryType else {
            return
        }

        // Look for `where Scope == <Scope>` on either the extension or the individual functions
        let scopeFromExtension = ext.generics.extractScope(diagnostics: diagnostics)

        for function in ext.functions {
            if !function.modifiers.contains(.static) {
                diagnostics.record(.bindingMustBeStatic(function))
            }

            if !function.generics.parameters.isEmpty {
                diagnostics.record(.genericBindingNotSupported(function))
            }

            let scopeFromFunction = function.generics.extractScope(diagnostics: diagnostics)

            if scopeFromFunction != nil && scopeFromExtension != nil {
                diagnostics.record(.conflictingScopeDefinitions(function))
            }

            if function.name != "bind" {
                diagnostics.record(.bindingFunctionMisnamed(function))
            }

            for arg in function.arguments where arg.isAssisted {
                diagnostics.error(
                    "@Assisted bindings are not supported in custom Bindings",
                    at: arg.sourceRange?.start
                )
            }

            guard let returnType = function.returnType else {
                diagnostics.error(
                    "binding method must return type",
                    at: function.sourceRange?.start
                )
                return
            }
            graph.registerBinding(
                type: returnType,
                kind: extendedFactoryType,
                factoryMethod: function,
                scope: scopeFromFunction
                    ?? scopeFromExtension
                    ?? TypeSignature.simple(name: "GlobalScope")
            )
        }
    }

}

extension Diagnostic {
    static func bindingMustBeStatic(_ function: Function) -> Diagnostic {
        Diagnostic(
            message: "Binding Method must be declared static",
            level: .error,
            location: function.sourceRange?.start
        )
    }

    static func genericBindingNotSupported(_ function: Function) -> Diagnostic {
        Diagnostic(
            message: "Generic Bindings are not supported",
            level: .error,
            location: function.sourceRange?.start
        )
    }

    static func bindingFunctionMisnamed(_ function: Function) -> Diagnostic {
        Diagnostic(
            message: "Binding methods must be named 'bind'",
            level: .error,
            location: function.sourceRange?.start
        )
    }

    static func conflictingScopeDefinitions(_ function: Function) -> Diagnostic {
        Diagnostic(
            message: "Conflicting Scope Definitions",
            level: .error,
            location: function.sourceRange?.start
        )
    }

}

extension Generics {

    fileprivate func extractScope(diagnostics: Diagnostics) -> TypeSignature? {
        guard let requirement = requirements.first,
            requirements.count == 1,
            requirement.isSameType,
            requirement.left.description == "Scope"
        else {
            diagnostics.error("extensions can only declare like 'where Scope == <Scope>'")
            return nil
        }

        return requirement.right
    }

}
