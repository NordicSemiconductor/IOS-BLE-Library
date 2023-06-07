//
//  ServicePopover.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 02/06/2023.
//

import SwiftUI
import iOS_Bluetooth_Numbers_Database

extension FilterScreen {
    struct ServicePopover: View {
        @State var text: String = ""
        
        var handler: (Service) -> ()
        
        var body: some View {
            VStack {
                Form {
                    Section {
                        TextField("Service UUID", text: $text)
                    } footer: {
                        Text("Add Service UUID.")
                    }
                }
            }
            .navigationTitle("Add Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
    }
}

struct ServicePopover_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FilterScreen.ServicePopover { _ in
                
            }
        }
    }
}
