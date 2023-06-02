//
//  FilterScreen.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 01/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database

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
            
            Section {
                ForEach(viewModel.services, id: \.data) {
                    Service.find(by: $0).flatMap { Text($0.name) } ?? Text($0.uuidString)
                }
            } header: {
                HStack {
                    Text("Services")
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
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
                    NavigationView {
                        ServiceListView()
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
