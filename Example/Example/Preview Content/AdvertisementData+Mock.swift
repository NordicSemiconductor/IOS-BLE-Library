//
//  AdvData+Mock.swift
//  Example
//
//  Created by Nick Kibysh on 05/04/2023.
//

import Foundation
import iOS_BLE_Library
import iOS_Bluetooth_Numbers_Database

extension AdvertisementData {
    static var fullMock: AdvertisementData {
        let service = Service.Nordicsemi.ThingyUi.thingyUiService.uuid
        
        let mockDict = [CBAdvertisementDataLocalNameKey: "MockName",
                        CBAdvertisementDataManufacturerDataKey: Data([0x01, 0x02, 0x03, 0x04]),
                        CBAdvertisementDataServiceDataKey: [service: Data([0x01, 0x02, 0x03, 0x04])],
                        CBAdvertisementDataServiceUUIDsKey: [service],
                        CBAdvertisementDataOverflowServiceUUIDsKey: [service],
                        CBAdvertisementDataTxPowerLevelKey: NSNumber(value: 1),
                        CBAdvertisementDataIsConnectable: NSNumber(value: true),
                        CBAdvertisementDataSolicitedServiceUUIDsKey: [service]] as [String : Any]
        return AdvertisementData(mockDict)
    }
}
