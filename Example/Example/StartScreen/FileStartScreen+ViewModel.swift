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
        
        init(bluetooth: Bluetooth = Bluetooth()) {
            self.bluetooth = bluetooth
            
            bluetooth.$isScanning
                .sink(to: \.isScanning, in: self, assigningInCaseOfError: false)
                .store(in: &cancelable)
        }
        
        func startScan() {
            bluetooth.scan()
                .scan([Bluetooth.ScanData](), { acc, new in
                    acc + [new]
                })
                .sink(to: \.scanResults, in: self, assigningInCaseOfError: [])
                .store(in: &cancelable)
        }
    }
}
