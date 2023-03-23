//
//  Bluetooth.ScanData.swift
//  Example
//
//  Created by Nick Kibysh on 23/03/2023.
//

import Foundation
import CoreBluetooth

extension Bluetooth {
    public struct ScanData {
        public var peripheral: CBPeripheral
        public var advertisementData: [String: Any]
        public var RSSI: NSNumber
        
        public init(peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
            self.peripheral = peripheral
            self.advertisementData = advertisementData
            self.RSSI = RSSI
        }
    }
}
