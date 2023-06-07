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
   
    @StateObject var viewModel = ViewModel()
    @State var showServicePopover = false
    
    var body: some View {
        List {
            Section {
                Toggle("All Devices", isOn: $viewModel.allDevices )
            }
            
            Section("Custom Filters") {
                Toggle("Named", isOn: $viewModel.named )
                Toggle("Connectable", isOn: $viewModel.connectable )
            }
            .disabled(viewModel.allDevices)
            
            Section("Services") {
                ForEach(viewModel.services, id: \.uuidString) {
                    Text($0.name)
                }
            }
        }
        .navigationTitle("Filter")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Add Service") {
                    showServicePopover = true
                }
                .popover(isPresented: $showServicePopover) {
                    ServiceListSelector(alreadySelectedServices: viewModel.services) { service in
                        self.showServicePopover = false
                        self.viewModel.services.append(service)
                    }
                }
            }
        }
    }
}

struct FilterScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterScreen()
        }
        
    }
}
