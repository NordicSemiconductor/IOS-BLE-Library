//
//  File.swift
//
//
//  Created by Nick Kibysh on 18/04/2023.
//

import Foundation
import Combine
import CoreBluetooth

open class ReactiveCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    enum BluetoothError: Error {
        case failedToConnect
    }
    
    let stateSubject = CurrentValueSubject<CBManagerState, Never>(.unknown)
    let scanResultSubject = PassthroughSubject<ScanResult, Never>()
    let connetedPeripheralSubject = PassthroughSubject<(CBPeripheral, Error?), Never>()
    let disconnectedPeripheralsSubject = PassthroughSubject<(CBPeripheral, Error?), Never>()
    
    public var statePublisher: AnyPublisher<CBManagerState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    public var state: CBManagerState {
        stateSubject.value
    }
    
    // MARK: CBCentralManagerDelegate
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }
    
    /*
     func centralManager(CBCentralManager, willRestoreState: [String : Any])
     */
    
    /*
     func centralManager(CBCentralManager, didUpdateANCSAuthorizationFor: CBPeripheral)
     */
    
    open func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let scanResult = ScanResult(
            peripheral: peripheral,
            rssi: RSSI,
            advertisementData: advertisementData
        )
        
        scanResultSubject.send(scanResult)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connetedPeripheralSubject.send((peripheral, nil))
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let e = error ?? BluetoothError.failedToConnect
        connetedPeripheralSubject.send((peripheral, e))
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        disconnectedPeripheralsSubject.send((peripheral, error))
    }
    /*
    @available(iOS 13, *)
    public func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
    }
    */
}
