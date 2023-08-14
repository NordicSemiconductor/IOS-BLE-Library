//
//  DeviceList.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 14/06/2023.
//

import SwiftUI
import iOS_BLE_Library

extension ScanDeviceList {
    
    struct DeviceList: View {
        let devices: [ScanResult]
        
        var body: some View {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct DeviceList_Previews: PreviewProvider {
    typealias DeviceList = ScanDeviceList.DeviceList
    
    static var previews: some View {
        DeviceList()
    }
}
