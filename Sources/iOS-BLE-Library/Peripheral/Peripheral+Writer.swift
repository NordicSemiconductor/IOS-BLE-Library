//
//  File.swift
//
//
//  Created by Nick Kibysh on 07/05/2023.
//

import Combine
//CG_REPLACE
import CoreBluetooth
//CG_WITH
/*
import CoreBluetoothMock
*/
//CG_END
import Foundation

extension Peripheral {
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

		init(
			writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>,
			peripheral: CBPeripheral
		) {
			self.writtenEventsPublisher = writtenEventsPublisher
			super.init(peripheral: peripheral)
		}
	}

	class CharacteristicReader: OperationQueue {
		let updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>

		init(
			updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>,
			peripheral: CBPeripheral
		) {
			self.updateEventPublisher = updateEventPublisher
			super.init(peripheral: peripheral)
		}
	}
    
    class DescriptorWriter: OperationQueue {
        let writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>

        init(
            writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
            peripheral: CBPeripheral
        ) {
            self.writtenEventsPublisher = writtenEventsPublisher
            super.init(peripheral: peripheral)
        }
    }
    
    class DescriptorReader: OperationQueue {
        let updateEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>

        init(
            updateEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
            peripheral: CBPeripheral
        ) {
            self.updateEventsPublisher = updateEventsPublisher
            super.init(peripheral: peripheral)
        }
    }
}

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

extension Peripheral.CharacteristicReader {
	func readValue(from characteristc: CBCharacteristic) -> Future<Data?, Error> {
		let operation = ReadCharacteristicOperation(
			updateEventPublisher: updateEventPublisher,
			characteristic: characteristc,
			peripheral: peripheral
		)

		queue.addOperation(operation)

		return operation.future
	}
}

extension Peripheral.DescriptorWriter {
    func write(_ value: Data, to dsecriptor: CBDescriptor) -> Future<Void, Error> {
        let operation = WriteDescriptorOperation(
            data: value,
            writtenEventsPublisher: writtenEventsPublisher,
            descriptor: dsecriptor,
            peripheral: peripheral
        )

        queue.addOperation(operation)

        return operation.future
    }
}

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

private class BasicOperation<T>: Operation, @unchecked Sendable {
	let peripheral: CBPeripheral
	var cancelable: AnyCancellable?

	private(set) var promise: ((Result<T, Error>) -> Void)?

	enum State: String {
		case ready, executing, finished

		var keyPath: String {
			"is\(rawValue.capitalized)"
		}
	}

	init(peripheral: CBPeripheral) {
		self.peripheral = peripheral
	}

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
		cancelable?.cancel()
	}

	override var isAsynchronous: Bool {
		true
	}
}

private class WriteCharacteristicOperation: BasicOperation<Void>, @unchecked Sendable {

	let writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>
	let characteristic: CBCharacteristic

	let data: Data

	init(
		data: Data, writtenEventsPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>,
		characteristic: CBCharacteristic, peripheral: CBPeripheral
	) {
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

		self.cancelable = writtenEventsPublisher.share()
			.filter { $0.0.uuid == self.characteristic.uuid && $0.0.service?.uuid == self.characteristic.service?.uuid }
			.first()
			.tryMap { v in
				if let e = v.1 {
					throw e
				} else {
					return v.0
				}
			}
			.sink { [unowned self] completion in
				switch completion {
				case .finished:
					self.promise?(.success(()))
				case .failure(let e):
					self.promise?(.failure(e))
				}
				self.state = .finished
			} receiveValue: { _ in

			}

		state = .executing
		main()
	}
}

private class ReadCharacteristicOperation: BasicOperation<Data?>, @unchecked Sendable {
	let updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>
	let characteristic: CBCharacteristic

	init(
		updateEventPublisher: AnyPublisher<(CBCharacteristic, Error?), Never>,
		characteristic: CBCharacteristic, peripheral: CBPeripheral
	) {
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

		self.cancelable = updateEventPublisher.share()
			.filter { $0.0.uuid == self.characteristic.uuid && $0.0.service?.uuid == self.characteristic.service?.uuid }
			.first()
			.tryMap { v in
				if let e = v.1 {
					throw e
				} else {
					return v.0.value
				}
			}
			.sink { [unowned self] completion in
				if case .failure(let e) = completion {
					self.promise?(.failure(e))
				}
				self.state = .finished
			} receiveValue: { v in
				self.promise?(.success(v))
			}

		state = .executing
		main()
	}
}

private class WriteDescriptorOperation: BasicOperation<Void>, @unchecked Sendable {

    let writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>
    let descriptor: CBDescriptor

    let data: Data

    init(
        data: Data, writtenEventsPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
        descriptor: CBDescriptor, peripheral: CBPeripheral
    ) {
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

        self.cancelable = writtenEventsPublisher.share()
            .filter { $0.0.uuid == self.descriptor.uuid && $0.0.characteristic?.uuid == self.descriptor.characteristic?.uuid && $0.0.characteristic?.uuid == self.descriptor.characteristic?.uuid && $0.0.characteristic?.service?.uuid == self.descriptor.characteristic?.service?.uuid }
            .first()
            .tryMap { v in
                if let e = v.1 {
                    throw e
                } else {
                    return v.0
                }
            }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    self.promise?(.success(()))
                case .failure(let e):
                    self.promise?(.failure(e))
                }
                self.state = .finished
            } receiveValue: { _ in

            }

        state = .executing
        main()
    }
}

private class ReadDescriptorOperation: BasicOperation<Any?>, @unchecked Sendable {
    let updateEventPublisher: AnyPublisher<(CBDescriptor, Error?), Never>
    let descriptor: CBDescriptor

    init(
        updateEventPublisher: AnyPublisher<(CBDescriptor, Error?), Never>,
        descriptor: CBDescriptor, peripheral: CBPeripheral
    ) {
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

        self.cancelable = updateEventPublisher.share()
            .filter { $0.0.uuid == self.descriptor.uuid && $0.0.characteristic?.uuid == self.descriptor.characteristic?.uuid &&	$0.0.characteristic?.uuid == self.descriptor.characteristic?.uuid && $0.0.characteristic?.service?.uuid == self.descriptor.characteristic?.service?.uuid }
            .first()
            .tryMap { v in
                if let e = v.1 {
                    throw e
                } else {
                    return v.0.value
                }
            }
            .sink { [unowned self] completion in
                if case .failure(let e) = completion {
                    self.promise?(.failure(e))
                }
                self.state = .finished
            } receiveValue: { v in
                self.promise?(.success(v))
            }

        state = .executing
        main()
    }
}
