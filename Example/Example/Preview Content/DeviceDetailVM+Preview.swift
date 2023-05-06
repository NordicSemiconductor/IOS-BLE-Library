//
//  DeviceDetailVM+Preview.swift
//  Example
//
//  Created by Nick Kibysh on 05/04/2023.
//

import Foundation
import iOS_BLE_Library
import iOS_Bluetooth_Numbers_Database

extension DeviceDetailsScreen {
    private typealias S = iOS_Bluetooth_Numbers_Database.Service
    private typealias C = iOS_Bluetooth_Numbers_Database.Characteristic
    
    class PreviewViewModel: ViewModel {
        init(name: String = "New Device", connectable: Bool = true, rssi: RSSI = .good, advData: AdvertisementData = .mock) {
            super.init()
            
            let s1 = S.Nordicsemi.LEDAndButton.nordicLEDAndButtonService
            let s2 = S.Nordicsemi.EdgeImpulse.edgeImpulseRemoteManagementService
            let s3 = S.Nordicsemi.ThingySound.thingySoundService
            
            let c11 = C.Nordicsemi.Blinky.LEDState.blinkyLEDState
            
            let c21 = C.Nordicsemi.EdgeImpulse.UARTRx.edgeImpulseRemoteManagementRxCharacteristic
            let c22 = C.Nordicsemi.EdgeImpulse.UARTTx.edgeImpulseRemoteManagementTxCharacteristic
            
            let c31 = C.Nordicsemi.Thingy.SoundConfig.thingySoundConfig
            let c32 = C.Nordicsemi.Thingy.SpeakerStatus.thingySpeakerStatus
            let c33 = C.Nordicsemi.Thingy.SpeakerData.thingySpeakerData
            
            self.name = name
            self.isConnectable = connectable
            self.rssi = rssi
            self.advertisementData = advData
            self.discoveredServices = [
                Service(name: s1.name, id: s1.identifier, characteristics: [
                    Characteristic(name: c11.name, id: c11.identifier)
                ]),
                Service(name: s2.name, id: s2.identifier, characteristics: [
                    Characteristic(name: c21.name, id: c21.identifier),
                    Characteristic(name: c22.name, id: c22.identifier),
                ]),
                Service(name: s3.name, id: s3.identifier, characteristics: [
                    Characteristic(name: c31.name, id: c31.identifier),
                    Characteristic(name: c32.name, id: c32.identifier),
                    Characteristic(name: c33.name, id: c33.identifier),
                ])
            ]
        }
        
        override func discoverDevice() { }
    }
}
