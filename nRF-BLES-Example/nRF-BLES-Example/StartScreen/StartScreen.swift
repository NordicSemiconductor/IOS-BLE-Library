//
//  StartScreen.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 01/06/2023.
//

import SwiftUI
import iOS_BLE_Library

struct StartScreen: View {
    @EnvironmentObject var centralmanager: BluetoothManager
    @State var didRequestScan: Bool = false
    
    var body: some View {
        VStack {
            switch centralmanager.stace {
            case .unknown, .poweredOn, .resetting:
                if didRequestScan {
                    ScannerScreen()
                } else {
                    startScanPlaceholder
                        .padding()
                }
            case .poweredOff:
                EmptyView()
            case .unauthorized:
                EmptyView()
            case .unsupported:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    var startScanPlaceholder: some View {
        VStack {
            imageView(systemImage: "scanner", message: "Scan for nearby devices")
            Button("Start Scan") {
                didRequestScan = true
                centralmanager.startScan(services: nil)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    @ViewBuilder
    func imageView(systemImage: String, message: String) -> some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .foregroundColor(.secondary)
            Text(message)
                .foregroundColor(.secondary)
                .font(.headline)
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
            .environmentObject(BluetoothManager())
    }
}
