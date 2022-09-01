//
//  Bluetooth+Internal.swift
//  
//
//  Created by Dinesh Harjani on 1/9/22.
//

import Foundation

internal extension Bluetooth {
    
    func reportConnectedStreamError<T: BluetoothDevice>(_ bluetoothError: BluetoothError, for device: T) {
        connectedStreams[device.uuidString]?.forEach {
            $0.finish(throwing: bluetoothError)
        }
    }
}
