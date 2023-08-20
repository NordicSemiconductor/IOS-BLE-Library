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
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        cancelables = Set()
        central = CentralManager()
    }

    override func tearDownWithError() throws {
        cancelables.removeAll()
        cancelables = nil
        central = nil
        rs = nil
    }
    
    func testPublisher() {
        let expectation = XCTestExpectation(description: "Scan for peripherals")
        
        [1, 2, 3].publisher
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .sink { v in
                expectation.fulfill()
            }
            .store(in: &cancelables)
        
        wait(for: [expectation], timeout: 2)
    }

    func testScan() {
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        central.scanForPeripherals(withServices: nil)
            .autoconnect()
//            .prefix(1)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                fatalError()
            })
            .store(in: &cancelables)
        
        wait(for: [expectation], timeout: 15)
    }
    
//    func testScanSeq() async throws {
//        var peripherals: Int = 0
//
//        for try await p in central.scanForPeripherals(withServices: nil).autoconnect().prefix(2).values {
//            peripherals += 1
//        }
//
//        XCTAssertEqual(peripherals, 2)
//    }

}
