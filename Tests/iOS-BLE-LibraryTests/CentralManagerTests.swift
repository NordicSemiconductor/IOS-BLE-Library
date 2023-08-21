//
//  CentralManagerTests.swift
//  
//
//  Created by Nick Kibysh on 18/08/2023.
//

import XCTest
@testable import iOS_BLE_Library
import CoreBluetoothMock_Collection
import CoreBluetoothMock
import Combine

final class CentralManagerTests: XCTestCase {
    
    var cancelables: Set<AnyCancellable>!
    var central: CentralManager!
    var rs: RunningSpeedAndCadence!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.rs = RunningSpeedAndCadence()
        
        let cmd = ReactiveCentralManagerDelegate()
        let cm = CBCentralManagerFactory.instance(delegate: cmd, queue: .main, forceMock: true)
        self.central = try CentralManager(centralManager: cm)
        
        CBMCentralManagerMock.simulateInitialState(.unknown)
        CBMCentralManagerMock.simulatePeripherals([rs.peripheral])
        
        cancelables = Set()
        central = CentralManager()
    }

    override func tearDownWithError() throws {
        cancelables.removeAll()
        cancelables = nil
        central = nil
        rs = nil
    }

    func testScan() async {
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .prefix(1)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: { _ in
                
            })
            .store(in: &cancelables)
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
    func testFailedStateScan() async {
        CBMCentralManagerMock.simulateInitialState(.poweredOff)
        
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .prefix(1)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Failure completion is expeted")
                case .failure(let error) where error is CentralManager.Error:
                    guard case CentralManager.Error.badState(let s) = error else {
                        XCTFail("Expected `badState` error. Found: \(error.localizedDescription)")
                        break
                    }
                    
                    XCTAssertEqual(s, .poweredOff)
                case .failure(let e):
                    XCTFail("Should be CentralManager.Error.badState. Found \(e.localizedDescription)")
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                XCTFail("No peripherals are expected. Failure completion is expeted")
            })
            .store(in: &cancelables)
        
        await fulfillment(of: [expectation], timeout: 5)
    }
    
}
