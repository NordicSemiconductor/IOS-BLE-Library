//
//  ScanResult.swift
//  Example
//
//  Created by Nick Kibysh on 23/03/2023.
//

import SwiftUI
import iOS_BLE_Library
import CoreBluetooth

struct ScanResult: View {
    let scanData: Bluetooth.ScanData
    
    var body: some View {
        HStack {
            Text(scanData.peripheral.name ?? "n/a")
            Spacer()
            Circle()
                .fill(scanData.advertisementData.isConnectable == true ? .green : .red)
                .frame(size: CGSize(width: 10, height: 10))
        }
        .padding()
    }
}
