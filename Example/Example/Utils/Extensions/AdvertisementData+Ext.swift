//
//  AdvertisementData+Ext.swift
//  Example
//
//  Created by Nick Kibysh on 30/03/2023.
//

import Foundation
import iOS_BLE_Library

extension AdvertisementData {
    var readableFormat: [(title: String, value: String)] {
        var fields: [(title: String, value: String)] = []
        
        localName.map { fields.append(("Local Name", $0.humanReadableString)) }
        manufacturerData.map { fields.append(("Manufacturer Data", $0.humanReadableString)) }
        serviceData.map { fields.append(("Service Data", $0.humanReadableString)) }
        serviceUUIDs.map { fields.append(("Service UUIDs", $0.humanReadableString)) }
        overflowServiceUUIDs.map { fields.append(("Overflow Service UUIDs", $0.humanReadableString)) }
        txPowerLevel.map { fields.append(("TX Power Level", $0.humanReadableString)) }
        isConnectable.map { fields.append(("Is Connectable", $0.humanReadableString)) }
        solicitedServiceUUIDs.map { fields.append(("Solicited Service UUIDs", $0.humanReadableString)) }
        return fields
    }
}
