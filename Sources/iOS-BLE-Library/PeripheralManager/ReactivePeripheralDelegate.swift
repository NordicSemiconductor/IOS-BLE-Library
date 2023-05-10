//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/04/2023.
//

import CoreBluetoothMock
import Foundation
import Combine

public class ReactivePeripheralDelegate: NSObject {
    // MARK: Subjects
    public let discoveredServicesSubject = PassthroughSubject<([CBService]?, Error?), Never>()
    public let discoveredIncludedServicesSubject = PassthroughSubject<(CBService, [CBService]?, Error?), Never>()
    public let discoveredCharacteristicsSubject = PassthroughSubject<(CBService, [CBCharacteristic]?, Error?), Never>()
    public let discoveredDescriptorsSubject = PassthroughSubject<(CBCharacteristic, [CBDescriptor]?, Error?), Never>()
    
    // MARK: Retrieving Characteristic and Descriptor Values
    public let updatedCharacteristicValuesSubject = PassthroughSubject<(CBCharacteristic, Error?), Never>()
    public let updatedDescriptorValuesSubject = PassthroughSubject<(CBDescriptor, Error?), Never>()
    
    public let writtenCharacteristicValuesSubject = PassthroughSubject<(CBCharacteristic, Error?), Never>()
    public let writtenDescriptorValuesSubject = PassthroughSubject<(CBDescriptor, Error?), Never>()
}

extension ReactivePeripheralDelegate: CBPeripheralDelegate {
    // MARK: Discovering Services
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(#function)
        discoveredServicesSubject.send((peripheral.services, error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        discoveredIncludedServicesSubject.send((service, service.includedServices, error))
    }
    
    // MARK: Discovering Characteristics and their Descriptors
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        discoveredCharacteristicsSubject.send((service, service.characteristics, error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        discoveredDescriptorsSubject.send((characteristic, characteristic.descriptors, error))
    }
    
    // MARK: Retrieving Characteristic and Descriptor Values
    
    public func peripheral(_ peripheral: CBMPeripheral, didUpdateValueFor characteristic: CBMCharacteristic, error: Error?) {
        if let v = characteristic.value {
            print("updated value: \(String(data: v, encoding: .utf8)), \(Date())")
        }
        updatedCharacteristicValuesSubject.send((characteristic, error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        updatedDescriptorValuesSubject.send((descriptor, error))
    }
    
    // MARK: Writing Characteristic and Descriptor Values
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        writtenCharacteristicValuesSubject.send((characteristic, error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        writtenDescriptorValuesSubject.send((descriptor, error))
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
    }
    
    // MARK: Managing Notifications for a Characteristic’s Value
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    // MARK: Retrieving a Peripheral’s RSSI Data
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        
    }
    
    // MARK: Monitoring Changes to a Peripheral’s Name or Services
    
    
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
    
    // MARK: Monitoring L2CAP Channels
    
    public func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?) {
        
    }
    
}
