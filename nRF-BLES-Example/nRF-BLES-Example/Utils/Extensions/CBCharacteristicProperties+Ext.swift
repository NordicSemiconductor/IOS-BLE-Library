//
//  CBCharacteristicProperties+Ext.swift
//  Example
//
//  Created by Nick Kibysh on 07/05/2023.
//

import Foundation
import CoreBluetoothMock

extension CBCharacteristicProperties: CustomStringConvertible {
    public var description: String {
        var strings: [String] = []
        
        if self.contains(.authenticatedSignedWrites) {
            strings.append("Authenticated Signed Writes")
        }
        if self.contains(.broadcast) {
            strings.append("Broadcast")
        }
        if self.contains(.extendedProperties) {
            strings.append("Extended Properties")
        }
        if self.contains(.indicate) {
            strings.append("Indicate")
        }
        if self.contains(.indicateEncryptionRequired) {
            strings.append("Indicate Encryption Required")
        }
        if self.contains(.notify) {
            strings.append("Notify")
        }
        if self.contains(.notifyEncryptionRequired) {
            strings.append("Notify Encryption Required")
        }
        if self.contains(.read) {
            strings.append("Read")
        }
        if self.contains(.write) {
            strings.append("Write")
        }
        if self.contains(.writeWithoutResponse) {
            strings.append("Write Without Response")
        }
        
        return strings.joined(separator: ", ")
    }
}
