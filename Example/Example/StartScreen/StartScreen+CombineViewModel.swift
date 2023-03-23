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
    class CombineViewModel: ViewModel {
        private var cancelable = Set<AnyCancellable>()
        private let bluetoothState: AnyPublisher<CBManagerState, Never>
        
        override init(bluetooth: Bluetooth = Bluetooth()) {
            self.bluetoothState = bluetooth.turnOnBluetoothRadio()
            super.init(bluetooth: bluetooth)
            
            bluetoothState
                .map { StartScreen.State(cbState: $0) }
                .sink(to: \.state, in: self, assigningInCaseOfError: .unknown)
                .store(in: &cancelable)
        }
        
        override func startScan() {
            
        }
    }
}

extension StartScreen.CombineViewModel {
    
}
