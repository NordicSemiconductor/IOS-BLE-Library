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
        Text(scanData.)
    }
}

//struct ScanResult_Previews: PreviewProvider {
//    static var previews: some View {
//        ScanResult(scanData: Bluetooth.ScanData(
//            peripheral: CBPeripheral,
//            advertisementData: [:],
//            RSSI: NSNumber(integerLiteral: -55))
//        )
//    }
//}
