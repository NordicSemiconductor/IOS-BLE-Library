//
//  ScanResult.swift
//  Example
//
//  Created by Nick Kibysh on 23/03/2023.
//

import SwiftUI
import iOS_BLE_Library
import CoreBluetooth

struct ScanResultView: View {
    let scanResult: ScanResult
    
    var body: some View {
        HStack {
            Text(scanResult.name)
            Spacer()
            Circle()
                .fill(scanResult.advertisementData.isConnectable == true ? .green : .red)
                .frame(size: CGSize(width: 10, height: 10))
        }
        .padding()
    }
}
