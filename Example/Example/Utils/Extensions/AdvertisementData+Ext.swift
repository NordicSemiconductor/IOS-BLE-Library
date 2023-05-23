//
//  AdvertisementData+Ext.swift
//  Example
//
//  Created by Nick Kibysh on 30/03/2023.
//

import Foundation
import iOS_BLE_Library
import iOS_Common_Libraries

extension AdvertisementData {
    typealias Record = ItemModel<String>
    
    var readableFormat: [Record] {
        var records = [Record]()
        
        localName.map { records.append(Record(key: CBAdvertisementDataLocalNameKey, title: "Local Name", value: $0.humanReadableString)) }
        manufacturerData.map { records.append(Record(key: CBAdvertisementDataManufacturerDataKey, title: "Manufacturer Data", value: $0.humanReadableString)) }
        serviceData.map { records.append(Record(key: CBAdvertisementDataServiceDataKey, title: "Service Data", value: $0.humanReadableString)) }
        overflowServiceUUIDs.map { records.append(Record(key: CBAdvertisementDataOverflowServiceUUIDsKey, title: "Overflow Service UUIDs", value: $0.humanReadableString)) }
        txPowerLevel.map { records.append(Record(key: CBAdvertisementDataTxPowerLevelKey, title: "TX Power Level", value: $0.humanReadableString)) }
        isConnectable.map { records.append(Record(key: CBAdvertisementDataIsConnectable, title: "Is Connectable", value: $0.humanReadableString)) }
        solicitedServiceUUIDs.map { records.append(Record(key: CBAdvertisementDataSolicitedServiceUUIDsKey, title: "Solicited Service UUIDs", value: $0.humanReadableString)) }
        
        return records
    }
}
