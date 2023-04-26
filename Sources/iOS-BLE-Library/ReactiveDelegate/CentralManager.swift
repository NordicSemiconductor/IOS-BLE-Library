//
//  File.swift
//
//
//  Created by Nick Kibysh on 18/04/2023.
//

import Foundation
import CoreBluetooth
import Combine

extension CentralManager {
    enum CentralManagerError: Error {
        case wrongManager
        case badState(CBManagerState)
        case unknownError
    }
}

private class Observer: NSObject {
    @objc private weak var cm: CBCentralManager!
    private weak var publisher: CurrentValueSubject<Bool, Never>!
    private var obserwation: NSKeyValueObservation?
    
    init(cm: CBCentralManager, publisher: CurrentValueSubject<Bool, Never>) {
        self.cm = cm
        self.publisher = publisher
        super.init()
    }
    
    func setup() {
        obserwation = observe(\.cm?.isScanning,
                               options: [.old, .new],
                               changeHandler: { _, change in
            
            change.newValue?.flatMap { [weak self] new in
                self?.publisher.send(new) }
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
    
    var observation: NSKeyValueObservation?
    
    public init(centralManagerDelegate: ReactiveCentralManagerDelegate = ReactiveCentralManagerDelegate(), queue: DispatchQueue = .main) {
        self.centralManagerDelegate = centralManagerDelegate
        self.centralManager = CBCentralManager(delegate: centralManagerDelegate, queue: queue)
        observer.setup()
    }
    
    public init(centralManager: CBCentralManager) throws {
        guard let reactiveDelegate = centralManager.delegate as? ReactiveCentralManagerDelegate else {
            throw CentralManagerError.wrongManager
        }
        
        self.centralManager = centralManager
        self.centralManagerDelegate = reactiveDelegate
        
        observer.setup()
    }
}

// MARK: Methods
extension CentralManager {
    public func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) -> AnyPublisher<CBPeripheral, Error> {
        return Deferred {
            Future<Void, Never> { promise in
                self.centralManager.connect(peripheral, options: options)
                promise(.success(()))
            }
        }
        .flatMap {
            self.connectedPeripheralChannel
        }
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
        .eraseToAnyPublisher()
    }
}

// MARK: Channels
extension CentralManager {
    public var stateChannel: AnyPublisher<CBManagerState, Never> {
        centralManagerDelegate.statePublisher
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
    
    public var connectedPeripheralChannel: AnyPublisher<(CBPeripheral, Error?), Never> {
        centralManagerDelegate.connectedPeripheralSubject
            .eraseToAnyPublisher()
    }
    
    public var disconnectedPeripheralsChannel: AnyPublisher<(CBPeripheral, Error?), Never> {
        centralManagerDelegate.disconnectedPeripheralsSubject
            .eraseToAnyPublisher()
    }
}

extension CentralManager {
    public func stopScan() {
        centralManager.stopScan()
    }
    
    public func scanForPeripherals(withServices services: [CBUUID]?) -> AnyPublisher<ScanResult, Error> {
        stopScan()
        
        return centralManagerDelegate.stateSubject
            .prefix(untilOutputFrom: killSwitchSubject)
            .tryFirst { state in
                guard let determined = state.ready else { return false }

                guard determined else { throw CentralManagerError.badState(state) }
                return true
            }
            .flatMap { _ in
                // TODO: Check for mmemory leaks
                self.centralManager.scanForPeripherals(withServices: services)
                return self.centralManagerDelegate.scanResultSubject
                    .setFailureType(to: Error.self)
            }
            .mapError{ [weak self] e in
                self?.stopScan()
                return e
            }
            .eraseToAnyPublisher()
    }
    
    
}

