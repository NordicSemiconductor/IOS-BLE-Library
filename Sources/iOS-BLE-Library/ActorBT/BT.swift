//
//  File.swift
//  
//
//  Created by Nick Kibysh on 06/04/2023.
//

import Foundation
import CoreBluetoothMock
import AsyncAlgorithms

actor BluetoothActor {
    private let bleManager = BLEManager()
    
    public private (set) var isScanning = false
    
    func scan() {
        isScanning = true
    }
    
    func stopScan() {
        isScanning = false
    }
}

private final class BLEManager: NSObject {
    
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CoreBluetoothMock.CBMCentralManager) {
        
    }
}
