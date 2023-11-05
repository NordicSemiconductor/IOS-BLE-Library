//
//  File.swift
//
//
//  Created by Nick Kibysh on 28/04/2023.
//

import Combine
import CoreBluetooth

//CG_REPLACE
/*EMPTY BLOCK*/
//CG_WITH
/*
import CoreBluetoothMock
*/
//CG_END
import Foundation

private class Observer: NSObject {
	func setup() {}
}

private class NativeObserver: Observer {
	@objc private var peripheral: CoreBluetooth.CBPeripheral

	private weak var publisher: CurrentValueSubject<CBPeripheralState, Never>!
	private var observation: NSKeyValueObservation?

	init(
		peripheral: CoreBluetooth.CBPeripheral,
		publisher: CurrentValueSubject<CBPeripheralState, Never>
	) {
		self.peripheral = peripheral
		self.publisher = publisher
		super.init()
	}

	override func setup() {
		observation = peripheral.observe(\.state, options: [.new]) {
			[weak self] _, change in
            // TODO: Check threads
            guard let self else { return }
            self.publisher.send(self.peripheral.state)
		}
	}
}

//CG_REPLACE
/*EMPTY BLOCK*/
//CG_WITH
/*
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
*/
//CG_END


public class Peripheral {
    private var serviceDiscoveryQueue = Queue<UUID>()
    
    let l = L(category: #file)
    
	/// I'm Errr from Omicron Persei 8
	public enum Err: Error {
		case badDelegate
	}

	/// The underlying CBPeripheral instance.
	public let peripheral: CBPeripheral

    // MARK: Identifying a Peripheralin page link
    /// The name of the peripheral.
    public var name: String? { peripheral.name }
    
	/// The delegate for handling peripheral events.
	public let peripheralDelegate: ReactivePeripheralDelegate

	private let stateSubject = CurrentValueSubject<CBPeripheralState, Never>(.disconnected)
	private var observer: Observer!
	private lazy var writer = CharacteristicWriter(
		writtenEventsPublisher: self.peripheralDelegate.writtenCharacteristicValuesSubject
			.eraseToAnyPublisher(),
		peripheral: self.peripheral
	)

	private lazy var reader = CharacteristicReader(
		updateEventPublisher: self.peripheralDelegate.updatedCharacteristicValuesSubject
			.eraseToAnyPublisher(),
		peripheral: peripheral
	)

	// TODO: Why don't we use default delegate?
	/// Initializes a Peripheral instance.
    ///
    /// - Parameters:
    ///   - peripheral: The CBPeripheral to manage.
    ///   - delegate: The delegate for handling peripheral events.
	public init(peripheral: CBPeripheral, delegate: ReactivePeripheralDelegate) {
		self.peripheral = peripheral
		self.peripheralDelegate = delegate
		peripheral.delegate = delegate

//CG_REPLACE
		observer = NativeObserver(peripheral: peripheral, publisher: stateSubject)
		observer.setup()
//CG_WITH
/*
         if let p = peripheral as? CBMPeripheralNative {
                     observer = NativeObserver(peripheral: p.peripheral, publisher: stateSubject)
                     observer.setup()
                 } else if let p = peripheral as? CBMPeripheralMock {
                     observer = MockObserver(peripheral: p, publisher: stateSubject)
                     observer.setup()
                 }
*/
//CG_END
	}
}

// MARK: - Channels
extension Peripheral {
	/// A publisher for the current state of the peripheral.
	public var peripheralStateChannel: AnyPublisher<CBPeripheralState, Never> {
		stateSubject.eraseToAnyPublisher()
	}
}

// MARK: - Discovering Servicesin page link
extension Peripheral {
    /// Discover services for the peripheral.
    ///
    /// - Parameter serviceUUIDs: An optional array of service UUIDs to filter the discovery results. If nil, all services will be discovered.
    /// - Returns: A publisher emitting discovered services or an error.
    public func discoverServices(serviceUUIDs: [CBUUID]?)
    -> AnyPublisher<[CBService], Error>
    {
        let id = UUID()
        
        let allServices = peripheralDelegate.discoveredServicesSubject
            .first(where: { $0.id == id } )
            .tryCompactMap { result throws -> [CBService]? in
                if let e = result.error {
                    throw e
                } else {
                    return result.value
                }
            }
            .first()
        
        return allServices.bluetooth {
            self.peripheralDelegate.discoveredServicesQueue.enqueue(id)
            self.peripheral.discoverServices(serviceUUIDs)
        }
        .autoconnect()
        .eraseToAnyPublisher()
    }
    
    /// Discovers the specified included services of a previously-discovered service.
    public func discoverIncludedServices(_ includedServiceUUIDs: [CBUUID]?, for: CBService) -> AnyPublisher<[CBService], Error> {
        fatalError()
    }
    
    /// A list of a peripheral’s discovered services.
    public var services: [CBService]? {
        peripheral.services
    }
}

//MARK: - Discovering Characteristics and Descriptorsin page link
extension Peripheral {

	/// Discover characteristics for a given service.
    ///
    /// - Parameters:
    ///   - characteristicUUIDs: An optional array of characteristic UUIDs to filter the discovery results. If nil, all characteristics will be discovered.
    ///   - service: The service for which to discover characteristics.
    /// - Returns: A publisher emitting discovered characteristics or an error.
	public func discoverCharacteristics(
		_ characteristicUUIDs: [CBUUID]?, for service: CBService
	) -> AnyPublisher<[CBCharacteristic], Error> {
        let id = UUID()
        
		let allCharacteristics = peripheralDelegate.discoveredCharacteristicsSubject
            .filter {
                $0.value.0.uuid == service.uuid
            }
            .first(where: { $0.id == id } )
			.tryCompactMap { result throws -> [CBCharacteristic]? in
                if let e = result.error {
					throw e
				} else {
                    return result.value.1
				}
			}
            .first()

		return allCharacteristics.bluetooth {
            self.peripheralDelegate.discoveredCharacteristicsQueue.enqueue(id)
			self.peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
		}
        .autoconnect()
        .eraseToAnyPublisher()
	}

	/// Discover descriptors for a given characteristic.
    ///
    /// - Parameter characteristic: The characteristic for which to discover descriptors.
    /// - Returns: A publisher emitting discovered descriptors or an error.
	public func discoverDescriptors(for characteristic: CBCharacteristic)
		-> AnyPublisher<[CBDescriptor], Error>
	{
        let id = UUID()
        
		return peripheralDelegate.discoveredDescriptorsSubject
			.filter {
                $0.value.0.uuid == characteristic.uuid
			}
            .first(where: { $0.id == id })
			.tryCompactMap { result throws -> [CBDescriptor]? in
                if let e = result.error {
					throw e
				} else {
                    return result.value.1
				}
			}
            .first()
			.bluetooth {
                self.peripheralDelegate.discoveredDescriptorsQueue.enqueue(id)
				self.peripheral.discoverDescriptors(for: characteristic)
			}
            .autoconnect()
            .eraseToAnyPublisher()
	}
}

// MARK: - Reading Characteristic and Descriptor Values
extension Peripheral {
    /// Read the value of a characteristic.
    ///
    /// - Parameter characteristic: The characteristic to read from.
    /// - Returns: A future emitting the read data or an error.
    public func readValue(for characteristic: CBCharacteristic) -> Future<Data?, Error> {
        return reader.readValue(from: characteristic)
    }

    /// Listen for updates to the value of a characteristic.
    ///
    /// - Parameter characteristic: The characteristic to monitor for updates.
    /// - Returns: A publisher emitting characteristic values or an error.
    public func listenValues(for characteristic: CBCharacteristic) -> AnyPublisher<Data, Error>
    {
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

    /// Read the value of a descriptor.
    ///
    /// - Parameter descriptor: The descriptor to read from.
    /// - Returns: A future emitting the read data or an error.
    public func readValue(for descriptor: CBDescriptor) -> Future<Data, Error> {
        fatalError()
    }
}

// MARK: - Writing Characteristic and Descriptor Values
extension Peripheral {
	/// Write data to a characteristic and wait for a response.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - characteristic: The characteristic to write to.
    /// - Returns: A publisher indicating success or an error.
	public func writeValueWithResponse(_ data: Data, for characteristic: CBCharacteristic)
		-> AnyPublisher<Void, Error>
	{
		return peripheralDelegate.writtenCharacteristicValuesSubject
			.first(where: { $0.0.uuid == characteristic.uuid })
			.tryMap { result in
				if let e = result.1 {
					throw e
				} else {
					return ()
				}
			}
			.bluetooth {
				self.peripheral.writeValue(
					data, for: characteristic, type: .withResponse)
			}
            .autoconnect()
            .eraseToAnyPublisher()
	}

	/// Write data to a characteristic without waiting for a response.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - characteristic: The characteristic to write to.
	public func writeValueWithoutResponse(_ data: Data, for characteristic: CBCharacteristic) {
		peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
	}

	/// Write data to a descriptor.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - descriptor: The descriptor to write to.
	public func writeValue(_ data: Data, for descriptor: CBDescriptor) {
		fatalError()
	}
}

// MARK: - Setting Notifications for a Characteristic’s Value
extension Peripheral {
	/// Set notification state for a characteristic.
    ///
    /// - Parameters:
    ///   - isEnabled: Whether notifications should be enabled or disabled.
    ///   - characteristic: The characteristic for which to set the notification state.
    /// - Returns: A publisher indicating success or an error.
	public func setNotifyValue(_ isEnabled: Bool, for characteristic: CBCharacteristic)
		-> AnyPublisher<Bool, Error>
	{
		if characteristic.isNotifying == isEnabled {
			return Just(isEnabled)
				.setFailureType(to: Error.self)
                .eraseToAnyPublisher()
		}

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
            .autoconnect()
            .eraseToAnyPublisher()
	}
}

// MARK: - Accessing a Peripheral’s Signal Strengthin page link
extension Peripheral {
    /// Retrieves the current RSSI value for the peripheral while connected to the central manager.
    public func readRSSI() -> AnyPublisher<NSNumber, Error> {
        peripheralDelegate.readRSSISubject
            .tryMap { rssi in
                if let error = rssi.1 {
                    throw error
                } else {
                    return rssi.0
                }
            }
            .first()
            .bluetooth {
                self.peripheral.readRSSI()
            }
            .autoconnect()
            .eraseToAnyPublisher()
    }
}
