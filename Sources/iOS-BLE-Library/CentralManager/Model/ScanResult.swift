//
//  File.swift
//
//
//  Created by Nick Kibysh on 19/04/2023.
//

//CG_REPLACE
import CoreBluetooth
//CG_WITH
/*
import CoreBluetoothMock
*/
//CG_END
import Foundation

public struct ScanResult {
	public let peripheral: CBPeripheral
	public let rssi: RSSI
	public let advertisementData: AdvertisementData

	init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: [String: Any]) {
		self.peripheral = peripheral
		self.rssi = RSSI(integerLiteral: rssi.intValue)
		self.advertisementData = AdvertisementData(advertisementData)
	}

	public var name: String? {
		peripheral.name ?? advertisementData.localName
	}
}
