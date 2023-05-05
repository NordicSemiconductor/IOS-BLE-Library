//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/04/2023.
//

import Foundation
import CoreBluetoothMock
import CoreBluetooth
import Combine

private class Observer: NSObject {
    func setup() { }
}

private class NativeObserver: Observer {
    @objc private var peripheral: CoreBluetooth.CBPeripheral
    
    private weak var publisher: CurrentValueSubject<CBPeripheralState, Never>!
    private var observation: NSKeyValueObservation?
    
    init(peripheral: CoreBluetooth.CBPeripheral, publisher: CurrentValueSubject<CBPeripheralState, Never>) {
        self.peripheral = peripheral
        self.publisher = publisher
        super.init()
    }
    
    override func setup() {
        observation = peripheral.observe(\.state, options: [.new]) { [weak self] _, change in
            #warning("queue can be not only main")
            DispatchQueue.main.async {
                guard let self else { return }
                self.publisher.send(self.peripheral.state)
            }
        }
    }
}

// TODO: Generate this code
private class MockObserver: Observer {
    @objc private var peripheral: CBMPeripheralMock
    
    private weak var publisher: CurrentValueSubject<CBPeripheralState, Never>!
    private var observation: NSKeyValueObservation?
    
    init(peripheral: CBMPeripheralMock, publisher: CurrentValueSubject<CBPeripheralState, Never>) {
        self.peripheral = peripheral
        self.publisher = publisher
        super.init()
    }
    
    override func setup() {
        observation = peripheral.observe(\.state, options: [.new]) { [weak self] _, change in
            #warning("queue can be not only main")
            DispatchQueue.main.async {
                guard let self else { return }
                self.publisher.send(self.peripheral.state)
            }
        }
    }
}

// TODO: It deserves a better name. `PeripheralManager` sounds similar to `CBPeripheralManager` but has a different purpose.
public class PeripheralManager {
    public enum Error: Swift.Error {
        case badDelegate
    }
    
    public let peripheral: CBPeripheral
    public let peripheralDelegate: ReactivePeripheralDelegate
    
    private let stateSubject = CurrentValueSubject<CBPeripheralState, Never>(.disconnected)
    private var observer: Observer!
    
    public init(peripheral: CBPeripheral, delegate: ReactivePeripheralDelegate) {
        self.peripheral = peripheral
        self.peripheralDelegate = delegate
        peripheral.delegate = delegate
        
        if let p = peripheral as? CBMPeripheralNative {
            observer = NativeObserver(peripheral: p.peripheral, publisher: stateSubject)
            observer.setup()
        } else if let p = peripheral as? CBMPeripheralMock {
            observer = MockObserver(peripheral: p, publisher: stateSubject)
            observer.setup()
        }
        
    }
}

// MARK: - Channels
extension PeripheralManager {
    public var peripheralStateChannel: AnyPublisher<CBPeripheralState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}

extension PeripheralManager {
    public func discoverServices() -> Publishers.BluetoothPublisher<CBService, Swift.Error> {
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
            .bluetooth {
                self.peripheral.discoverServices(nil)
            }
    }
    
    public func discoverServices(serviceUUIDs: [CBMUUID]) -> Publishers.BluetoothPublisher<CBService, Swift.Error> {
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
            .bluetooth {
                self.peripheral.discoverServices(serviceUUIDs)
            }
    }
}
