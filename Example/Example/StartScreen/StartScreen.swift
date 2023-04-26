//
//  StartScreen.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_Common_Libraries
import CoreBluetooth

struct StartScreen: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            bluetoothState
            devicesBlock
        }
        .navigationBarTitle("Scaner")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    viewModel.toggleScan()
                } label: {
                    if viewModel.isScanning {
                        Image(systemName: "stop.fill")
                    } else {
                        Image(systemName: "play.fill")
                    }
                }

            }
        }
        .alert(
            viewModel.displayError?.title ?? viewModel.displayError?.message ?? "Error",
            isPresented: $viewModel.showError) {
                Button("OK") { }
            }
    }
    
    @ViewBuilder
    var bluetoothState: some View {
        HStack {
            Text("State:")
            Spacer()
            Text(viewModel.state.rawValue)
                .foregroundColor(.green)
            if viewModel.isScanning {
                Image(systemName: "scanner.fill")
                    .foregroundColor(.nordicBlue)
            } else {
                Image(systemName: "scanner")
                    .foregroundColor(.nordicMiddleGrey)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var devicesBlock: some View {
        VStack {
            Spacer()
            if !viewModel.isScanning && viewModel.scanResults.isEmpty {
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
                ForEach(viewModel.displayResults) { sr in
//                    DisplayLink(displayData: sr)
                    Button {
                        viewModel.connect(uuid: sr.id)
                    } label: {
                        if viewModel.connetedDevices.contains(sr.id) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                ScanResultView(scanResult: sr)
                            }
                        } else {
                            ScanResultView(scanResult: sr)
                        }
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
