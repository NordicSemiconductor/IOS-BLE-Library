//
//  AdvertisementData.swift
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

public struct AdvertisementData: Hashable {
	public static func == (lhs: AdvertisementData, rhs: AdvertisementData) -> Bool {
		return lhs.localName == rhs.localName
			&& lhs.manufacturerData == rhs.manufacturerData
			&& lhs.serviceData == rhs.serviceData
			&& lhs.serviceUUIDs == rhs.serviceUUIDs
			&& lhs.overflowServiceUUIDs == rhs.overflowServiceUUIDs
			&& lhs.txPowerLevel == rhs.txPowerLevel
			&& lhs.isConnectable == rhs.isConnectable
			&& lhs.solicitedServiceUUIDs == rhs.solicitedServiceUUIDs
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(localName)
		hasher.combine(manufacturerData)
		hasher.combine(serviceData)
		hasher.combine(serviceUUIDs)
		hasher.combine(overflowServiceUUIDs)
		hasher.combine(txPowerLevel)
		hasher.combine(isConnectable)
		hasher.combine(solicitedServiceUUIDs)
	}

	public let rawData: [String: Any]

	// MARK: - Properties

	public var localName: String? {  // CBAdvertisementDataLocalNameKey
		rawData[CBAdvertisementDataLocalNameKey] as? String
	}

	public var manufacturerData: Data? {  // CBAdvertisementDataManufacturerDataKey
		rawData[CBAdvertisementDataManufacturerDataKey] as? Data
	}

	public var serviceData: [CBUUID: Data]? {  // CBAdvertisementDataServiceDataKey
		rawData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
	}

	public var serviceUUIDs: [CBUUID]? {  // CBAdvertisementDataServiceUUIDsKey
		rawData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
	}

	public var overflowServiceUUIDs: [CBUUID]? {  // CBAdvertisementDataOverflowServiceUUIDsKey
		rawData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
	}

	public var txPowerLevel: Int? {  // CBAdvertisementDataTxPowerLevelKey
		(rawData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.intValue
	}

	public var isConnectable: Bool? {  // CBAdvertisementDataIsConnectable
		(rawData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
	}

	public var solicitedServiceUUIDs: [CBUUID]? {  // CBAdvertisementDataSolicitedServiceUUIDsKey
		rawData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
	}

	// MARK: - Init

	public init() {
		self.init([:])
	}

	public init(_ advertisementData: [String: Any]) {
		self.rawData = advertisementData
	}

	// MARK: - Advertised ID (MAC Address)

	internal static let ExpectedManufacturerDataPrefix: UInt8 = 225

	public func advertisedID() -> String? {
		guard let data = manufacturerData, data.count > 4 else { return nil }
		var advData = data.suffix(from: 2)  // Skip 'Nordic' Manufacturer Code
		guard advData.removeFirst() == Self.ExpectedManufacturerDataPrefix else {
			return nil
		}
//        return advData.hexEncodedString(options: [.upperCase], separator: ":")
        return advData.hexEncodedString(separator: ":").uppercased()
	}
}

// MARK: - Debug

#if DEBUG
	extension AdvertisementData {

		public static var connectableMock: AdvertisementData {
			AdvertisementData([
				CBAdvertisementDataLocalNameKey: "iPhone 13",
				CBAdvertisementDataIsConnectable: true as NSNumber,
			])
		}

		public static var unconnectableMock: AdvertisementData {
			AdvertisementData([
				CBAdvertisementDataLocalNameKey: "iPhone 14",
				CBAdvertisementDataIsConnectable: false as NSNumber,
			])
		}
	}
#endif
