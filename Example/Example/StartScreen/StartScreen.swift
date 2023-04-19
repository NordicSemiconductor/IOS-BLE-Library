//
//  StartScreen.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_Common_Libraries
import CoreBluetoothMock

struct StartScreen: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            bluetoothState
            devicesBlock
            Spacer()
        }
        .navigationBarTitle("Scaner")
    }
    
    @ViewBuilder
    var bluetoothState: some View {
        HStack {
            Text("Bluetooth State:")
            Spacer()
            Text(viewModel.state.rawValue)
                .foregroundColor(.green)
        }
        .padding()
    }
    
    @ViewBuilder
    var devicesBlock: some View {
        VStack {
            Spacer()
            if !viewModel.isScanning {
                Button("Start Scan") {
                    viewModel.startScan()
                }
            } else {
                if viewModel.scanResults.isEmpty {
                    Text("Scanning...").font(.title)
                        .foregroundColor(.secondary)
                } else {
                    deviceList
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var deviceList: some View {
        List {
            Section {
                ForEach(viewModel.scanResults, id: \.peripheral.identifier) { sr in
                    NavigationLink {
                        DeviceDetailsScreen(
                            viewModel: viewModel.deviceViewModel(with: sr)
                        )
                    } label: {
                        ScanResultView(scanResult: sr)
                    }
                }
            } header: {
                Text("Scan Results")
            }
        }
    }
    
}

struct StartScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                StartScreen()
                    .navigationTitle("Scanner")
            } else {
                EmptyView()
            }
        }
    }
}
