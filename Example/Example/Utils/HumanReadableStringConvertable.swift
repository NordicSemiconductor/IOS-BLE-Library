//
//  HumanReadableStringConvertable.swift
//  Example
//
//  Created by Nick Kibysh on 30/03/2023.
//

import Foundation

protocol HumanReadableStringConvertable {
    var humanReadableString: String { get }
}

extension String: HumanReadableStringConvertable {
    var humanReadableString: String { self }
}

extension Bool: HumanReadableStringConvertable {
    var humanReadableString: String { self ? "yes" : "No" }
}

extension Int: HumanReadableStringConvertable {
    var humanReadableString: String { "\(self)" }
}

extension NSNumber: HumanReadableStringConvertable {
    var humanReadableString: String { self.stringValue }
}

extension CBUUID: HumanReadableStringConvertable {
    var humanReadableString: String { self.uuidString }
}

extension Data: HumanReadableStringConvertable {
    var humanReadableString: String {
        if let str = String(data: self, encoding: .utf8) {
            return str
        } else {
            return "\(self.count) bytes"
        }
    }
}

extension Optional: HumanReadableStringConvertable where Wrapped: HumanReadableStringConvertable {
    var humanReadableString: String {
        switch self {
        case .some(let w):
            return w.humanReadableString
        case .none:
            return "n/a"
        }
    }
}

extension Array: HumanReadableStringConvertable where Element: HumanReadableStringConvertable {
    var humanReadableString: String {
        let arrayString = self
            .map(\.humanReadableString)
            .joined(separator: ", ")
        return "[\(arrayString)]"
    }
}

extension Dictionary: HumanReadableStringConvertable where Key: HumanReadableStringConvertable, Value: HumanReadableStringConvertable {
    var humanReadableString: String {
        let str = self.enumerated().map {
            "\($0.element.key.humanReadableString) : \($0.element.value.humanReadableString)"
        }
        .joined(separator: ",\n")
        
        return """
{
\(str)
}
"""
    }
}
