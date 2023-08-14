//
//  FilterScreen.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 01/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database

extension Service: Identifiable {
    public var id: String {
        uuidString
    }
}

struct FilterScreen: View {
    @Environment(\.isPresented) private var isPresented
    @StateObject var viewModel = ViewModel()
    @State var showServicePopover = false
    
    var body: some View {
        VStack {
            List {
                Section {
                    Toggle("All Devices", isOn: $viewModel.allDevices )
                }
                
                Section("Custom Filters") {
                    Toggle("Named only", isOn: $viewModel.named )
                    Toggle("Connectable only", isOn: $viewModel.connectable)
                }
                .disabled(viewModel.allDevices)
                
                Section("Services") {
                    ForEach(viewModel.services, id: \.uuidString) {
                        Text($0.name)
                    }
                    Button("Add Service") {
                        showServicePopover = true
                    }
                    .buttonStyle(.bordered)
                    .pushPresent(presented: isPresented, isPresented: $showServicePopover) {
                        ServiceListSelector(alreadySelectedServices: viewModel.services) { service in
                            self.showServicePopover = false
                            self.viewModel.services.append(service)
                        }
                    }
                }
                .disabled(viewModel.allDevices)
                
            }
        }
        .navigationTitle("Filter")
    }
}

struct FilterScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterScreen()
        }
        
    }
}
