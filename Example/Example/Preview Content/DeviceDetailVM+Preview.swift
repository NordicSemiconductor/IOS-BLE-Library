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
        override init(deviceId: String) {
            super.init(deviceId: deviceId)
            
            self.name = "New Device"
            self.advertisementData = .fullMock
            self.isConnectable = true
        }
        
        override init(deviceId: CBUUID) {
            super.init(deviceId: deviceId)
            
            self.name = "New Device"
            self.advertisementData = .fullMock
            self.isConnectable = true
            
        }
        
        override func discoverDevice() { }
    }
}
