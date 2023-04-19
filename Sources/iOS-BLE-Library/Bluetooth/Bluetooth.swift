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
import CoreBluetooth
import iOS_Common_Libraries
import AsyncAlgorithms

// MARK: - Bluetooth
/*
public final class Bluetooth: NSObject {
    
    // MARK: - MODERN ASYNC PART
    let stateChannel = AsyncChannel<CBManagerState>()
    
    public internal (set) var currentState: CBManagerState = .unknown
    public var state: AsyncBroadcastSequence<AsyncChannel<CBManagerState>> {
        stateChannel.broadcast()
    }
    
    public internal (set) var isScanning: Bool = false
    public var isScanningBroadcast: AsyncBroadcastSequence<AsyncChannel<Bool>> {
        isScanningChannel.broadcast()
    }
    
    let scanResultChannel = AsyncChannel<ScanData>()
    let isScanningChannel = AsyncChannel<Bool>()
    
    enum AwaitContinuation {
        case connection(_ continuation: CheckedContinuation<CBPeripheral, Error>)
        case serviceDiscovery(_ continuation: CheckedContinuation<CBPeripheral, Error>)
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
    
    public enum Mock {
        case none, simulatorOnly, forceMock
    }
    
    public init(forceMock: Bool = false ) {
        super.init()
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        CBMCentralManagerMock.simulatePeripherals([blinky])
        
        self.bluetoothManager = CBMCentralManagerFactory.instance(
            delegate: self,
            queue: nil,
            forceMock: forceMock
        )
    }
    
    // MARK: - Public Properties
    
//    @Published public private(set) var isScanning = false
    
//    public private(set) lazy var devicePublisher = PassthroughSubject<ScanData, Never>()
    
    // MARK: - Internal Properties
    
    internal lazy var logger = L(subsystem: "com.nordicsemi.nRF-BLe-Library",
                                      category: String(describing: Self.self))
    private var bluetoothManager: CBCentralManager!
    
//    @Published internal var managerState: CBManagerState = .unknown
    var filters: [ScannerFilter] = [.none]
    var shouldScan = false
    
    internal var continuations = [String: AwaitContinuation]()
    internal var dataStreams = [String: [AsyncThrowingStream<AsyncStreamValue, Error>.Continuation]]()
    
    private var connectedPeripherals = [String: CBPeripheral]()
    
    // TODO: - Combine -> AsyncSequence
    private var cancelables = Set<AnyCancellable>()
}

// MARK: - API

extension Bluetooth {
    
    // MARK: Scan
    
    /**
     Needs to be called before any attempt to Scan is made.
     
     The first call to `CBCentralManager.state` is the one that turns on the BLE Radio if it's available, and successive calls check whether it turned on or not, but they cannot be made one after the other or the second will return an error. This is why we make this first call ahead of time.
     */
    // TODO: - Combine -> AsyncSequence
    public func turnOnBluetoothRadio() -> AsyncBroadcastSequence<AsyncChannel<CBMManagerState>> {
        shouldScan = true
        Task {
            await stateChannel.send(bluetoothManager.state)
        }
        return stateChannel.broadcast()
    }
    
    // MARK: Stop Scanner
    public func stopScanner() async {
        guard isScanning else { return }
        
        // Toggle Scanner, which is not immediate.
//        toggleScanner()
        // Wait for first value change in 'isScanning' to return false, meaning Scanning has stopped.
//        _ = await $isScanning.values.first(where: { !$0 })
        assert(!isScanning)
    }
    
    // MARK: Start Scan
    // TODO: - Combine -> AsyncSequence
    public func scan(with services: [CBUUID]? = nil) async -> AsyncBroadcastSequence<AsyncChannel<ScanData>> {
        if currentState != .poweredOn {
            await _ = state.first(where: { $0 == .poweredOn })
        }
        
        bluetoothManager.scanForPeripherals(withServices: services)
        
        return scanResultChannel.broadcast()
    }
    
    public func scan(forDeviceWithUUID uuid: CBUUID) async throws -> CBPeripheral? {
        defer {
            bluetoothManager.stopScan()
        }
        
//        for try await newDevice in scan().timeout(.seconds(5), scheduler: DispatchQueue.main).values {
//            guard newDevice.peripheral.identifier.uuidString == uuid.uuidString else { continue }
//            return newDevice.peripheral
//        }
        return nil
    }
    
    // MARK: Connect
    public func connect(to device: CBPeripheral) async throws {
        try await connect(toDeviceWithUUID: device.identifier.uuidString)
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
        catch let error as BluetoothError {
            continuations.removeValue(forKey: deviceUUID)
            throw error
        }
    }
    
    // MARK: Discover Services
    
    public func discoverServices(_ serviceUUIDs: [String] = [], of device: CBPeripheral) async throws -> [CBService] {
        try await discoverServices(serviceUUIDs, ofDeviceWithUUID: device.identifier.uuidString)
    }
    
    public func discoverServices(_ serviceUUIDs: [String] = [], ofDeviceWithUUID deviceUUID: String) async throws -> [CBService] {
        guard let peripheral = connectedPeripherals[deviceUUID] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        guard continuations[deviceUUID] == nil else { throw BluetoothError.operationInProgress }
        
        do {
            let peripheralWithServices = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CBPeripheral, Error>) -> Void in
                continuations[deviceUUID] = .serviceDiscovery(continuation)
                let cbUUIDServices = serviceUUIDs.map { CBUUID(string: $0) }
                peripheral.discoverServices(cbUUIDServices)
            }
            connectedPeripherals[deviceUUID] = peripheralWithServices
            continuations.removeValue(forKey: deviceUUID)
            return peripheralWithServices.services ?? []
        }
        catch let error as BluetoothError {
            continuations.removeValue(forKey: deviceUUID)
            throw error
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
        catch let error as BluetoothError {
            throw error
        }
    }
    
    // MARK: Read
    
    public func data(fromCharacteristic characteristic: CBCharacteristic,
                                         inService service: CBService,
                                         device: CBPeripheral) -> AsyncCharacteristicData {
        return data(fromCharacteristicWithUUIDString: characteristic.uuid.uuidString,
                    inServiceWithUUIDString: service.uuid.uuidString,
                    device: device)
    }
    
    public func data(fromCharacteristicWithUUID characteristicUUID: CBUUID,
                                         inServiceWithUUID serviceUUID: CBUUID,
                                         device: CBPeripheral) -> AsyncCharacteristicData {
        return data(fromCharacteristicWithUUIDString: characteristicUUID.uuidString,
                    inServiceWithUUIDString: serviceUUID.uuidString,
                    device: device)
    }
    
    public func data(fromCharacteristicWithUUIDString characteristicUUIDString: String,
                                         inServiceWithUUIDString serviceUUIDString: String,
                                         device: CBPeripheral) -> AsyncCharacteristicData {
        let stream = AsyncThrowingStream<AsyncStreamValue, Error> { continuation in
            dataStreams[device.identifier.uuidString]?.append(continuation)
        }
        return AsyncCharacteristicData(serviceUUID: serviceUUIDString,
                                       characteristicUUID: characteristicUUIDString,
                                       stream: stream)
    }
    
    public func readCharacteristic(withUUID characteristicUUID: CBUUID,
                                                       inServiceWithUUID serviceUUID: CBUUID,
                                                       from device: CBPeripheral) async throws -> Data? {
        return try await readCharacteristic(withUUIDString: characteristicUUID.uuidString, inServiceWithUUIDString: serviceUUID.uuidString, from: device)
    }
    
    public func readCharacteristic(withUUIDString characteristicUUIDString: String,
                                                       inServiceWithUUIDString serviceUUIDString: String,
                                                       from device: CBPeripheral) async throws -> Data? {
        guard let peripheral = connectedPeripherals[device.identifier.uuidString] else {
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
        catch let error as BluetoothError {
            throw error
        }
    }
    
    // MARK: Write
    
    public func writeCharacteristic(_ data: Data,
                                                        writeType: CBCharacteristicWriteType = .withoutResponse,
                                                        toCharacteristicWithUUID characteristicUUID: CBUUID,
                                                        inServiceWithUUID serviceUUID: CBUUID,
                                                        from device: CBPeripheral) async throws -> Data? {
        return try await writeCharacteristic(data, writeType: writeType, toCharacteristicWithUUIDString: characteristicUUID.uuidString, inServiceWithUUIDString: serviceUUID.uuidString, from: device)
    }
    
    public func writeCharacteristic(_ data: Data,
                                                        writeType: CBCharacteristicWriteType = .withoutResponse,
                                                        toCharacteristicWithUUIDString characteristicUUIDString: String,
                                                        inServiceWithUUIDString serviceUUIDString: String,
                                                        from device: CBPeripheral) async throws -> Data? {
        guard let peripheral = connectedPeripherals[device.identifier.uuidString] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        
        guard let cbService = peripheral.services?.first(where: { $0.uuid.uuidString == serviceUUIDString }),
              let cbCharacteristic = cbService.characteristics?.first(where: { $0.uuid.uuidString == characteristicUUIDString }) else {
            throw BluetoothError.cantRetrieveCharacteristic(characteristicUUIDString)
        }
        
        guard continuations[device.identifier.uuidString] == nil else { throw BluetoothError.operationInProgress }
        defer {
            continuations.removeValue(forKey: device.identifier.uuidString)
        }
        
        do {
            let writeData = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data?, Error>) -> Void in
                continuations[device.identifier.uuidString] = .attribute(continuation)
                peripheral.writeValue(data, for: cbCharacteristic, type: writeType)
            }
            return writeData
        }
        catch let error as BluetoothError {
            throw error
        }
    }
    
    // MARK: Notify
    
    public func setNotify(_ notify: Bool,
                                     toCharacteristicWithUUID characteristicUUID: CBUUID,
                                     inServiceWithUUID serviceUUID: CBUUID,
                                     from device: CBPeripheral) async throws -> Bool {
        return try await setNotify(notify, toCharacteristicWithUUIDString: characteristicUUID.uuidString, inServiceWithUUIDString: serviceUUID.uuidString, from: device)
    }
    
    public func setNotify(_ notify: Bool,
                                     toCharacteristicWithUUIDString characteristicUUIDString: String,
                                     inServiceWithUUIDString serviceUUIDString: String,
                                     from device: CBPeripheral) async throws -> Bool {
        guard let peripheral = connectedPeripherals[device.identifier.uuidString] else {
            throw BluetoothError.cantRetrievePeripheral
        }
        peripheral.delegate = self
        
        guard let cbService = peripheral.services?.first(where: { $0.uuid.uuidString == serviceUUIDString }),
              let cbCharacteristic = cbService.characteristics?.first(where: { $0.uuid.uuidString == characteristicUUIDString }) else {
            throw BluetoothError.cantRetrieveCharacteristic(characteristicUUIDString)
        }
        
        guard continuations[device.identifier.uuidString] == nil else { throw BluetoothError.operationInProgress }
        defer {
            continuations.removeValue(forKey: device.identifier.uuidString)
        }
        
        do {
            let isNotifying = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) -> Void in
                continuations[device.identifier.uuidString] = .notificationChange(continuation)
                peripheral.setNotifyValue(notify, for: cbCharacteristic)
            }
            return isNotifying
        }
        catch let error as BluetoothError {
            throw error
        }
    }
    
    // MARK: Disconnect
    
    public func disconnect(from device: CBPeripheral) async throws {
        try await disconnect(fromWithUUID: device.identifier.uuidString)
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
        catch let error as BluetoothError {
            continuations.removeValue(forKey: deviceUUID)
            throw error
        }
    }
}
*/
