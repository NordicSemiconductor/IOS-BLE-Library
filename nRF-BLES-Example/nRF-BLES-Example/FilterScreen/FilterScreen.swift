//
//  FilterScreen.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 01/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database

struct FilterScreen: View {
    @State var allDevices: Bool = true
    @State var named: Bool = false
    @State var connectable: Bool = false
    
    @State var services: [CBUUID] = []
    
    var body: some View {
        List {
            Section {
                Toggle("All Devices", isOn: $allDevices )
            }
            
            Section("Custom Filters") {
                Toggle("Named", isOn: $named )
                Toggle("Connectable", isOn: $connectable )
            }
            .disabled(allDevices)
            
            Section {
                ForEach(services, id: \.data) {
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
    }
}

struct FilterScreen_Previews: PreviewProvider {
    static var previews: some View {
        FilterScreen()
    }
}
