//
//  Bluetooth+CBCentralManagerDelegate.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation
import CoreBluetooth

// MARK: - CBCentralManagerDelegate

extension Bluetooth: CBCentralManagerDelegate {
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let isConnectable = (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
        if filters.contains(where: { $0 == .connectable }) {
            if isConnectable ?? false {
                devicePublisher.send((peripheral, advertisementData, RSSI))
            }
        } else {
            devicePublisher.send((peripheral, advertisementData, RSSI))
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        logger.debug("[Callback] centralManagerDidUpdateState(central: \(central))")
        managerState = central.state
        logger.info("Bluetooth changed state: \(central.state)")
        
        if central.state != .poweredOn {
            shouldScan = false
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logger.debug("[Callback] centralManager(central: \(central), didConnect: \(peripheral))")
        connectedStreams[peripheral.identifier.uuidString] = [AsyncThrowingStream<AsyncStreamValue, Error>.Continuation]()
        guard case .connection(let continuation)? = continuations[peripheral.identifier.uuidString] else { return }
        continuation.resume(returning: peripheral)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logger.debug("[Callback] centralManager(central: \(central), didFailToConnect: \(peripheral), error: \(error.debugDescription))")
        // Can only happen when trying to connect.
        guard case .connection(let continuation)? = continuations[peripheral.identifier.uuidString] else { return }
        if let error = error {
            let rethrow = BluetoothError.failedToConnect(description: error.localizedDescription)
            continuation.resume(throwing: rethrow)
            reportConnectedStreamError(rethrow, for: peripheral)
        } else {
            // Success.
            continuation.resume(returning: peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        logger.debug("[Callback] centralManager(central: \(central), didDisconnectPeripheral: \(peripheral), error: \(error.debugDescription))")
        if let error = error {
            let rethrow = BluetoothError(error)
            // Can happen at any time.
            reportContinuationError(rethrow, for: peripheral)
            reportConnectedStreamError(rethrow, for: peripheral)
        } else {
            // Success.
            connectedStreams[peripheral.identifier.uuidString]?.forEach {
                $0.finish()
            }
            guard case .connection(let ccontinuation)? = continuations[peripheral.identifier.uuidString] else { return }
            ccontinuation.resume(returning: peripheral)
        }
    }
}
