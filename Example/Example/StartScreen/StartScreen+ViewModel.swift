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
        @Published var displayResults: [DisplayResult] = []
        @Published var displayError: ReadableError? = nil {
            didSet {
                showError = displayError != nil
            }
        }
        
        @Published var showError: Bool = false
        @Published var connetedDevices: [UUID] = []
        
        private var cancelable = Set<AnyCancellable>()
        
        private var deviceViewModels: [UUID: DeviceDetailsScreen.ViewModel] = [:]
        
        private let centralManager: CentralManager
        
        init() {
            centralManager = CentralManager()
            
            $scanResults
                .map { $0.map { DisplayResult(scanResult: $0) } }
                .assign(to: &$displayResults)
        }
        
        func stopScan() {
            centralManager.stopScan()
        }
        
        func toggleScan() {
            if isScanning {
                stopScan()
            } else {
                startScan()
            }
        }
        
        func connect(uuid: UUID) {
            guard let sr = scanResults.first(where: { $0.id == uuid }) else { fatalError() }
            
            centralManager
                .connect(sr.peripheral)
                .autoconnect()
                .print()
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let e):
                        self.displayError = ReadableError(error: e, title: "Failed To Connect")
                    }
                } receiveValue: { p in
                    self.connetedDevices.append(p.identifier)
                }
                .store(in: &cancelable)

        }
        
        func startScan() {
            // IS SCANNING
            centralManager.isScanningChannel
                .assign(to: &$isScanning)
            
            // SCAN RESULTS
            centralManager.scanForPeripherals(withServices: [])
                .filter { $0.name != nil }
                .scan([ScanResult]()) { arr, sr in
                    arr.appendedOrReplaced(sr, where: { $0.id == sr.id })
                }
                .catch ({ e in
                    self.displayError = ReadableError(error: e, title: "Error")
                    print(e)
                    return Just(self.scanResults)
                })
                .receive(on: DispatchQueue.main)
                .assign(to: &$scanResults)
            
            // STATE
            centralManager.stateChannel
                .map { StartScreen.State(cbState: $0) }
                .assign(to: &$state)
        }
        
        func deviceViewModel(with scanData: DisplayResult) -> DeviceDetailsScreen.ViewModel {
            guard let scanData = scanResults.first(where: { $0.id == scanData.id }) else {
                fatalError()
            }
            
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
