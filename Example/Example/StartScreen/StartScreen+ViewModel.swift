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

extension StartScreen {
    class ViewModel: ObservableObject {
        @Published var state: StartScreen.State = .unknown
        @Published var isScanning: Bool = false
        @Published var scanResults: [Bluetooth.ScanData] = []
        
        let bluetooth: Bluetooth
        
        private var cancelable = Set<AnyCancellable>()
        
        private var deviceViewModels: [UUID: DeviceDetailsScreen.ViewModel] = [:]
        
        init(bluetooth: Bluetooth = Bluetooth()) {
            self.bluetooth = bluetooth
            
            bluetooth.turnOnBluetoothRadio()
                .map { StartScreen.State(cbState: $0) }
                .sink(to: \.state, in: self, assigningInCaseOfError: .unknown)
                .store(in: &cancelable)
            
            bluetooth.$isScanning
                .sink(to: \.isScanning, in: self, assigningInCaseOfError: false)
                .store(in: &cancelable)
            
        }
        
        func startScan() {
            bluetooth.scan()
                .scan([Bluetooth.ScanData](), { acc, new in
                    acc.appendedOrReplaced(new, where: { $0.peripheral.identifier == new.peripheral.identifier })
                })
                .sink(to: \.scanResults, in: self, assigningInCaseOfError: [])
                .store(in: &cancelable)
        }
        
        func deviceViewModel(with scanData: Bluetooth.ScanData) -> DeviceDetailsScreen.ViewModel {
            if let vm = deviceViewModels[scanData.peripheral.identifier] {
                return vm
            } else {
                let vm = DeviceDetailsScreen.ViewModel(scanData: scanData)
                deviceViewModels[scanData.peripheral.identifier] = vm
                return vm
            }
        }
    }
}
