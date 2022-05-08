import Foundation

public protocol Writable {
    func write(to writer: FileWriter)
}

extension Writable {
    public func writeToFile(_ url: URL) throws {
        let writer = FileWriter()
        try writer.write(self, to: url)
    }
}

struct CompositeWritable: Writable {
    let elements: [Writable]
    let endLines: Bool

    func write(to writer: FileWriter) {
        for element in elements {
            element.write(to: writer)
            if endLines {
                writer.endLine()
            }
        }
    }
}

struct Line: Writable {
    let text: String

    func write(to writer: FileWriter) {
        writer.writeLine(text)
    }
}
