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
    
    override func setUpWithError() throws {
        let cmd = ReactiveCentralManagerDelegate()
        let cm = CBCentralManagerFactory.instance(delegate: cmd, queue: .main, forceMock: true)
        self.central = try CentralManager(centralManager: cm)
        
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        CBMCentralManagerMock.simulatePeripherals([blinky, hrm, weightScale])
        cancelables = Set()
        central = CentralManager()
    }

    override func tearDownWithError() throws {
        cancelables.removeAll()
        cancelables = nil
        central = nil
    }

    func testScan() {
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .prefix(2)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: { _ in
                fatalError()
            })
            .store(in: &cancelables)
        
        wait(for: [expectation], timeout: 15)
    }
    
    func testScanSeq() async throws {
        var peripherals: Int = 0
        
        for try await p in central.scanForPeripherals(withServices: nil).autoconnect().prefix(2).values {
            peripherals += 1
        }
        
        XCTAssertEqual(peripherals, 2)
    }

}
