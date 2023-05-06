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
    private typealias D = iOS_Bluetooth_Numbers_Database.Descriptor
    
    class PreviewViewModel: ViewModel {
        init(name: String = "New Device", connectable: Bool = true, rssi: RSSI = .good, advData: AdvertisementData = .mock) {
            super.init()
            
            let s1 = S.Nordicsemi.LEDAndButton.nordicLEDAndButtonService
            let c11 = C.Nordicsemi.Blinky.LEDState.blinkyLEDState
            let d111 = D.Gatt.CharacteristicAggregateFormat.characteristicAggregateFormat
            
            let s2 = S.Nordicsemi.EdgeImpulse.edgeImpulseRemoteManagementService
            let c21 = C.Nordicsemi.EdgeImpulse.UARTRx.edgeImpulseRemoteManagementRxCharacteristic
            let d211 = D.EnvironmentalSensingMeasurement.environmentalSensingMeasurement
            let c22 = C.Nordicsemi.EdgeImpulse.UARTTx.edgeImpulseRemoteManagementTxCharacteristic
            let d221 = D.CompleteBredrTransportBlockData.completeBrEdrTransportBlockData
            
            let s3 = S.Nordicsemi.ThingySound.thingySoundService
            let c31 = C.Nordicsemi.Thingy.SoundConfig.thingySoundConfig
            let d311 = D.NumberOfDigitals.numberOfDigitals
            
            let c32 = C.Nordicsemi.Thingy.SpeakerStatus.thingySpeakerStatus
            let c33 = C.Nordicsemi.Thingy.SpeakerData.thingySpeakerData
            
            
            
            
            self.name = name
            self.isConnectable = connectable
            self.rssi = rssi
            self.advertisementData = advData
            self.discoveredServices = [
                Attributes(id: s1.identifier, level: 1, name: s1.name, inner: [
                    Attributes(id: c11.identifier, level: 2, name: c11.name, inner: [
                        Attributes(id: d111.identifier, level: 3, name: d111.name, inner: [])
                    ]),
                ]),
                Attributes(id: s2.identifier, level: 1, name: s2.name, inner: [
                    Attributes(id: c21.identifier, level: 2, name: c21.name, inner: [
                        Attributes(id: d211.identifier, level: 3, name: d211.name, inner: []),
                    ]),
                    Attributes(id: c22.identifier, level: 2, name: c22.name, inner: [
                        Attributes(id: d221.identifier, level: 3, name: d221.name, inner: []),
                    ]),
                ]),
                Attributes(id: s3.identifier, level: 1, name: s3.name, inner: [
                    Attributes(id: c31.identifier, level: 2, name: c31.name, inner: [
                        Attributes(id: d311.identifier, level: 3, name: d311.name, inner: []),
                    ]),
                    Attributes(id: c32.identifier, level: 2, name: c32.name, inner: [
                        
                    ]),
                    Attributes(id: c33.identifier, level: 2, name: c33.name, inner: [
                        
                    ]),
                ]),
            ]
        }
        
        override func discoverDevice() { }
    }
}
