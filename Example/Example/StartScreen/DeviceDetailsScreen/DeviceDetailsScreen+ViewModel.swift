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
        let centralManager: CentralManager
        
        private var cancelable = Set<AnyCancellable>()
        private var peripheral: CBPeripheral?
        
        // MARK: Published
        @Published var name: String = ""
        @Published var rssi: RSSI = .outOfRange
        @Published var isConnectable: Bool = false
        
        @Published var advertisementData: AdvertisementData = AdvertisementData([:])
        
        @Published var discoveredServices: [Service] = []
        
        init(peripheral: CBPeripheral, rssi: RSSI, centralManager: CentralManager, advertisementData: AdvertisementData) {
            self.peripheral = peripheral
            self.centralManager = centralManager
            self.rssi = rssi
            self.advertisementData = advertisementData
            
            setupDisplayValues()
        }
        
        init(scanResult: ScanResult, centralManager: CentralManager) {
            self.centralManager = centralManager
            self.peripheral = scanResult.peripheral
            self.rssi = scanResult.rssi
            self.advertisementData = scanResult.advertisementData
            
            setupDisplayValues()
        }
        
        private func setupDisplayValues() {
            self.name = peripheral?.name ?? "n/a"
            self.isConnectable = advertisementData.isConnectable ?? false
        }
        
        #if DEBUG
        init() {
            self.centralManager = CentralManager()
        }
        #endif
        
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
//        guard let peripheral else {
//            fatalError()
//        }
//        
        
    }
}
