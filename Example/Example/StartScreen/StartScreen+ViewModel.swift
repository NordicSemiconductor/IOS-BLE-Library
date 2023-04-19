//
//  StartScreen+ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_BLE_Library
import Combine
import CoreBluetooth

extension ScanResult: Identifiable {
    public var id: UUID {
        self.peripheral.identifier
    }
}

extension StartScreen {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: StartScreen.State = .unknown
        @Published var isScanning: Bool = false
        @Published var scanResults: [ScanResult] = []
        
        private var cancelable = Set<AnyCancellable>()
        
        private var deviceViewModels: [UUID: DeviceDetailsScreen.ViewModel] = [:]
        
        private let centralManager = CentralManager()
        
        func startScan() {
            centralManager.scan()
                .scan([ScanResult]()) { arr, sr in
                    arr.appendedOrReplaced(sr, where: { $0.id == sr.id })
                }
                .sink { _ in
                    
                } receiveValue: { sr in
                    self.scanResults = sr
                }
                .store(in: &cancelable)

        }
        
        func deviceViewModel(with scanData: ScanResult) -> DeviceDetailsScreen.ViewModel {
            if let vm = deviceViewModels[scanData.peripheral.identifier] {
                return vm
            } else {
                let vm = DeviceDetailsScreen.ViewModel(
                    deviceId: scanData.peripheral.identifier.uuidString
                )
                deviceViewModels[scanData.peripheral.identifier] = vm
                return vm
            }
        }
    }
}
