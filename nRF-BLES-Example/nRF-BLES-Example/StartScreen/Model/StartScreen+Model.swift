//
//  StartScreen+Model.swift
//  Example
//
//  Created by Nick Kibysh on 26/04/2023.
//

import Foundation
import iOS_BLE_Library

extension StartScreen {
    struct DisplayResult: Identifiable {
        let name: String
        let connectable: Bool
        let id: UUID
        
        init(name: String, connectable: Bool, id: UUID) {
            self.name = name
            self.connectable = connectable
            self.id = id
        }
        
        init(scanResult: ScanResult) {
            name = scanResult.name ?? "n/a"
            connectable = scanResult.advertisementData.isConnectable == true
            id = scanResult.peripheral.identifier
        }
    }
}
