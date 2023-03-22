//
//  StartScreen+ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_BLE_Library
import Combine

extension StartScreen {
    class ViewModel: ObservableObject {
        
        @Published var state: StartScreen.State = .unknown
        
        let bluetooth = Bluetooth()
        
        private var cancelable = Set<AnyCancellable>()
        
        func startScan() {
            bluetooth
                .turnOnBluetoothRadio()
                .map { StartScreen.State(cbState: $0) }
                .assign(to: &$state)
        }
    }
}

extension StartScreen.ViewModel {
    
}
