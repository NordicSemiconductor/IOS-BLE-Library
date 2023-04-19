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

extension CentralManager {
    public func scan() -> AnyPublisher<ScanResult, Error> {
        return centralManagerDelegate.stateSubject
            .tryFirst { state in
                guard let determined = state.ready else { return false }

                guard determined else { throw CentralManagerError.badState(state) }
                return true
            }
            .mapError { $0 as Swift.Error }
            .flatMap { _ -> AnyPublisher<ScanResult, Swift.Error> in
                self.centralManager.scanForPeripherals(withServices: [])
                return self.centralManagerDelegate.scanResultSubject
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

