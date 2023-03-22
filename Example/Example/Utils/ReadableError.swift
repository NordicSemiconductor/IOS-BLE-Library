//
//  ReadableError.swift
//  Example-Combine
//
//  Created by Nick Kibysh on 22/03/2023.
//

import Foundation

struct ReadableError: Error {
    let title: String?
    let message: String?
    
    init(title: String?, message: String?) {
        self.title = title
        self.message = message
    }
}

extension ReadableError {
    init(error: Error, title: String?) {
        self.title = title
        self.message = error.localizedDescription
    }
}
