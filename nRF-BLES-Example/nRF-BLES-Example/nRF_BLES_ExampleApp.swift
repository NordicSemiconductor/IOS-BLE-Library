//
//  nRF_BLES_ExampleApp.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 31/05/2023.
//

import SwiftUI

@main
struct nRF_BLES_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartSplitView()
                    .environmentObject(BluetoothManager())
            }
        }
    }
}
