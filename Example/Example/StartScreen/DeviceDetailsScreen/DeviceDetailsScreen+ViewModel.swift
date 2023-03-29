//
//  DeviceDetailsScreen+ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 29/03/2023.
//

import Foundation
import iOS_BLE_Library

extension DeviceDetailsScreen {
    class ViewModel: ObservableObject {
        let scanData: Bluetooth.ScanData
        
        @Published var name: String = ""
        
        init(scanData: Bluetooth.ScanData) {
            self.scanData = scanData
            
            name = scanData.advertisementData.localName ?? "No Local Name"
        }
    }
}
