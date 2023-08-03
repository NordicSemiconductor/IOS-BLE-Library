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

public class Peripheral {
    public enum Error: Swift.Error {
        case badDelegate
    }
    
    public let peripheral: CBPeripheral
    public let peripheralDelegate: ReactivePeripheralDelegate
    
    private let stateSubject = CurrentValueSubject<CBPeripheralState, Never>(.disconnected)
    private var observer: Observer!
    private lazy var writer = CharacteristicWriter(
        writtenEventsPublisher: self.peripheralDelegate.writtenCharacteristicValuesSubject.eraseToAnyPublisher(),
        peripheral: self.peripheral
    )
    
    private lazy var reader = CharacteristicReader(
        updateEventPublisher: self.peripheralDelegate.updatedCharacteristicValuesSubject.eraseToAnyPublisher(),
        peripheral: peripheral
    )
    
    // TODO: Why don't we use default delegate?
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
extension Peripheral {
    public var peripheralStateChannel: AnyPublisher<CBPeripheralState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
}

extension Peripheral {
    // TODO: Extract repeated code
    public func discoverServices(serviceUUIDs: [CBMUUID]?) -> Publishers.BluetoothPublisher<CBService, Swift.Error> {
        let allServices = peripheralDelegate.discoveredServicesSubject
            .tryCompactMap { result throws -> [CBService]? in
                if let e = result.1 {
                    throw e
                } else {
                    return result.0
                }
            }
            .flatMap { services -> Publishers.Sequence<[CBService], Swift.Error> in
                Publishers.Sequence(sequence: services)
            }
        
        let filtered: AnyPublisher<CBService, Swift.Error>
        
        if let serviceList = serviceUUIDs {
            filtered = allServices.guestList(serviceList, keypath: \.uuid).eraseToAnyPublisher()
        } else {
            filtered = allServices.eraseToAnyPublisher()
        }
        
        return filtered.bluetooth {
            self.peripheral.discoverServices(serviceUUIDs)
        }
    }
    
    public func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) -> Publishers.BluetoothPublisher<CBCharacteristic, Swift.Error> {
        let allCharacteristics = peripheralDelegate.discoveredCharacteristicsSubject
            .filter {
                $0.0.uuid == service.uuid
            }
            .tryCompactMap { result throws -> [CBCharacteristic]? in
                if let e = result.2 {
                    throw e
                } else {
                    return result.1
                }
            }
            .flatMap { characteristics -> Publishers.Sequence<[CBCharacteristic], Swift.Error> in
                Publishers.Sequence(sequence: characteristics)
            }
        
        let filtered: AnyPublisher<CBCharacteristic, Swift.Error>
            
        if let list = characteristicUUIDs {
            filtered = allCharacteristics
                .guestList(list, keypath: \.uuid)
                .eraseToAnyPublisher()
        } else {
            filtered = allCharacteristics.eraseToAnyPublisher()
        }
        
        return filtered.bluetooth {
            self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }
    
    public func discoverDescriptors(for characteristic: CBCharacteristic) -> Publishers.BluetoothPublisher<CBDescriptor, Swift.Error> {
        return peripheralDelegate.discoveredDescriptorsSubject
            .filter {
                $0.0.uuid == characteristic.uuid
            }
            .tryCompactMap { result throws -> [CBDescriptor]? in
                if let e = result.2 {
                    throw e
                } else {
                    return result.1
                }
            }
            .flatMap { descriptors -> Publishers.Sequence<[CBDescriptor], Swift.Error> in
                Publishers.Sequence(sequence: descriptors)
            }
            .bluetooth {
                self.peripheral.discoverDescriptors(for: characteristic)
            }
    }
}

// MARK: - Writing Characteristic and Descriptor Values
extension Peripheral {
    public func writeValueWithResponse(_ data: Data, for characteristic: CBMCharacteristic) -> Future<Void, Swift.Error> {
        return writer.write(data, to: characteristic)
    }
    
    public func writeValueWithoutResponse(_ data: Data, for characteristic: CBMCharacteristic) {
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    public func writeValue(_ value: Data, for descriptor: CBDescriptor) {
        fatalError()
    }
}

// MARK: - Reading Characteristic and Descriptor Values
extension Peripheral {
    public func readValue(for characteristic: CBCharacteristic) -> Future<Data?, Swift.Error> {
        return reader.readValue(from: characteristic)
    }
    
    public func listenValues(for characteristic: CBCharacteristic) -> AnyPublisher<Data, Swift.Error> {
        return peripheralDelegate.updatedCharacteristicValuesSubject
            .filter { $0.0.uuid == characteristic.uuid }
            .tryCompactMap { (ch, err) in
                if let err {
                    throw err
                }
                
                return ch.value
            }
            .eraseToAnyPublisher()
    }
    
    public func readValue(for descriptor: CBDescriptor) -> Future<Data, Swift.Error> {
        fatalError()
    }

}

// MARK: - Setting Notifications for a Characteristic’s Value
extension Peripheral {
    public func setNotifyValue(_ isEnabled: Bool, for characteristic: CBCharacteristic) -> Publishers.BluetoothPublisher<Bool, Swift.Error> {
        return peripheralDelegate.notificationStateSubject
            .first { $0.0.uuid == characteristic.uuid }
            .tryMap { result in
                if let e = result.1 {
                    throw e 
                }
                return result.0.isNotifying
            }
            .bluetooth {
                self.peripheral.setNotifyValue(isEnabled, for: characteristic)
            }
    }
}
