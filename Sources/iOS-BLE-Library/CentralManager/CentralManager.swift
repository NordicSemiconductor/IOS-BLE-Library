//
//  File.swift
//
//
//  Created by Nick Kibysh on 18/04/2023.
//

import Foundation
import CoreBluetoothMock
import Combine

extension CentralManager {
    public enum Error: Swift.Error {
        case wrongManager
        case badState(CBManagerState)
        case unknownError
    }
}

private class Observer: NSObject {
    @objc dynamic private weak var cm: CBCentralManager?
    private weak var publisher: CurrentValueSubject<Bool, Never>?
    private var observation: NSKeyValueObservation?
    
    init(cm: CBCentralManager, publisher: CurrentValueSubject<Bool, Never>) {
        self.cm = cm
        self.publisher = publisher
        super.init()
    }
    
    func setup() {
        observation = observe(\.cm?.isScanning,
                               options: [.old, .new],
                               changeHandler: { _, change in
            
            change.newValue?.flatMap { [weak self] new in
                self?.publisher?.send(new) }
            }
        )
    }
}

public class CentralManager {
    private let isScanningSubject = CurrentValueSubject<Bool, Never>(false)
    private let killSwitchSubject = PassthroughSubject<Void, Never>()
    private lazy var observer = Observer(cm: centralManager, publisher: isScanningSubject)
    
    public let centralManager: CBCentralManager
    public let centralManagerDelegate: ReactiveCentralManagerDelegate
    
    public init(centralManagerDelegate: ReactiveCentralManagerDelegate = ReactiveCentralManagerDelegate(), queue: DispatchQueue = .main) {
        self.centralManagerDelegate = centralManagerDelegate
        self.centralManager = CBCentralManagerFactory.instance(delegate: centralManagerDelegate, queue: queue)
        observer.setup()
    }
    
    public init(centralManager: CBCentralManager) throws {
        guard let reactiveDelegate = centralManager.delegate as? ReactiveCentralManagerDelegate else {
            throw Error.wrongManager
        }
        
        self.centralManager = centralManager
        self.centralManagerDelegate = reactiveDelegate
        
        observer.setup()
    }
}

// MARK: Establishing or Canceling Connections with Peripherals
extension CentralManager {
    public func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) -> Publishers.Peripheral {
        return self.connectedPeripheralChannel
        .tryFilter { r in
            guard r.0.identifier == peripheral.identifier else {
                return false
            }
            
            if let e = r.1 {
                throw e
            } else {
                return true
            }
        }
        .map { $0.0 }
        .first()
        .peripheral {
            self.centralManager.connect(peripheral, options: options)
        }
    }
    
    public func cancelPeripheralConnection(_ peripheral: CBPeripheral) -> Publishers.Peripheral {
        return self.disconnectedPeripheralsChannel
            .tryFilter { r in
                guard r.0.identifier == peripheral.identifier else {
                    return false
                }
                
                if let e = r.1 {
                    throw e
                } else {
                    return true
                }
            }
            .map { $0.0 }
            .first()
            .peripheral {
                self.centralManager.cancelPeripheralConnection(peripheral)
            }
    }
}

// MARK: Retrieving Lists of Peripherals
extension CentralManager {
    public func retrieveConnectedPeripherals(withServices identifiers: [CBUUID]) -> [CBPeripheral] {
        centralManager.retrieveConnectedPeripherals(withServices: identifiers)
    }
    
    public func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBPeripheral] {
        centralManager.retrievePeripherals(withIdentifiers: identifiers)
    }
}

// MARK: Scanning or Stopping Scans of Peripherals
extension CentralManager {
    public func scanForPeripherals(withServices services: [CBUUID]?) -> Publishers.BluetoothPublisher<ScanResult, Swift.Error> {
        stopScan()
        // TODO: Change to BluetoothPublisher
        return centralManagerDelegate.stateSubject
            .prefix(untilOutputFrom: killSwitchSubject)
            .tryFirst { state in
                guard let determined = state.ready else { return false }

                guard determined else { throw Error.badState(state) }
                return true
            }
            .flatMap { _ in
                // TODO: Check for mmemory leaks
                return self.centralManagerDelegate.scanResultSubject
                    .setFailureType(to: Swift.Error.self)
            }
            .map { a in
                return a 
            }
            .mapError{ [weak self] e in
                self?.stopScan()
                return e
            }
            .bluetooth {
                self.centralManager.scanForPeripherals(withServices: services)
            }
    }
    
    public func stopScan() {
        centralManager.stopScan()
    }
}


// MARK: Channels
extension CentralManager {
    public var stateChannel: AnyPublisher<CBManagerState, Never> {
        centralManagerDelegate
            .stateSubject
            .eraseToAnyPublisher()
    }
    
    public var isScanningChannel: AnyPublisher<Bool, Never> {
        isScanningSubject
            .eraseToAnyPublisher()
    }
    
    public var scanResultsChannel: AnyPublisher<ScanResult, Never> {
        centralManagerDelegate.scanResultSubject
            .eraseToAnyPublisher()
    }
    
    public var connectedPeripheralChannel: AnyPublisher<(CBPeripheral, Swift.Error?), Never> {
        centralManagerDelegate.connectedPeripheralSubject
            .eraseToAnyPublisher()
    }
    
    public var disconnectedPeripheralsChannel: AnyPublisher<(CBPeripheral, Swift.Error?), Never> {
        centralManagerDelegate.disconnectedPeripheralsSubject
            .eraseToAnyPublisher()
    }
}
