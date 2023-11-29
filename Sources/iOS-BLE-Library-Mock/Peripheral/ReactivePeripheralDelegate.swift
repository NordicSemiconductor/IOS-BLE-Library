//
//  File.swift
//
//
//  Created by Nick Kibysh on 28/04/2023.
//

import Combine
import CoreBluetoothMock
import Foundation

struct BluetoothOperationResult<T> {
    let value: T
    let error: Error?
    let id: UUID
}

open class ReactivePeripheralDelegate: NSObject, CBPeripheralDelegate {
	let l = L(category: #file)
    
    typealias NonFailureSubject<T> = PassthroughSubject<T, Never>
    
    struct TaskID {
        let id: UUID
        let task: () -> ()
    }
    
    var discoveredServicesQueue = Queue<TaskID>()
    var discoveredCharacteristicsQueue = Queue<UUID>()
    var discoveredDescriptorsQueue = Queue<UUID>()
    
    // MARK: Discovering Services
	let discoveredServicesSubject = NonFailureSubject<
        BluetoothOperationResult<[CBService]?>
    >()
    
    /*
	let discoveredIncludedServicesSubject = PassthroughSubject<
        BluetoothOperationResult<(CBService, [CBService]?)>, Never
	>()
     */
    
    // MARK: Discovering Characteristics and their Descriptors
	let discoveredCharacteristicsSubject = NonFailureSubject<
        BluetoothOperationResult<(CBService, [CBCharacteristic]?)>
	>()
	let discoveredDescriptorsSubject = NonFailureSubject<
        BluetoothOperationResult<(CBCharacteristic, [CBDescriptor]?)>
	>()

	// MARK: Retrieving Characteristic and Descriptor Values
	let updatedCharacteristicValuesSubject = PassthroughSubject<
		(CBCharacteristic, Error?), Never
	>()
	let updatedDescriptorValuesSubject = PassthroughSubject<
		(CBDescriptor, Error?), Never
	>()

	let writtenCharacteristicValuesSubject = PassthroughSubject<
		(CBCharacteristic, Error?), Never
	>()
	let writtenDescriptorValuesSubject = PassthroughSubject<
		(CBDescriptor, Error?), Never
	>()

	// MARK: Managing Notifications for a Characteristic’s Value
	let notificationStateSubject = PassthroughSubject<
		(CBCharacteristic, Error?), Never
	>()

	// MARK: Monitoring Changes to a Peripheral’s Name or Services
	let updateNameSubject = PassthroughSubject<String?, Never>()
    let modifyServicesSubject = PassthroughSubject<[CBService], Never>()
    
    let readRSSISubject = PassthroughSubject<(NSNumber, Error?), Never>()
    
    // MARK: - Channels
    
    
	// MARK: Discovering Services

	open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let operation = discoveredServicesQueue.dequeue()!
        l.d("\(#function). Operation ID: \(operation.id)")
        print("--| Operation ID: \(operation.id)")
        
        if let services = peripheral.services {
            for service in services {
                l.d("Service: \(service.uuid)")
                print("--| Service: \(service.uuid)")
            }
            if services.isEmpty {
                l.d("No Services Discovered")
                print("--| No Services Discovered")
            }
        }
        print("\n")
        
        let result = BluetoothOperationResult<[CBService]?>(value: peripheral.services, error: error, id: operation.id)
                
        discoveredServicesSubject.send(result)
        
        discoveredServicesQueue.head?.task()
	}

    /*
	public func peripheral(
		_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService,
		error: Error?
	) {
		discoveredIncludedServicesSubject.send((service, service.includedServices, error))
	}
     */

	// MARK: Discovering Characteristics and their Descriptors

	open func peripheral(
		_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
		error: Error?
    ) {
        let operationId = discoveredCharacteristicsQueue.dequeue()!
        let result = BluetoothOperationResult<(CBService, [CBCharacteristic]?)>(value: (service, service.characteristics), error: error, id: operationId)
        
		discoveredCharacteristicsSubject.send(result)
	}

	open func peripheral(
		_ peripheral: CBPeripheral,
		didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?
	) {
        let operationId = discoveredDescriptorsQueue.dequeue()!
        let result = BluetoothOperationResult<(CBCharacteristic, [CBDescriptor]?)>(value: (characteristic, characteristic.descriptors), error: error, id: operationId)
        
		discoveredDescriptorsSubject.send(result)
	}

	// MARK: Retrieving Characteristic and Descriptor Values

	open func peripheral(
		_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
		error: Error?
	) {
		updatedCharacteristicValuesSubject.send((characteristic, error))
	}

	open func peripheral(
		_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor,
		error: Error?
	) {
		updatedDescriptorValuesSubject.send((descriptor, error))
	}

	// MARK: Writing Characteristic and Descriptor Values

	open func peripheral(
		_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic,
		error: Error?
	) {
		writtenCharacteristicValuesSubject.send((characteristic, error))
	}

	open func peripheral(
		_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?
	) {
		writtenDescriptorValuesSubject.send((descriptor, error))
	}

	open func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
		l.i(#function)
		fatalError()
	}

	// MARK: Managing Notifications for a Characteristic’s Value

	open func peripheral(
		_ peripheral: CBPeripheral,
		didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?
	) {
		notificationStateSubject.send((characteristic, error))
	}

	// MARK: Retrieving a Peripheral’s RSSI Data

	open func peripheral(
		_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?
	) {
        readRSSISubject.send((RSSI, error))
	}

	// MARK: Monitoring Changes to a Peripheral’s Name or Services

	open func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
		updateNameSubject.send(peripheral.name)
	}

	open func peripheral(
		_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]
	) {
        modifyServicesSubject.send(invalidatedServices)
	}

	// MARK: Monitoring L2CAP Channels
/*
	public func peripheral(
		_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?
	) {
		l.i(#function)
		fatalError()
	}
*/
}
