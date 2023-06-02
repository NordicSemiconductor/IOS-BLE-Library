//
//  FilterScreen+ViewModel.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 02/06/2023.
//

import SwiftUI

extension FilterScreen {
    class ViewModel: ObservableObject {
        @Published var allDevices: Bool = true
        @Published var named: Bool = false
        @Published var connectable: Bool = false
        
        @Published var services: [CBUUID] = []
 
    }
}
