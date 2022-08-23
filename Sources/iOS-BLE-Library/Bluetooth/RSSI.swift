//
//  RSSI.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation

// MARK: - RSSI

public struct RSSI: ExpressibleByIntegerLiteral, Equatable, Hashable {
    
    public typealias IntegerLiteralType = Int
    
    // MARK: Properties
    
    public let value: Int
    
    // MARK: Init
    
    public init(integerLiteral value: Int) {
        self.value = value
    }
}

// MARK: - Constants

public extension RSSI {
    
    static let outOfRange: RSSI = 127
    static let practicalWorst: RSSI = -100
    static let bad: RSSI = -90
    static let ok: RSSI = -80
    static let good: RSSI = -50
}
