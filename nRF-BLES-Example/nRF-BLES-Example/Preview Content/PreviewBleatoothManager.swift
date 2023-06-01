//
//  PreviewBleatoothManager.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 01/06/2023.
//

import Foundation
import CoreBluetooth

class PreviewBluetoothManager: BluetoothManager {
    init(initialState: CBManagerState) {
        super.init()
        self.stace = initialState
    }
}
