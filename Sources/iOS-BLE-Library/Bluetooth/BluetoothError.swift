//
//  BluetoothError.swift
//  iOS-BLE-Library
//
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation

// MARK: - BluetoothError

public enum BluetoothError: LocalizedError, Equatable {
    
    // MARK: Error(s)
    
    case bluetoothPoweredOff
    case failedToConnect(description: String), failedToDiscoverCharacteristics, failedToDiscoverServices
    case cantRetrievePeripheral, cantRetrieveService(_ uuid: String), cantRetrieveCharacteristic(_ uuid: String)
    case expectedServiceNotFound, noCharacteristicsForService, noServicesForPeripheral
    
    /**
     This is returned when we detect `CBError` with code 15, which means 'Insufficient Encryption'. Usually this means Pairing is required to proceed reading Characteristics / Toggling Notifications and so on, hence why this specific case is returned.
     */
    case pairingRequired
    case operationInProgress
    case unexpectedDeviceDisconnection(description: String), coreBluetoothError(description: String)
    
    // MARK: Init
    
    init(_ error: Error) {
        switch (error as NSError).code {
        case 15:
            self = .pairingRequired
        default:
            self = .coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    // MARK: Descriptpion
    
    public var errorDescription: String? { localizedDescription }
    public var failureReason: String? { localizedDescription }
    
    public var localizedDescription: String {
        switch self {
        case .bluetoothPoweredOff:
            return "Bluetooth is Powered Off."
        case .failedToConnect(let description):
            return "Failed to connect to CBPeripheral: \(description)."
        case .cantRetrievePeripheral:
            return "Can't retrieve CBPeripheral."
        case .cantRetrieveService(let name):
            return "Can't retrieve CBService \(name)."
        case .cantRetrieveCharacteristic(let name):
            return "Can't retrieve CBCharacteristic \(name)."
        case .failedToDiscoverCharacteristics:
            return "Failed to Discover CBPeripheral's Characteristic(s)."
        case .failedToDiscoverServices:
            return "Failed to Discover CBPeripheral's Service(s)."
        case .expectedServiceNotFound:
            return "This device does not advertise the expected Service."
        case .noServicesForPeripheral:
            return "CBPeripheral does not declare any Service(s)."
        case .noCharacteristicsForService:
            return "CBPeripheral does not declare any Characteristic(s)."
        case .pairingRequired:
            return "Insufficient Encryption. Do you need to pair with this Device first?"
        case .operationInProgress:
            return "An operation with this CBPeripheral is already in progress."
        case .unexpectedDeviceDisconnection(description: let description):
            return "Device Disconnected Unexpectedly. Reason: \(description)."
        case .coreBluetoothError(description: let description):
            return description
        }
    }
}
