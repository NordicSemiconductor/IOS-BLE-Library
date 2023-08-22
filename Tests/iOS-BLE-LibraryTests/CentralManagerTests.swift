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
        
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        CBMCentralManagerMock.simulatePeripherals([rs.peripheral])
        
        cancelables = Set()
        central = CentralManager()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        cancelables.removeAll()
        cancelables = nil
        central = nil
        rs = nil
        CBMCentralManagerMock.tearDownSimulation()
    }

    func testScan() async {
        let valueExpectation = XCTestExpectation(description: "Receive at least 1 value (ScanResult)")
        let completionExpectation = XCTestExpectation(description: "Publisher finished")
        
        central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .prefix(1)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    completionExpectation.fulfill()
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                }
            }, receiveValue: { _ in
                valueExpectation.fulfill()
            })
            .store(in: &cancelables)
        
        await fulfillment(of: [valueExpectation, completionExpectation], timeout: 5)
    }
    
    func testFailedStateScan() async {
        CBMCentralManagerMock.simulatePowerOff()
        
        let expectation = XCTestExpectation(description: "Scan for peripherals")

        central.scanForPeripherals(withServices: nil)
            .autoconnect()
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

    func testStopScan() async {
        let firstExp = XCTestExpectation(description: "First scan for peripherals")
        let valueExpectation1 = XCTestExpectation(description: "1: Receive at least 1 value (ScanResult)")

        central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    firstExp.fulfill()
                case .failure(let e):
                    XCTFail("Found error: \(e.localizedDescription), instead of success result")
                }
                firstExp.fulfill()
            }, receiveValue: { _ in
                valueExpectation1.fulfill()
                self.central.stopScan()
            })
            .store(in: &cancelables)
        
        await fulfillment(of: [firstExp, valueExpectation1], timeout: 5)
        
        let valueExpectation2 = XCTestExpectation(description: "2: Receive at least 1 value (ScanResult)")
        let secondExp = XCTestExpectation(description: "Repeated scan for peripherals")
        
        central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    secondExp.fulfill()
                case .failure(let e):
                    XCTFail("Found error: \(e.localizedDescription), instead of success result")
                }
                secondExp.fulfill()
            }, receiveValue: { _ in
                valueExpectation2.fulfill()
                self.central.stopScan()
            })
            .store(in: &cancelables)
        
        await fulfillment(of: [secondExp, valueExpectation2], timeout: 5)
    }
    
    func testConnect() async throws {
        let connectionPeripheral = try await central.scanForPeripherals(withServices: nil)
            .autoconnect()
            .prefix(1)
            .value
            .peripheral
        
        let connectionExpectation = XCTestExpectation(description: "Connection expectation")
        let disconnectionExpectation = XCTestExpectation(description: "Disconnection expectation")
        central.connect(connectionPeripheral)
            .autoconnect()
            .sink { completion in
                switch completion {
                case .finished:
                    disconnectionExpectation.fulfill()
                case .failure(let e):
                    XCTFail(e.localizedDescription)
                }
            } receiveValue: { peripheral in
                XCTAssertEqual(peripheral.identifier, connectionPeripheral.identifier)
                connectionExpectation.fulfill()
            }
            .store(in: &cancelables)

        await fulfillment(of: [connectionExpectation], timeout: 3)
        
        central.cancelPeripheralConnection(connectionPeripheral)
            .autoconnect()
            .sink { completion in
                if case .failure(let e) = completion {
                    XCTFail(e.localizedDescription)
                }
            } receiveValue: { peripheral in
                XCTAssertEqual(peripheral.identifier, connectionPeripheral.identifier)
            }
            .store(in: &cancelables)
        
        await fulfillment(of: [disconnectionExpectation], timeout: 3)
    }
}
