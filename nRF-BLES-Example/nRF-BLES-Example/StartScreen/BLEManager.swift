//
//  BLEManager.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 01/06/2023.
//

import Foundation
import iOS_BLE_Library
import CoreBluetooth
import Combine

class BluetoothManager: ObservableObject {
    private var cancelables: Set<AnyCancellable> = Set()
    let centralManager: CentralManager
    
    @Published var stace: CBManagerState = .unknown
    @Published var isScanning: Bool = false
    
    init(centralManager: CentralManager = CentralManager()) {
        self.centralManager = centralManager
        self.enableNotifications()
    }
    
    func enableNotifications() {
        self.centralManager.isScanningChannel.sink { [weak self] isScanning in
            self?.isScanning = isScanning
        }
        .store(in: &cancelables)
        
        self.centralManager.stateChannel.sink { [weak self] state in
            self?.stace = state
        }
        .store(in: &cancelables)
    }
}
