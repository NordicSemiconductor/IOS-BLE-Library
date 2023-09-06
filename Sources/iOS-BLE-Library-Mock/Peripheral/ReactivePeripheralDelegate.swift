//
//  File.swift
//
//
//  Created by Nick Kibysh on 28/04/2023.
//

import Combine
import CoreBluetoothMock
import Foundation

public class ReactivePeripheralDelegate: NSObject {
	let l = L(category: #file)

	// MARK: Subjects
	public let discoveredServicesSubject = PassthroughSubject<([CBService]?, Error?), Never>()
	public let discoveredIncludedServicesSubject = PassthroughSubject<
		(CBService, [CBService]?, Error?), Never
	>()
	public let discoveredCharacteristicsSubject = PassthroughSubject<
		(CBService, [CBCharacteristic]?, Error?), Never
	>()
	public let discoveredDescriptorsSubject = PassthroughSubject<
		(CBCharacteristic, [CBDescriptor]?, Error?), Never
	>()

	// MARK: Retrieving Characteristic and Descriptor Values
	public let updatedCharacteristicValuesSubject = PassthroughSubject<
		(CBCharacteristic, Error?), Never
	>()
	public let updatedDescriptorValuesSubject = PassthroughSubject<
		(CBDescriptor, Error?), Never
	>()

	public let writtenCharacteristicValuesSubject = PassthroughSubject<
		(CBCharacteristic, Error?), Never
	>()
	public let writtenDescriptorValuesSubject = PassthroughSubject<
		(CBDescriptor, Error?), Never
	>()

	// MARK: Managing Notifications for a Characteristic’s Value
	public let notificationStateSubject = PassthroughSubject<
		(CBCharacteristic, Error?), Never
	>()

	// MARK: Monitoring Changes to a Peripheral’s Name or Services
	public let updateNameSubject = PassthroughSubject<String?, Never>()
}

extension ReactivePeripheralDelegate: CBPeripheralDelegate {
	// MARK: Discovering Services

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		l.i(#function)
		discoveredServicesSubject.send((peripheral.services, error))
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

	public func peripheral(
		_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?
	) {
		l.i(#function)
		fatalError()
	}

	public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
		l.i(#function)
		fatalError()
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
		fatalError()
	}

	// MARK: Monitoring L2CAP Channels

	public func peripheral(
		_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?
	) {
		l.i(#function)
		fatalError()
	}

}
