//
//  AsyncCharacteristicData.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

//CG_REPLACE
import CoreBluetooth
//CG_WITH
/*
import CoreBluetoothMock
*/
//CG_END
import Foundation

public typealias AsyncStreamValue = (characteristic: CBCharacteristic, data: Data?)

public struct AsyncCharacteristicData: AsyncSequence, AsyncIteratorProtocol {
	public typealias Element = Data?

	let serviceUUID: String
	let characteristicUUID: String
	let stream: AsyncThrowingStream<AsyncStreamValue, Error>

	public func makeAsyncIterator() -> AsyncCharacteristicData {
		self
	}

	mutating public func next() async throws -> Element? {
		for try await newValue in stream {
			guard newValue.characteristic.uuid.uuidString == characteristicUUID,
				let service = newValue.characteristic.service,
				service.uuid.uuidString == serviceUUID
			else { continue }
			return newValue.data
		}
		return nil
	}
}
