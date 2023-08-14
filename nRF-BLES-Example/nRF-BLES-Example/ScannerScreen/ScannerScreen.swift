//
//  StartScreen.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_Common_Libraries
import CoreBluetooth

struct ScannerScreen: View {
    @StateObject private var viewModel = ViewModel()
    @EnvironmentObject var bluetoothManager: BluetoothManager
    
    @State private var selectedDevice: DisplayResult?
    @State private var showFilterScreen = false

    var body: some View {
        VStack {
            if PhysicalDevice.current == .phone {
                _2columnNavigation
            } else {
                _3columnNavigation
            }
        }
    }
   
    @ViewBuilder
    var _3columnNavigation: some View {
        NavigationSplitView {
           FilterScreen()
        } content: {
            devicesBlock
        } detail: {
            if let vm = viewModel.deviceViewModel(with: selectedDevice) {
                DeviceDetailsScreen(viewModel: vm)
            } else {
                NotSelectedDevice()
            }
        }
        .onAppear {
            viewModel.centralManager = bluetoothManager.centralManager
        }
    }
    
    @ViewBuilder
    var _2columnNavigation: some View {
        NavigationSplitView {
            devicesBlock
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showFilterScreen = true
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                        .sheet(isPresented: $showFilterScreen) {
                            NavigationStack {
                                FilterScreen()
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Close") {
                                                showFilterScreen = false
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    #else
                    EmptyView()
                    #endif
                }
        } detail: {
            if let vm = viewModel.deviceViewModel(with: selectedDevice) {
                DeviceDetailsScreen(viewModel: vm)
            } else {
                NotSelectedDevice()
            }
        }
        .onAppear {
            viewModel.centralManager = bluetoothManager.centralManager
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
        .navigationTitle("Device List")
    }
    
    @ViewBuilder
    var deviceList: some View {
        List(selection: $selectedDevice) {
            Section {
                ForEach(viewModel.displayResults) { sr in
                    NavigationLink(value: sr) {
                        ScannerScreen.ScanResultView(scanResult: sr)
                    }
                    /*
                    NavigationLink {
                        DeviceDetailsScreen(viewModel: viewModel.deviceViewModel(with: sr))
                    } label: {
                        StartScreen.ScanResultView(scanResult: sr)
                    }
                     */

                }
            } header: {
                Text("Scan Results")
            }
        }
    }
    
}

//struct ScannerScreen_Previews: PreviewProvider {
//
//    static var previews: some View {
//        NavigationStack {
//            if #available(iOS 14.0, *) {
//                ScannerScreen()
//                    .navigationTitle("Scanner")
//            } else {
//                EmptyView()
//            }
//        }
//    }
//}
