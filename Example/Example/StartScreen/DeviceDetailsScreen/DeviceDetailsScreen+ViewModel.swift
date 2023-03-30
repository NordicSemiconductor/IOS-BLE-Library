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
        let bluetooth = Bluetooth()
        
        @Published var name: String = ""
        @Published var advertisementData: AdvertisementData = AdvertisementData([:])
        @Published var isConnectable: Bool = false
        
        init(scanData: Bluetooth.ScanData) {
            self.scanData = scanData
            
            name = scanData.advertisementData.localName ?? "No Local Name"
            advertisementData = scanData.advertisementData
            isConnectable = scanData.advertisementData.isConnectable == true 
        }
    }
}

extension DeviceDetailsScreen.ViewModel {
    func connect() async {
        do {
            try await bluetooth.connect(to: scanData.peripheral)
        } catch {
            
        }
    }
}
