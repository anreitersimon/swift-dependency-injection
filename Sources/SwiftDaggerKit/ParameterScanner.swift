//
//  File.swift
//
//
//  Created by Simon Anreiter on 19.04.22.
//

import DependencyModel
import Foundation
import SwiftSyntax

extension FunctionParameterSyntax {

    fileprivate func extractArgument(converter: SourceLocationConverter) -> Argument? {
        guard
            let typeName = type?.withoutTrivia().description,
            let name = firstName?.withoutTrivia().description
        else {
            return nil
        }

        let attributes =
            attributes?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .map { $0.attributeName.withoutTrivia().description }

        return Argument(
            type: TypeDescriptor(name: typeName),
            firstName: name,
            secondName: secondName?.withoutTrivia().description,
            attributes: attributes ?? [],
            range: self.sourceRange(converter: converter)
        )

    }

}

extension FunctionParameterListSyntax {

    fileprivate func extractArguments(converter: SourceLocationConverter) -> [Argument] {
        return self.compactMap { parameter in
            parameter.extractArgument(converter: converter)
        }
    }

}

extension FunctionDeclSyntax {

    func extractArguments(
        converter: SourceLocationConverter
    ) -> [Argument] {
        self.signature.input.parameterList.extractArguments(converter: converter)
    }

}

extension InitializerDeclSyntax {
    func extractArguments(converter: SourceLocationConverter) -> [Argument] {
        return parameters.parameterList.extractArguments(converter: converter)
    }
}
