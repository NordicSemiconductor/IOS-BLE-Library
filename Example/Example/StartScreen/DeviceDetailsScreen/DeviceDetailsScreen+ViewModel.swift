//
//  DeviceDetailsScreen+ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 29/03/2023.
//

import Foundation
import iOS_BLE_Library
import iOS_Bluetooth_Numbers_Database
import Combine

extension DeviceDetailsScreen {
    @MainActor
    class ViewModel: ObservableObject {
        let deviceId: CBUUID
        
        private var cancelable = Set<AnyCancellable>()
        private var peripheral: CBPeripheral?
        
        @Published var name: String = ""
        @Published var advertisementData: AdvertisementData = AdvertisementData([:])
        @Published var isConnectable: Bool = false
        
        @Published var discoveredServices: [Service] = []
        
        init(deviceId: CBUUID, bluetooth: Bluetooth = Bluetooth()) {
            self.deviceId = deviceId
            self.discoverDevice()
        }
        
        convenience
        init(deviceId: String, bluetooth: Bluetooth = Bluetooth()) {
            let id = CBUUID(string: deviceId)
            self.init(deviceId: id, bluetooth: bluetooth)
        }
        
        func discoverDevice() {
        }
    }
}

extension DeviceDetailsScreen.ViewModel {
    struct Service: NestedStringRepresentable {
        var description: String { name }
        
        let level: UInt = 1
        
        let name: String
        let id: String
        
        var characteristics: [Characteristic] = []
    }
    
    struct Characteristic: NestedStringRepresentable {
        var description: String { name }
        
        let level: UInt = 2
        
        let name: String
        let id: String
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}

extension DeviceDetailsScreen.ViewModel {
    func connect() async {
//        guard let peripheral = self.peripheral else { return }
//        
//        do {
//            try await bluetooth.connect(to: peripheral)
//            
//            let services = try await bluetooth.discoverServices(of: peripheral)
//                .map {
//                    iOS_Bluetooth_Numbers_Database.Service.find(by: $0.uuid) ??
//                    iOS_Bluetooth_Numbers_Database.Service(name: "Unknown Service", identifier: "", uuidString: $0.uuid.uuidString, source: "")
//                }
//                .map {
//                    Service(name: $0.name, id: $0.uuidString)
//                }
//                .asyncMap { s in
//                    var service = s
//                    service.characteristics = (try await bluetooth.discoverCharacteristics(ofService: s.id, ofDeviceWithUUID: peripheral.identifier.uuidString) ?? [])
//                        .map {
//                            iOS_Bluetooth_Numbers_Database.Characteristic.find(by: $0.uuid) ??
//                            iOS_Bluetooth_Numbers_Database.Characteristic(name: "Unknown Characteristic", identifier: $0.uuid.uuidString, uuidString: "", source: "")
//                        }
//                        .map {
//                            Characteristic(name: $0.name, id: $0.uuidString)
//                        }
//                    
//                    return service
//                }
//            
//            self.discoveredServices = services
//        } catch let e {
//            print(e.localizedDescription)
//        }
    }
}
