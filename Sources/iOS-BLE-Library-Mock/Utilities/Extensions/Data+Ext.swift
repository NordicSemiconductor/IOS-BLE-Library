//
//  Data.swift
//  
//
//  Created by Dinesh Harjani on 18/8/22.
//

import Foundation

// MARK: - Data Extension

public extension Data {
    
    // MARK: HexEncodingOptions
    
    struct HexEncodingOptions: OptionSet {
        
        public static let upperCase = HexEncodingOptions(rawValue: 1)
        public static let reverseEndianness = HexEncodingOptions(rawValue: 2)
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue << 0
        }
    }

    // MARK: hexEncodedString
    
    func hexEncodedString(options: HexEncodingOptions = [], separator: String = "") -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        
        var bytes = self
        if options.contains(.reverseEndianness) {
            bytes.reverse()
        }
        return bytes
            .map { String(format: format, $0) }
            .joined(separator: separator)
    }
}
