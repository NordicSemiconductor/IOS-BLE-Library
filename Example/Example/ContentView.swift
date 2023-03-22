//
//  ContentView.swift
//  Example
//
//  Created by Nick Kibysh on 09/01/2023.
//

import SwiftUI
import iOS_BLE_Library

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button("Start Scan") {
                
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
