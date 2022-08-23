//
//  Device.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation
import CoreBluetooth

// MARK: - BluetoothDevice

public protocol BluetoothDevice {
    
    var uuidString: String { get }
}

// MARK: - Implementations

extension CBPeripheral: BluetoothDevice {
    
    public var uuidString: String {
        identifier.uuidString
    }
}
