import SourceModel

extension DependencyGraphCollector {

    mutating func collectInjectableType(_ type: TypeDeclaration) {

        let conformances = type.injectableConformances
        let conformanceKind: InjectableProtocol
        let initializers = type.initializersWithInjectableArguments()

        switch conformances.count {
        case 0:  // does not support injection
            if !initializers.isEmpty {
                for initializer in initializers {
                    diagnostics.error(
                        "Type must declare Injectable support by inheriting from one of \(InjectableProtocol.protocolNames))",
                        at: initializer.sourceRange?.start
                    )
                }
            }

            return
        case 1:
            conformanceKind = conformances[0]
        default:
            diagnostics.error(
                "Only one conformance allowed \(conformances.map(\.rawValue).joined(separator: ", "))",
                at: type.sourceRange?.start
            )
            return
        }

        if !type.generics.isEmpty {
            diagnostics.error("Generic Types are not supported", at: type.sourceRange?.start)
        }

        guard
            let initializer = type.findPrimaryInjectionInitializer(diagnostics: diagnostics)
        else {
            return
        }
        let assisted = initializer.arguments.filter(\.isAssisted)
        if !assisted.isEmpty, conformanceKind != .factory {
            for assistedArgument in assisted {
                diagnostics.error(
                    "@Assisted not supported with \(conformanceKind.rawValue)\nOnly is supported \(InjectableProtocol.factory.rawValue)",
                    at: assistedArgument.sourceRange?.start
                )
            }

            return
        }

        graph.registerInjectableType(
            type,
            kind: conformanceKind,
            initializer: initializer
        )
    }

}
