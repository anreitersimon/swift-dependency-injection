import SourceModel
import SwiftSyntaxBuilder

protocol CodeGenStep {
    @CodeBlockItemListBuilder
    var registration: CodeBlockItemList { get }

    @CodeBlockItemListBuilder
    var declaration: CodeBlockItemList { get }
}
