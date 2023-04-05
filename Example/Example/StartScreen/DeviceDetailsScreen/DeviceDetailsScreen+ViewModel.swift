//
//  DeviceDetailsScreen+ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 29/03/2023.
//

import Foundation
import iOS_BLE_Library
import iOS_Bluetooth_Numbers_Database

extension DeviceDetailsScreen {
    class ViewModel: ObservableObject {
        let scanData: Bluetooth.ScanData
        let bluetooth = Bluetooth()
        
        @Published var name: String = ""
        @Published var advertisementData: AdvertisementData = AdvertisementData([:])
        @Published var isConnectable: Bool = false
        
        @Published var discoveredServices: [Service] = []
        @Published var serviceName: String = ""
        
        init(scanData: Bluetooth.ScanData) {
            self.scanData = scanData
            
            name = scanData.advertisementData.localName ?? "No Local Name"
            advertisementData = scanData.advertisementData
            isConnectable = scanData.advertisementData.isConnectable == true
            
        }
    }
}

extension DeviceDetailsScreen.ViewModel {
    struct Service: Identifiable, Equatable {
        let name: String
        let uuidString: String
        
        var id: String {
            uuidString
        }
        
        var characteristics: [Characteristic] = []
    }
    
    struct Characteristic: Identifiable, Equatable {
        let name: String
        let uuidString: String
        
        var id: String {
            uuidString
        }
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
        do {
            try await bluetooth.connect(to: scanData.peripheral)
            
            let services = try await bluetooth.discoverServices(of: scanData.peripheral)
                .map {
                    iOS_Bluetooth_Numbers_Database.Service.find(by: $0.uuid) ??
                    iOS_Bluetooth_Numbers_Database.Service(name: "Unknown Service", identifier: "", uuidString: $0.uuid.uuidString, source: "")
                }
                .map {
                    Service(name: $0.name, uuidString: $0.uuidString)
                }
                .asyncMap { s in
                    var service = s
                    service.characteristics = (try await bluetooth.discoverCharacteristics(ofService: s.uuidString, ofDeviceWithUUID: scanData.peripheral.identifier.uuidString) ?? [])
                        .map {
                            iOS_Bluetooth_Numbers_Database.Characteristic.find(by: $0.uuid) ??
                            iOS_Bluetooth_Numbers_Database.Characteristic(name: "Unknown Characteristic", identifier: $0.uuid.uuidString, uuidString: "", source: "")
                        }
                        .map {
                            Characteristic(name: $0.name, uuidString: $0.uuidString)
                        }
                    
                    return service
                }
            
            self.discoveredServices = services
            self.serviceName = services.first?.name ?? "No Service"
        } catch let e {
            print(e.localizedDescription)
        }
    }
}
