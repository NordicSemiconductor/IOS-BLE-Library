//
//  ViewModel.swift
//  Example
//
//  Created by Nick Kibysh on 09/01/2023.
//

import Foundation
import iOS_BLE_Library

extension ContentView {
    class ViewModel: ObservableObject {
        let bluetooth = Bluetooth()
        
        func turnOn() async {
            await bluetooth.turnOnBluetoothRadio()
        }
    }
}
