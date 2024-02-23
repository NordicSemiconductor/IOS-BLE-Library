//
//  PeripheralReadWriteDescriptorTests.swift
//  
//
//  Created by Nick Kibysh on 23/02/2024.
//

import Combine
import CoreBluetoothMock
import XCTest

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

private class MockPeripheral: CBMPeripheralSpecDelegate {
    
    private var batteryLevel: UInt8 = 0
    private (set) var lastWroteCommandValue: Data?
    
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
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristicMock) -> Result<Data, Error> {
        defer { batteryLevel += 1 }
        
        if batteryLevel % 2 == 0 {
            return .failure(NSError(domain: "com.ble.characteristic", code: 1, userInfo: ["value":batteryLevel]))
        } else {
            return .success(Data([batteryLevel]))
        }
    }
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteCommandFor characteristic: CBMCharacteristicMock, data: Data) {
        lastWroteCommandValue = data
    }
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Result<Void, Error> {
        defer { lastWroteCommandValue = data }
        
        if data[0] % 2 == 0 {
            return .failure(NSError(domain: "com.ble.characteristic", code: 2, userInfo: ["value": data]))
        } else {
            return .success(())
        }
    }
}

final class PeripheralReadWriteDescriptorTests: XCTestCase {
    var cancelables: Set<AnyCancellable>!
    var central: CentralManager!
    private var rs: MockPeripheral!
    
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
    
    func testReadCharacteristic() async throws {
        let p = try await central.scanForPeripherals(withServices: nil)
            .flatMap { self.central.connect($0.peripheral) }
            .map { Peripheral(peripheral: $0, delegate: ReactivePeripheralDelegate()) }
            .firstValue
        
        let batteryService = try await p.discoverServices(serviceUUIDs: [.batteryService ]).firstValue.first!
        let batteryLevelCharacteristic = try await p.discoverCharacteristics([.batteryLevel], for: batteryService).firstValue.first!
        
        do {
            _ = try await p.readValue(for: batteryLevelCharacteristic).firstValue
        } catch let e as NSError {
            let level = try XCTUnwrap(e.userInfo["value"] as? UInt8)
            XCTAssertEqual(level, 0)
            XCTAssertEqual(e.code, 1)
        } catch {
            XCTFail("unexpected error")
        }
        
        do {
            let data = try await p.readValue(for: batteryLevelCharacteristic).firstValue
            let level = try XCTUnwrap(data?[0] as? UInt8)
            XCTAssertEqual(level, 1)
        } catch {
            XCTFail("unexpected error")
        }
    }
    
    func testWriteWithoutResponse() async throws {
        let delegate = ReactivePeripheralDelegate()
        
        let p = try await central.scanForPeripherals(withServices: nil)
            .flatMap { self.central.connect($0.peripheral) }
            .map { Peripheral(peripheral: $0, delegate: delegate) }
            .firstValue
        
        let batteryService = try await p.discoverServices(serviceUUIDs: [.batteryService ]).firstValue.first!
        let batteryLevelCharacteristic = try await p.discoverCharacteristics([.batteryLevel], for: batteryService).firstValue.first!
        
        let isReadyExp = expectation(description: "Peripheral is ready to write value without response")
        p.isReadyToSendWriteWithoutResponseChannel
            .sink { _ in
                isReadyExp.fulfill()
            } receiveValue: { _ in
            }
            .store(in: &cancelables)

        
        let data = Data([1, 2, 3])
        p.writeValueWithoutResponse(data, for: batteryLevelCharacteristic)
        XCTAssertEqual(data, rs.lastWroteCommandValue)
        
        await fulfillment(of: [isReadyExp], timeout: 3)
    }
}
