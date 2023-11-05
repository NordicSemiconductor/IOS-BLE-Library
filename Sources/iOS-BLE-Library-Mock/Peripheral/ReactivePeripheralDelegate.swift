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

public class ReactivePeripheralDelegate: NSObject, CBPeripheralDelegate {
	let l = L(category: #file)
    
    typealias NonFailureSubject<T> = PassthroughSubject<T, Never>
    
    var discoveredServicesQueue = Queue<UUID>()
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
    
	// MARK: Discovering Services

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let operationId = discoveredServicesQueue.dequeue()!
        let result = BluetoothOperationResult<[CBService]?>(value: peripheral.services, error: error, id: operationId)
        
		discoveredServicesSubject.send(result)
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

	public func peripheral(
		_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
		error: Error?
    ) {
        let operationId = discoveredCharacteristicsQueue.dequeue()!
        let result = BluetoothOperationResult<(CBService, [CBCharacteristic]?)>(value: (service, service.characteristics), error: error, id: operationId)
        
		discoveredCharacteristicsSubject.send(result)
	}

	public func peripheral(
		_ peripheral: CBPeripheral,
		didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?
	) {
        let operationId = discoveredDescriptorsQueue.dequeue()!
        let result = BluetoothOperationResult<(CBCharacteristic, [CBDescriptor]?)>(value: (characteristic, characteristic.descriptors), error: error, id: operationId)
        
		discoveredDescriptorsSubject.send(result)
	}

	// MARK: Retrieving Characteristic and Descriptor Values

	public func peripheral(
		_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
		error: Error?
	) {
		updatedCharacteristicValuesSubject.send((characteristic, error))
	}

	public func peripheral(
		_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor,
		error: Error?
	) {
		updatedDescriptorValuesSubject.send((descriptor, error))
	}

	// MARK: Writing Characteristic and Descriptor Values

	public func peripheral(
		_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic,
		error: Error?
	) {
		writtenCharacteristicValuesSubject.send((characteristic, error))
	}

	public func peripheral(
		_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?
	) {
		writtenDescriptorValuesSubject.send((descriptor, error))
	}

	public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
		l.i(#function)
		fatalError()
	}

	// MARK: Managing Notifications for a Characteristic’s Value

	public func peripheral(
		_ peripheral: CBPeripheral,
		didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?
	) {
		notificationStateSubject.send((characteristic, error))
	}

	// MARK: Retrieving a Peripheral’s RSSI Data

    public let readRSSISubject = PassthroughSubject<(NSNumber, Error?), Never>()
    
	public func peripheral(
		_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?
	) {
        readRSSISubject.send((RSSI, error))
	}

	// MARK: Monitoring Changes to a Peripheral’s Name or Services

	public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
		updateNameSubject.send(peripheral.name)
	}

	public func peripheral(
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
