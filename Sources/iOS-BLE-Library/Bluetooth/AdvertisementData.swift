//
//  AdvertisementData.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation
import CoreBluetooth
//import iOS_Common_Libraries

public struct AdvertisementData: Hashable {
    
    // MARK: - Properties
    
    public let localName: String? // CBAdvertisementDataLocalNameKey
    public let manufacturerData: Data? // CBAdvertisementDataManufacturerDataKey
    public let serviceData: [CBUUID : Data]? // CBAdvertisementDataServiceDataKey
    public let serviceUUIDs: [CBUUID]? // CBAdvertisementDataServiceUUIDsKey
    public let overflowServiceUUIDs: [CBUUID]? // CBAdvertisementDataOverflowServiceUUIDsKey
    public let txPowerLevel: Int? // CBAdvertisementDataTxPowerLevelKey
    public let isConnectable: Bool? // CBAdvertisementDataIsConnectable
    public let solicitedServiceUUIDs: [CBUUID]? // CBAdvertisementDataSolicitedServiceUUIDsKey
    
    // MARK: - Init
    
    public init() {
        self.init([:])
    }
    
    public init(_ advertisementData: [String : Any]) {
        localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID : Data]
        serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        overflowServiceUUIDs = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
        txPowerLevel = (advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber)?.intValue
        isConnectable = (advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
        solicitedServiceUUIDs = advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
    }
    
    // MARK: - Advertised ID (MAC Address)
    
    internal static let ExpectedManufacturerDataPrefix: UInt8 = 225
    
    public func advertisedID() -> String? {
        guard let data = manufacturerData, data.count > 4 else { return nil }
        var advData = data.suffix(from: 2) // Skip 'Nordic' Manufacturer Code
        guard advData.removeFirst() == Self.ExpectedManufacturerDataPrefix else { return nil }
        return advData.hexEncodedString(separator: ":").uppercased()
    }
}

// MARK: - Debug

#if DEBUG
public extension AdvertisementData {
    
    static var connectableMock: AdvertisementData {
        AdvertisementData([
            CBAdvertisementDataLocalNameKey: "iPhone 13",
            CBAdvertisementDataIsConnectable: true as NSNumber
        ])
    }
    
    static var unconnectableMock: AdvertisementData {
        AdvertisementData([
            CBAdvertisementDataLocalNameKey: "iPhone 14",
            CBAdvertisementDataIsConnectable: false as NSNumber
        ])
    }
}
#endif
