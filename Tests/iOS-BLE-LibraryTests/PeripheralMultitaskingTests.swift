//
//  PeripheralMultitaskingTests.swift
//  
//
//  Created by Nick Kibysh on 03/11/2023.
//

import XCTest
import Combine
import CoreBluetoothMock

@testable import iOS_BLE_Library_Mock

private extension CBMUUID {
    static let runningSpeedCadenceService = CBUUID(string: "1814")
    static let batteryService = CBUUID(string: "180F")
    static let heartRateMonitorService = CBUUID(string: "180D")
    static let deviceInformationService = CBUUID(string: "180A")
    
    static var allServices: [CBMUUID] = [
        .batteryService,
        .runningSpeedCadenceService,
        .heartRateMonitorService,
        .deviceInformationService
    ]
    
    static let batteryLevel = CBUUID(string: "2A19")
    static let presentationFormat = CBUUID(string: "2904")
}

class MockPeripheral: CBMPeripheralSpecDelegate {
    public private (set) lazy var peripheral = CBMPeripheralSpec
        .simulatePeripheral(proximity: .far)
        .advertising(
            advertisementData: [
                CBAdvertisementDataIsConnectable : true as NSNumber,
                CBAdvertisementDataLocalNameKey : "Running Speed and Cadence sensor",
                CBAdvertisementDataServiceUUIDsKey : [CBMUUID.runningSpeedCadenceService]
            ],
            withInterval: 2.0,
            delay: 5.0,
            alsoWhenConnected: false
        )
        .connectable(
            name: "Running Sensor",
            services: CBMUUID.allServices.map {
                if $0 == .batteryService {
                    return CBMServiceMock(
                        type: $0,
                        primary: true,
                        characteristics: [
                            CBMCharacteristicMock(type: .batteryLevel, properties: .read, descriptors: CBMDescriptorMock(type: .presentationFormat))
                        ])
                } else {
                    return CBMServiceMock(type: $0, primary: true)
                }
            },
            delegate: self
        )
        .build()
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?) -> Result<Void, Error> {
        return .success(())
    }
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveCharacteristicsDiscoveryRequest characteristicUUIDs: [CBMUUID]?, for service: CBMServiceMock) -> Result<Void, Error> {
        return .success(())
    }
}

final class PeripheralMultitaskingTests: XCTestCase {
    var cancelables: Set<AnyCancellable>!
    var central: CentralManager!
    var rs: MockPeripheral!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        self.rs = MockPeripheral()
        
        CBMCentralManagerMock.simulateInitialState(.poweredOn)
        CBMCentralManagerMock.simulatePeripherals([rs.peripheral])
        
        let cmd = ReactiveCentralManagerDelegate()
        let cm = CBCentralManagerFactory.instance(delegate: cmd, queue: .main, forceMock: true)
        self.central = try CentralManager(centralManager: cm)
        
        cancelables = Set()
    }
    
    func testDiscoverServices() async throws {
        let p = try await central.scanForPeripherals(withServices: nil)
            .flatMap { self.central.connect($0.peripheral) }
            .map { Peripheral(peripheral: $0, delegate: ReactivePeripheralDelegate()) }
            .firstValue
        
        let batteryExp = expectation(description: "Battery Service Expectation")
        let hrExp = expectation(description: "Heart Rate Service Expectation")
        
        p.discoverServices(serviceUUIDs: [.heartRateMonitorService])
            .sink { completion in
                if case .failure = completion {
                    XCTFail("Should not fail")
                }
            } receiveValue: { services in
                if case .some = services.first(where: { $0.uuid == CBUUID.heartRateMonitorService }) {
                    hrExp.fulfill()
                }
            }
            .store(in: &cancelables)

        p.discoverServices(serviceUUIDs: [.batteryService])
            .sink { completion in
                if case .failure = completion {
                    XCTFail("Should not fail")
                }
            } receiveValue: { services in
                if case .some = services.first(where: { $0.uuid == CBUUID.batteryService }) {
                    batteryExp.fulfill()
                }
            }
            .store(in: &cancelables)
        
        await fulfillment(of: [batteryExp, hrExp], timeout: 4)
    }
    
    func testDiscoverCharacteristics() async throws {
        let p = try await central.scanForPeripherals(withServices: nil)
            .flatMap { self.central.connect($0.peripheral) }
            .map { Peripheral(peripheral: $0, delegate: ReactivePeripheralDelegate()) }
            .firstValue
        
        let batteryService = try await p.discoverServices(serviceUUIDs: [.batteryService ]).firstValue.first!
        
        let characteristicExp = expectation(description: "Characteristic expectation")
        let descriptorExp = expectation(description: "Descriptor expectation")
        
        Task {
            let ch = try await p.discoverCharacteristics([.batteryLevel], for: batteryService).firstValue.first!
            characteristicExp.fulfill()
            
            let desc = try await p.discoverDescriptors(for: ch).firstValue.first!
            descriptorExp.fulfill()
            
            XCTAssert(ch.uuid == CBUUID.batteryLevel)
            XCTAssert(desc.uuid == CBUUID.presentationFormat)
        }
        
        await fulfillment(of: [characteristicExp, descriptorExp], timeout: 4)
    }
}
