//
//  CustomServiceView.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 05/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database

struct CustomServiceView: View {
    @State var name: String = ""
    @State var uuidString: String = ""
    @State var showAlert: Bool = false
    
    let selectionHandler: (Service) -> ()
    
    var body: some View {
        VStack {
            Form {
                TextField("Name", text: $name)
                TextField("UUID String", text: $uuidString)
            }
        }
        .navigationTitle("Custom Service")
        .toolbar {
            ToolbarItem {
                Button("Add") {
                    if UUID(uuidString: uuidString) != nil {
                        let service = Service(
                            name: name,
                            identifier: name+uuidString,
                            uuidString: uuidString,
                            source: name+uuidString
                        )
                        
                        self.selectionHandler(service)
                    } else {
                        showAlert = true
                    }
                }
                .alert("Wrong UUID", isPresented: $showAlert) {
                    Button("Cancel") { }
                }
            }
        }
    }
}

struct CustomServiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomServiceView { _ in }
        }
            
    }
}
