//
//  Bluetooth.swift
//  iOS-BLE-Library
//
//  Created by Nick Kibysh on 15/04/2021.
//  Created by Dinesh Harjani on 23/8/22.
//

import Foundation
import Combine
import os
import CoreBluetooth
import iOS_Common_Libraries

// MARK: - Bluetooth

public final class Bluetooth: NSObject {
    
    enum AwaitContinuation {
        case connection(_ continuation: CheckedContinuation<CBPeripheral, Error>)
        case updatedService(_ continuation: CheckedContinuation<CBService, Error>)
        case attribute(_ continuation: CheckedContinuation<Data?, Error>)
        case notificationChange(_ continuation: CheckedContinuation<Bool, Error>)
    }
    
    // MARK: - ScannerFilter
    
    public enum ScannerFilter: Hashable, Equatable {
        case none
        case matchingServiceUUID(_ uuid: CBUUID)
        case connectable
        
        internal func filterServices() -> [CBUUID] {
            switch self {
            case .matchingServiceUUID(let uuid):
                return [uuid]
            case .none, .connectable:
                return []
            }
        }
    }
    
    // MARK: - Public Properties
    
    @Published public private(set) var isScanning = false
    
    public typealias ScanData = (peripheral: CBPeripheral, advertisementData: [String: Any], RSSI: NSNumber)
    public private(set) lazy var devicePublisher = PassthroughSubject<ScanData, Never>()
    
    // MARK: - Internal Properties
    
    internal lazy var logger = Logger(subsystem: "com.nordicsemi.nRF-BLe-Library",
                                      category: String(describing: Self.self))
    private lazy var bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    
    @Published internal var managerState: CBManagerState = .unknown
    @Published internal var filters: [ScannerFilter] = [.none]
    @Published internal var shouldScan = false
    
    internal var continuations = [String: AwaitContinuation]()
    internal var connectedStreams = [String: [AsyncThrowingStream<AsyncStreamValue, Error>.Continuation]]()
    
    private var connectedPeripherals = [String: CBPeripheral]()
}

// MARK: - API

extension Bluetooth {
    
    // MARK: Scan
    
    /**
     Needs to be called before any attempt to Scan is made.
     
     The first call to `CBCentralManager.state` is the one that turns on the BLE Radio if it's available, and successive calls check whether it turned on or not, but they cannot be made one after the other or the second will return an error. This is why we make this first call ahead of time.
     */
    public func turnOnBluetoothRadio() -> AnyPublisher<CBManagerState, Never> {
        shouldScan = true
        _ = bluetoothManager.state
        return $managerState.eraseToAnyPublisher()
    }
    
    public func toggleScanner() {
        shouldScan.toggle()
    }
    
    public func scan(with filters: [ScannerFilter] = [.none]) -> AnyPublisher<ScanData, Never> {
        self.filters = filters
        
        return turnOnBluetoothRadio()
            .filter { $0 == .poweredOn }
            .combineLatest($shouldScan, $filters)
            .flatMap { (_, isScanning, scanConditions) -> PassthroughSubject<ScanData, Never> in
                if isScanning {
                    let scanServices = scanConditions.flatMap { $0.filterServices() }
                    self.bluetoothManager.scanForPeripherals(withServices: scanServices,
                                                             options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                    self.isScanning = true
                } else {
                    self.bluetoothManager.stopScan()
                    self.isScanning = false
                }
                
                return self.devicePublisher
            }
            .eraseToAnyPublisher()
    }
    
    public func scan(forDeviceWithUUID uuid: CBUUID) async throws -> CBPeripheral? {
        defer {
            bluetoothManager.stopScan()
        }
        
        for try await newDevice in scan().timeout(.seconds(5), scheduler: DispatchQueue.main).values {
            guard newDevice.peripheral.uuidString == uuid.uuidString else { continue }
            return newDevice.peripheral
        }
        return nil
    }
    
    // MARK: Connect
    
    public func connect<T: BluetoothDevice>(to device: T) async throws {
        try await connect(toDeviceWithUUID: device.uuidString)
    }
    
    public func connect(toDeviceWithUUID deviceUUID: String) async throws {
        guard let uuid = UUID(uuidString: deviceUUID) else {
            throw BluetoothError.cantRetrievePeripheral
        }
        
        var peripheral = bluetoothManager.retrievePeripherals(withIdentifiers: [uuid]).first
        if peripheral == nil {
            peripheral = try await scan(forDeviceWithUUID: CBUUID(string: deviceUUID))
        }
        
        guard let peripheral = peripheral else {
            throw BluetoothError.cantRetrievePeripheral
        }
        
        peripheral.delegate = self
        guard continuations[deviceUUID] == nil else { throw BluetoothError.operationInProgress }
        do {
            let connectedPeripheral = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CBPeripheral, Error>) -> Void in
                continuations[deviceUUID] = .connection(continuation)
                bluetoothManager.connect(peripheral)
            }
            connectedPeripherals[deviceUUID] = connectedPeripheral
            continuations.removeValue(forKey: deviceUUID)
        }
        catch {
            continuations.removeValue(forKey: deviceUUID)
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    // MARK: Discover Services
    
    public func discoverServices<T: BluetoothDevice>(_ serviceUUIDs: [String] = [], of device: T) async throws -> [CBService] {
        try await discoverServices(serviceUUIDs, ofDeviceWithUUID: device.uuidString)
    }
    
    public func discoverServices(_ serviceUUIDs: [String] = [], ofDeviceWithUUID deviceUUID: String) async throws -> [CBService] {
        guard let peripheral = connectedPeripherals[deviceUUID] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        guard continuations[deviceUUID] == nil else { throw BluetoothError.operationInProgress }
        
        do {
            let peripheralWithServices = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CBPeripheral, Error>) -> Void in
                continuations[deviceUUID] = .connection(continuation)
                let cbUUIDServices = serviceUUIDs.map { CBUUID(string: $0) }
                peripheral.discoverServices(cbUUIDServices)
            }
            connectedPeripherals[deviceUUID] = peripheralWithServices
            continuations.removeValue(forKey: deviceUUID)
            return peripheralWithServices.services ?? []
        }
        catch {
            continuations.removeValue(forKey: deviceUUID)
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    @discardableResult
    public func discoverCharacteristics(_ characteristicUUIDs: [String] = [], ofService serviceUUID: String, ofDeviceWithUUID deviceUUID: String) async throws -> [CBCharacteristic]? {
        guard let peripheral = connectedPeripherals[deviceUUID] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        
        guard let cbService = peripheral.services?.first(where: { $0.uuid.uuidString == serviceUUID }) else {
            throw BluetoothError.cantRetrieveService(serviceUUID)
        }
        
        guard continuations[deviceUUID] == nil else { throw BluetoothError.operationInProgress }
        defer {
            continuations.removeValue(forKey: deviceUUID)
        }
        
        do {
            let updatedService = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CBService, Error>) -> Void in
                continuations[deviceUUID] = .updatedService(continuation)
                let cbUUIDCharacteristics = characteristicUUIDs.map { CBUUID(string: $0) }
                peripheral.discoverCharacteristics(cbUUIDCharacteristics, for: cbService)
            }
            return updatedService.characteristics
        }
        catch {
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    // MARK: Read
    
    public func data<T: BluetoothDevice>(fromCharacteristic characteristic: CBCharacteristic,
                                         inService service: CBService,
                                         device: T) -> AsyncCharacteristicData {
        return data(fromCharacteristicWithUUIDString: characteristic.uuid.uuidString,
                    inServiceWithUUIDString: service.uuid.uuidString,
                    device: device)
    }
    
    public func data<T: BluetoothDevice>(fromCharacteristicWithUUID characteristicUUID: CBUUID,
                                         inServiceWithUUID serviceUUID: CBUUID,
                                         device: T) -> AsyncCharacteristicData {
        return data(fromCharacteristicWithUUIDString: characteristicUUID.uuidString,
                    inServiceWithUUIDString: serviceUUID.uuidString,
                    device: device)
    }
    
    public func data<T: BluetoothDevice>(fromCharacteristicWithUUIDString characteristicUUIDString: String,
                                         inServiceWithUUIDString serviceUUIDString: String,
                                         device: T) -> AsyncCharacteristicData {
        let stream = AsyncThrowingStream<AsyncStreamValue, Error> { continuation in
            connectedStreams[device.uuidString]?.append(continuation)
        }
        return AsyncCharacteristicData(serviceUUID: serviceUUIDString,
                                       characteristicUUID: characteristicUUIDString,
                                       stream: stream)
    }
    
    public func readCharacteristic<T: BluetoothDevice>(withUUID characteristicUUID: CBUUID,
                                                       inServiceWithUUID serviceUUID: CBUUID,
                                                       from device: T) async throws -> Data? {
        return try await readCharacteristic(withUUIDString: characteristicUUID.uuidString, inServiceWithUUIDString: serviceUUID.uuidString, from: device)
    }
    
    public func readCharacteristic<T: BluetoothDevice>(withUUIDString characteristicUUIDString: String,
                                                       inServiceWithUUIDString serviceUUIDString: String,
                                                       from device: T) async throws -> Data? {
        guard let peripheral = connectedPeripherals[device.uuidString] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self

        guard let cbService = peripheral.services?.first(where: { $0.uuid.uuidString == serviceUUIDString }),
              let cbCharacteristic = cbService.characteristics?.first(where: { $0.uuid.uuidString == characteristicUUIDString }) else {
            throw BluetoothError.cantRetrieveCharacteristic(characteristicUUIDString)
        }
        
        do {
            var readData: Data? = nil
            let readStream = data(fromCharacteristic: cbCharacteristic, inService: cbService, device: device)
            peripheral.readValue(for: cbCharacteristic)
            for try await newValue in readStream {
                readData = newValue
                break // we're only interested in the first 'read' Value.
            }
            return readData
        }
        catch {
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    // MARK: Write
    
    public func writeCharacteristic<T: BluetoothDevice>(_ data: Data,
                                                        writeType: CBCharacteristicWriteType = .withoutResponse,
                                                        toCharacteristicWithUUID characteristicUUID: CBUUID,
                                                        inServiceWithUUID serviceUUID: CBUUID,
                                                        from device: T) async throws -> Data? {
        return try await writeCharacteristic(data, writeType: writeType, toCharacteristicWithUUIDString: characteristicUUID.uuidString, inServiceWithUUIDString: serviceUUID.uuidString, from: device)
    }
    
    public func writeCharacteristic<T: BluetoothDevice>(_ data: Data,
                                                        writeType: CBCharacteristicWriteType = .withoutResponse,
                                                        toCharacteristicWithUUIDString characteristicUUIDString: String,
                                                        inServiceWithUUIDString serviceUUIDString: String,
                                                        from device: T) async throws -> Data? {
        guard let peripheral = connectedPeripherals[device.uuidString] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        
        guard let cbService = peripheral.services?.first(where: { $0.uuid.uuidString == serviceUUIDString }),
              let cbCharacteristic = cbService.characteristics?.first(where: { $0.uuid.uuidString == characteristicUUIDString }) else {
            throw BluetoothError.cantRetrieveCharacteristic(characteristicUUIDString)
        }
        
        guard continuations[device.uuidString] == nil else { throw BluetoothError.operationInProgress }
        defer {
            continuations.removeValue(forKey: device.uuidString)
        }
        
        do {
            let writeData = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) -> Void in
                continuations[device.uuidString] = .attribute(continuation)
                peripheral.writeValue(data, for: cbCharacteristic, type: writeType)
            }
            return writeData
        }
        catch {
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    // MARK: Notify
    
    public func setNotify<T: BluetoothDevice>(_ notify: Bool,
                                     toCharacteristicWithUUID characteristicUUID: CBUUID,
                                     inServiceWithUUID serviceUUID: CBUUID,
                                     from device: T) async throws -> Bool {
        return try await setNotify(notify, toCharacteristicWithUUIDString: characteristicUUID.uuidString, inServiceWithUUIDString: serviceUUID.uuidString, from: device)
    }
    
    public func setNotify<T: BluetoothDevice>(_ notify: Bool,
                                     toCharacteristicWithUUIDString characteristicUUIDString: String,
                                     inServiceWithUUIDString serviceUUIDString: String,
                                     from device: T) async throws -> Bool {
        guard let peripheral = connectedPeripherals[device.uuidString] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        
        guard let cbService = peripheral.services?.first(where: { $0.uuid.uuidString == serviceUUIDString }),
              let cbCharacteristic = cbService.characteristics?.first(where: { $0.uuid.uuidString == characteristicUUIDString }) else {
            throw BluetoothError.cantRetrieveCharacteristic(characteristicUUIDString)
        }
        
        guard continuations[device.uuidString] == nil else { throw BluetoothError.operationInProgress }
        defer {
            continuations.removeValue(forKey: device.uuidString)
        }
        
        do {
            let isNotifying = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) -> Void in
                continuations[device.uuidString] = .notificationChange(continuation)
                peripheral.setNotifyValue(notify, for: cbCharacteristic)
            }
            return isNotifying
        }
        catch {
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
    
    // MARK: Disconnect
    
    public func disconnect<T: BluetoothDevice>(from device: T) async throws {
        try await disconnect(fromWithUUID: device.uuidString)
    }
    
    public func disconnect(fromWithUUID deviceUUID: String) async throws {
        guard let peripheral = connectedPeripherals[deviceUUID] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        
        peripheral.delegate = self
        guard continuations[deviceUUID] == nil else { throw BluetoothError.operationInProgress }
        do {
            let disconnectedPeripheral = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CBPeripheral, Error>) -> Void in
                continuations[deviceUUID] = .connection(continuation)
                bluetoothManager.cancelPeripheralConnection(peripheral)
            }
            connectedPeripherals.removeValue(forKey: disconnectedPeripheral.identifier.uuidString)
            continuations.removeValue(forKey: deviceUUID)
        }
        catch {
            continuations.removeValue(forKey: deviceUUID)
            throw BluetoothError.coreBluetoothError(description: error.localizedDescription)
        }
    }
}
