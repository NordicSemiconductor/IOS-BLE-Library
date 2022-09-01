//
//  Bluetooth+Internal.swift
//  
//
//  Created by Dinesh Harjani on 1/9/22.
//

import Foundation

internal extension Bluetooth {
    
    func reportContinuationError<T: BluetoothDevice>(_ bluetoothError: BluetoothError, for device: T) {
        guard let pendingContinuation = continuations[device.uuidString] else { return }
        switch pendingContinuation {
        case .connection(let connection):
            connection.resume(throwing: bluetoothError)
        case .updatedService(let service):
            service.resume(throwing: bluetoothError)
        case .attribute(let att):
            att.resume(throwing: bluetoothError)
        case .notificationChange(let notification):
            notification.resume(throwing: bluetoothError)
        }
    }
    
    func reportConnectedStreamError<T: BluetoothDevice>(_ bluetoothError: BluetoothError, for device: T) {
        connectedStreams[device.uuidString]?.forEach {
            $0.finish(throwing: bluetoothError)
        }
    }
}
