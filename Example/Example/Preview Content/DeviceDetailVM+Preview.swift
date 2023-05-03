//
//  DeviceDetailVM+Preview.swift
//  Example
//
//  Created by Nick Kibysh on 05/04/2023.
//

import Foundation
import iOS_BLE_Library

extension DeviceDetailsScreen {
    class PreviewViewModel: ViewModel {
        init(name: String = "New Device", connectable: Bool = true, rssi: RSSI = .good, advData: AdvertisementData = .mock) {
            super.init()
            self.name = name
            self.isConnectable = connectable
            self.rssi = rssi
            self.advertisementData = advData
        }
        
        override func discoverDevice() { }
    }
}
