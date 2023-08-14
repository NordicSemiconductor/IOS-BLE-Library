//
//  Bluetooth+Internal.swift
//  
//
//  Created by Dinesh Harjani on 1/9/22.
//

import Foundation
/*
internal extension Bluetooth {
    
    func reportContinuationError<T: CBPeripheral>(_ bluetoothError: BluetoothError, for device: T) {
        guard let pendingContinuation = continuations[device.identifier.uuidString] else { return }
        switch pendingContinuation {
        case .connection(let connection):
            connection.resume(throwing: bluetoothError)
        case .serviceDiscovery(let discovery):
            discovery.resume(throwing: bluetoothError)
        case .updatedService(let service):
            service.resume(throwing: bluetoothError)
        case .attribute(let att):
            att.resume(throwing: bluetoothError)
        case .notificationChange(let notification):
            notification.resume(throwing: bluetoothError)
        }
    }
    
    func reportDataStreamError<T: CBPeripheral>(_ bluetoothError: BluetoothError, for device: T) {
        dataStreams[device.identifier.uuidString]?.forEach {
            $0.finish(throwing: bluetoothError)
        }
        dataStreams[device.identifier.uuidString]?.removeAll()
    }
}
*/
