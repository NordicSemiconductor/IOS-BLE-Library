//
//  CentralManagerStateTest.swift
//  
//
//  Created by Nick Kibysh on 29/08/2023.
//
import XCTest
@testable import iOS_BLE_Library_Mock
import CoreBluetoothMock
import Combine

final class CentralManagerStateTest: XCTestCase {
    func testStateChanges() async throws {
        var cancelables = Set<AnyCancellable>()
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        let central = CentralManager()
        
        let powerOffExp = expectation(description: "Power OFF state")
        let powerOnExp = expectation(description: "Power ON state")
        let authorizationExp = expectation(description: "Unauthorized state")
        let unknownStateExp = expectation(description: "Unknown State")
        
        central.stateChannel
            .scan(([], nil)) { // Distinct Values
                $0.0.contains($1) ? ($0.0, nil) : ($0.0 + [$1], $1)
            }
            .compactMap { $0.1 }
            .sink { state in
                switch state {
                case .poweredOff: powerOffExp.fulfill()
                case .poweredOn: powerOnExp.fulfill()
                case .unauthorized: authorizationExp.fulfill()
                case .resetting: XCTFail("Unexpected state")
                case .unknown: unknownStateExp.fulfill()
                case .unsupported: XCTFail("Unexpected state")
                }
            }
            .store(in: &cancelables)
        
        await fulfillment(of: [unknownStateExp], timeout: 1.0)
        
        CBMCentralManagerMock.simulatePowerOff()
        await fulfillment(of: [powerOffExp], timeout: 1.0)
        
        CBMCentralManagerMock.simulateAuthorization(.denied)
        await fulfillment(of: [authorizationExp], timeout: 1.0)
        
        CBMCentralManagerMock.simulateAuthorization(.allowedAlways)
        
        CBMCentralManagerMock.simulatePowerOn()
        await fulfillment(of: [powerOnExp], timeout: 1.0)
    }
}
