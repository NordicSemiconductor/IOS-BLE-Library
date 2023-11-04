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
    var serviceDiscoveryQueue = Queue<UUID>()
    
    // MARK: Discovering Services
	let discoveredServicesSubject = PassthroughSubject<
        BluetoothOperationResult<[CBService]?>, Never
    >()
	let discoveredIncludedServicesSubject = PassthroughSubject<
		(CBService, [CBService]?, Error?), Never
	>()
    
    // MARK: Discovering Characteristics and their Descriptors
	let discoveredCharacteristicsSubject = PassthroughSubject<
		(CBService, [CBCharacteristic]?, Error?), Never
	>()
	let discoveredDescriptorsSubject = PassthroughSubject<
		(CBCharacteristic, [CBDescriptor]?, Error?), Never
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
		l.i(#function)
        
        if let services = peripheral.services {
            services.forEach { l.d($0.description) }
        }
        
        let operationId = serviceDiscoveryQueue.dequeue()!
        let result = BluetoothOperationResult<[CBService]?>(value: peripheral.services, error: error, id: operationId)
        
		discoveredServicesSubject.send(result)
	}

	public func peripheral(
		_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService,
		error: Error?
	) {
		l.i(#function)
		discoveredIncludedServicesSubject.send((service, service.includedServices, error))
	}

	// MARK: Discovering Characteristics and their Descriptors

	public func peripheral(
		_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
		error: Error?
	) {
		l.i(#function)
		discoveredCharacteristicsSubject.send((service, service.characteristics, error))
	}

	public func peripheral(
		_ peripheral: CBPeripheral,
		didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?
	) {
		l.i(#function)
		discoveredDescriptorsSubject.send(
			(characteristic, characteristic.descriptors, error))
	}

	// MARK: Retrieving Characteristic and Descriptor Values

	public func peripheral(
		_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
		error: Error?
	) {
		l.i(#function)
		updatedCharacteristicValuesSubject.send((characteristic, error))
	}

	public func peripheral(
		_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor,
		error: Error?
	) {
		l.i(#function)
		updatedDescriptorValuesSubject.send((descriptor, error))
	}

	// MARK: Writing Characteristic and Descriptor Values

	public func peripheral(
		_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic,
		error: Error?
	) {
		l.i(#function)
		writtenCharacteristicValuesSubject.send((characteristic, error))
	}

	public func peripheral(
		_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?
	) {
		l.i(#function)
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
		l.i(#function)
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
		l.i(#function)
		updateNameSubject.send(peripheral.name)
	}

	public func peripheral(
		_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]
	) {
		l.i(#function)
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
