//
//  File.swift
//  
//
//  Created by Simon Anreiter on 02.05.22.
//

import Foundation

extension FileManager {
    func smartWrite(atPath path: String, contents: String) {
        if fileExists(atPath: path) {
            if (try? String(contentsOfFile: path)) == contents {
                return
            }
        }
        
        createFile(
            atPath: path,
            contents: contents.data(using: .utf8),
            attributes: nil
        )
    }
}
