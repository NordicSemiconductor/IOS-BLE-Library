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

public class CentralManager {
    private let isScanningChannel = CurrentValueSubject<Bool, Never>(false)
    
    public let centralManager: CBCentralManager
    public let centralManagerDelegate: ReactiveCentralManagerDelegate
    
    public init(centralManagerDelegate: ReactiveCentralManagerDelegate = ReactiveCentralManagerDelegate(), queue: DispatchQueue = .main) {
        self.centralManagerDelegate = centralManagerDelegate
        self.centralManager = CBCentralManager(delegate: centralManagerDelegate, queue: queue)
    }
    
    public init(centralManager: CBCentralManager) throws {
        guard let reactiveDelegate = centralManager.delegate as? ReactiveCentralManagerDelegate else {
            throw CentralManagerError.wrongManager
        }
        
        self.centralManager = centralManager
        self.centralManagerDelegate = reactiveDelegate
    }
}

// MARK: Channels
extension CentralManager {
    public var stateChannel: AnyPublisher<CBManagerState, Never> {
        centralManagerDelegate.statePublisher
            .share()
            .eraseToAnyPublisher()
    }
    
    public var scanResultsChannel: AnyPublisher<ScanResult, Never> {
        centralManagerDelegate.scanResultSubject
            .share()
            .eraseToAnyPublisher()
    }
    
    public var connetedPeripheralChannel: AnyPublisher<(CBPeripheral, Error?), Never> {
        centralManagerDelegate.connetedPeripheralSubject
            .share()
            .eraseToAnyPublisher()
    }
    
    public var disconnectedPeripheralsChannel: AnyPublisher<(CBPeripheral, Error?), Never> {
        centralManagerDelegate.disconnectedPeripheralsSubject
            .share()
            .eraseToAnyPublisher()
    }
}

extension CentralManager {
    public func stopScan() {
        centralManager.stopScan()
        isScanningChannel.send(false)
    }
    
    public func scanForPeripherals(withServices services: [CBUUID]?) -> AnyPublisher<ScanResult, Error> {
        stopScan()
        isScanningChannel.send(true)
        
        return centralManagerDelegate.stateSubject
            .prefix(untilOutputFrom: isScanningChannel.first { !$0 }.share())
            .tryFirst { state in
                guard let determined = state.ready else { return false }

                guard determined else { throw CentralManagerError.badState(state) }
                return true
            }
            .flatMap { _ in
                // TODO: Check for mmemory leaks
                self.isScanningChannel.send(true)
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

