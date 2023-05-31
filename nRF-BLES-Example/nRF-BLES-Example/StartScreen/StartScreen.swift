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
    enum Filter: String, CaseIterable {
        case connectable, named
    }
    
    @State private var path: [Filter] = []
    @State private var selectedFilter: Filter?
    @State private var selectedDevice: DisplayResult?

    var body: some View {
        NavigationSplitView {
            List(Filter.allCases, id: \.rawValue, selection: $selectedFilter) {
                NavigationLink($0.rawValue.capitalized, value: $0)
            }
        } content: {
            devicesBlock
        } detail: {
            if let vm = viewModel.deviceViewModel(with: selectedDevice) {
                DeviceDetailsScreen(viewModel: vm)
            } else {
                NotSelectedDevice()
            }
        }

        /*
        VStack {
            bluetoothState
            devicesBlock
        }
        .navigationTitle(Text("Scaner"))
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
         */
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
                    NavigationLink(sr.name, value: sr)
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

struct StartScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            if #available(iOS 14.0, *) {
                StartScreen()
                    .navigationTitle("Scanner")
            } else {
                EmptyView()
            }
        }
    }
}
