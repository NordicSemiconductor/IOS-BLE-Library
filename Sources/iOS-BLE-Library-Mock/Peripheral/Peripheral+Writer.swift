//
//  Peripheral+Writer.swift
//  iOS-BLE-Library
//
//  Created by Nick Kibysh on 07/05/2023.
//  Copyright © 2025 Nordic Semiconductor ASA. All rights reserved.
//

import Combine
import CoreBluetoothMock
import Foundation

extension Peripheral {
    
    // MARK: OperationQueue
    
    class OperationQueue {
        let queue = Foundation.OperationQueue()
        let peripheral: CBPeripheral

        init(peripheral: CBPeripheral) {
            self.peripheral = peripheral
            queue.maxConcurrentOperationCount = 1
        }
    }

    class CharacteristicWriter: OperationQueue {
        let writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>

        init(writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>, peripheral: CBPeripheral) {
            self.writtenEventsPublisher = writtenEventsPublisher
            super.init(peripheral: peripheral)
        }
    }

    class CharacteristicReader: OperationQueue {
        let updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>

        init(updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>, peripheral: CBPeripheral) {
            self.updateEventPublisher = updateEventPublisher
            super.init(peripheral: peripheral)
        }
    }

    class DescriptorWriter: OperationQueue {
        let writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>

        init(writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
             peripheral: CBPeripheral) {
            self.writtenEventsPublisher = writtenEventsPublisher
            super.init(peripheral: peripheral)
        }
    }

    class DescriptorReader: OperationQueue {
        let updateEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>

        init(updateEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
             peripheral: CBPeripheral) {
            self.updateEventsPublisher = updateEventsPublisher
            super.init(peripheral: peripheral)
        }
    }
}

// MARK: - write(_to:CBCharacteristic)

extension Peripheral.CharacteristicWriter {
    
    func write(_ value: Data, to characteristic: CBCharacteristic) -> Future<Void, Error> {
        let operation = WriteCharacteristicOperation(
            data: value,
            writtenEventsPublisher: writtenEventsPublisher,
            characteristic: characteristic,
            peripheral: peripheral)
        queue.addOperation(operation)
        return operation.future
    }
}

// MARK: - readValue(CBCharacteristic)

extension Peripheral.CharacteristicReader {
    
    func readValue(from characteristic: CBCharacteristic) -> Future<Data?, Error> {
        let operation = ReadCharacteristicOperation(
            updateEventPublisher: updateEventPublisher,
            characteristic: characteristic,
            peripheral: peripheral
        )
        queue.addOperation(operation)
        return operation.future
    }
}

// MARK: - write(_to:CBDescriptor)

extension Peripheral.DescriptorWriter {
    
    func write(_ value: Data, to descriptor: CBDescriptor) -> Future<Void, Error> {
        let operation = WriteDescriptorOperation(
            data: value,
            writtenEventsPublisher: writtenEventsPublisher,
            descriptor: descriptor,
            peripheral: peripheral
        )
        queue.addOperation(operation)
        return operation.future
    }
}

// MARK: - readValue(CBDescriptor)

extension Peripheral.DescriptorReader {
    
    func readValue(from descriptor: CBDescriptor) -> Future<Any?, Error> {
        let operation = ReadDescriptorOperation(
            updateEventPublisher: updateEventsPublisher,
            descriptor: descriptor,
            peripheral: peripheral
        )
        queue.addOperation(operation)
        return operation.future
    }
}

// MARK: - BasicOperation

private class BasicOperation<T>: Operation, @unchecked Sendable {
    
    // MARK: State
    
    enum State: String {
        case ready, executing, finished

        var keyPath: String {
            "is\(rawValue.capitalized)"
        }
    }
    
    // MARK: Properties
    
    let peripheral: CBPeripheral
    var cancellable: AnyCancellable?

    private(set) var promise: ((Result<T, Error>) -> Void)?

    lazy private(set) var future: Future<T, Error> = Future { [unowned self] promise in
        self.promise = promise
    }

    var state: State = .ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    override var isExecuting: Bool {
        state == .executing
    }

    override var isFinished: Bool {
        state == .finished
    }

    override func cancel() {
        cancellable?.cancel()
    }

    override var isAsynchronous: Bool {
        true
    }
    
    // MARK: init
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    // MARK: match(_to:)
    
    func match(_ eventCharacteristic: CBCharacteristic, to characteristic: CBCharacteristic) -> Bool {
        guard eventCharacteristic.uuid == characteristic.uuid else {
            return false
        }
        guard let eventService = eventCharacteristic.service,
              let targetService = characteristic.service else {
            return true
        }
        return eventService.uuid == targetService.uuid
    }
    
    func match(_ eventDescriptor: CBDescriptor, to descriptor: CBDescriptor) -> Bool {
        guard eventDescriptor.uuid == descriptor.uuid else {
            return false
        }
        guard let eventCharacteristic = eventDescriptor.characteristic,
              let targetCharacteristic = descriptor.characteristic else {
            return true
        }
        return match(eventCharacteristic, to: targetCharacteristic)
    }
}

// MARK: - WriteCharacteristicOperation

private class WriteCharacteristicOperation: BasicOperation<Void>, @unchecked Sendable {

    let writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>
    let characteristic: CBCharacteristic

    let data: Data

    init(data: Data, writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>, characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        self.data = data
        self.writtenEventsPublisher = writtenEventsPublisher
        self.characteristic = characteristic
        super.init(peripheral: peripheral)
    }

    override func main() {
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

    override func start() {
        if isCancelled {
            state = .finished
            return
        }

        self.cancellable = writtenEventsPublisher.share()
            .filter { [unowned self] eventCharacteristic, _ in
                match(eventCharacteristic, to: characteristic)
            }
            .first()
            .tryMap { eventCharacteristic, error in
                if let error {
                    throw error
                } else {
                    return eventCharacteristic
                }
            }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    self.promise?(.success(()))
                case .failure(let error):
                    self.promise?(.failure(error))
                }
                self.state = .finished
            } receiveValue: { _ in

            }

        state = .executing
        main()
    }
}

// MARK: - ReadCharacteristicOperation

private class ReadCharacteristicOperation: BasicOperation<Data?>, @unchecked Sendable {
    
    let updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>
    let characteristic: CBCharacteristic

    init(updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>,
         characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        self.updateEventPublisher = updateEventPublisher
        self.characteristic = characteristic
        super.init(peripheral: peripheral)
    }

    override func main() {
        peripheral.readValue(for: characteristic)
    }

    override func start() {
        if isCancelled {
            state = .finished
            return
        }

        self.cancellable = updateEventPublisher.share()
            .filter { [unowned self] eventCharacteristic, _ in
                match(eventCharacteristic, to: characteristic)
            }
            .first()
            .tryMap { eventCharacteristic, error in
                if let error {
                    throw error
                } else {
                    return eventCharacteristic.value
                }
            }
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    promise?(.failure(error))
                }
                state = .finished
            } receiveValue: { [unowned self] data in
                promise?(.success(data))
            }

        state = .executing
        main()
    }
}

// MARK: - WriteDescriptorOperation

private class WriteDescriptorOperation: BasicOperation<Void>, @unchecked Sendable {

    let writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>
    let descriptor: CBDescriptor

    let data: Data

    init(data: Data, writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>, descriptor: CBDescriptor, peripheral: CBPeripheral) {
        self.data = data
        self.writtenEventsPublisher = writtenEventsPublisher
        self.descriptor = descriptor
        super.init(peripheral: peripheral)
    }

    override func main() {
        peripheral.writeValue(data, for: descriptor)
    }

    override func start() {
        if isCancelled {
            state = .finished
            return
        }

        self.cancellable = writtenEventsPublisher.share()
            .filter { [unowned self] eventDescriptor, error in
                match(eventDescriptor, to: descriptor)
            }
            .first()
            .tryMap { eventDescriptor, error in
                if let error {
                    throw error
                } else {
                    return eventDescriptor
                }
            }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    self.promise?(.success(()))
                case .failure(let error):
                    self.promise?(.failure(error))
                }
                self.state = .finished
            } receiveValue: { _ in

            }

        state = .executing
        main()
    }
}

// MARK: - ReadDescriptorOperation

private class ReadDescriptorOperation: BasicOperation<Any?>, @unchecked Sendable {
    
    let updateEventPublisher: AnyPublisher<(CBDescriptor, Error?), Never>
    let descriptor: CBDescriptor

    init(updateEventPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
         descriptor: CBDescriptor, peripheral: CBPeripheral) {
        self.updateEventPublisher = updateEventPublisher
        self.descriptor = descriptor
        super.init(peripheral: peripheral)
    }

    override func main() {
        peripheral.readValue(for: descriptor)
    }

    override func start() {
        if isCancelled {
            state = .finished
            return
        }

        self.cancellable = updateEventPublisher.share()
            .filter { [unowned self] eventDescriptor, error in
                match(eventDescriptor, to: descriptor)
            }
            .first()
            .tryMap { eventDescriptor, error in
                if let error {
                    throw error
                } else {
                    return eventDescriptor.value
                }
            }
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.promise?(.failure(error))
                }
                self.state = .finished
            } receiveValue: { data in
                self.promise?(.success(data))
            }

        state = .executing
        main()
    }
}
