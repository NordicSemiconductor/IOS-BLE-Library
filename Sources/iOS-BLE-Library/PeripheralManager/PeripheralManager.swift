//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/04/2023.
//

import Foundation
import CoreBluetoothMock
import Combine

public class PeripheralManager {
    public enum Error: Swift.Error {
        case badDelegate
    }
    
    public let peripheral: CBPeripheral
    public let peripheralDelegate: ReactivePeripheralDelegate
    
    public init(peripheral: CBPeripheral, delegate: ReactivePeripheralDelegate) {
        self.peripheral = peripheral
        self.peripheralDelegate = delegate
        peripheral.delegate = delegate
    }
}

extension PeripheralManager {
    public func discoverServices() -> Publishers.BluetoothPublisher<CBService> {
        return peripheralDelegate.discoveredServicesSubject
            .tryCompactMap { result throws -> [CBService]? in
                if let e = result.1 {
                    throw e
                } else {
                    return result.0
                }
            }
            .flatMap { services in
                Publishers.Sequence(sequence: services)
            }
            .btPublisher {
                self.peripheral.discoverServices(nil)
            }
    }
    
    public func discoverServices(serviceUUIDs: [CBMUUID]) -> Publishers.BluetoothPublisher<CBService> {
        return peripheralDelegate.discoveredServicesSubject
            .tryCompactMap { result throws -> [CBService]? in
                if let e = result.1 {
                    throw e
                } else {
                    return result.0
                }
            }
            .flatMap { services in
                Publishers.Sequence(sequence: services)
            }
            .guestList(serviceUUIDs, keypath: \.uuid)
            .btPublisher {
                self.peripheral.discoverServices(serviceUUIDs)
            }
    }
}
