//
//  StartScreen+ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import Combine
import CoreBluetoothMock
import SwiftUI
import iOS_BLE_Library

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
        @Published var displayError: ReadableError? = nil {
            didSet {
                showError = displayError != nil
            }
        }
        
        @Published var showError: Bool = false
        
        private var cancelable = Set<AnyCancellable>()
        
        private var deviceViewModels: [UUID: DeviceDetailsScreen.ViewModel] = [:]
        
        private let centralManager: CentralManager
        
        init() {
            centralManager = CentralManager()
        }
        
        func stopScan() {
            centralManager.stopScan()
            isScanning = false
        }
        
        func startScan() {
            isScanning = true
            centralManager.scanForPeripherals(withServices: [])
                .filter { $0.name != nil }
                .scan([ScanResult]()) { arr, sr in
                    arr.appendedOrReplaced(sr, where: { $0.id == sr.id })
                }
                .catch { e in
                    self.displayError = ReadableError(error: e, title: "Error")
                    print(e)
                    return Just(self.scanResults)
                }
                .receive(on: DispatchQueue.main)
                .assign(to: &$scanResults)
            
            centralManager.stateChannel
                .map { StartScreen.State(cbState: $0) }
                .assign(to: &$state)
        }
        
        func deviceViewModel(with scanData: ScanResult) -> DeviceDetailsScreen.ViewModel {
            if let vm = deviceViewModels[scanData.peripheral.identifier] {
                return vm
            }
            else {
                let vm = DeviceDetailsScreen.ViewModel(
                    deviceId: scanData.peripheral.identifier.uuidString
                )
                deviceViewModels[scanData.peripheral.identifier] = vm
                return vm
            }
        }
    }
}
