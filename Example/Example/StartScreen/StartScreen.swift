//
//  StartScreen.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_Common_Libraries

struct StartScreen: View {
    @StateObject var viewModel = CombineViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                bluetoothState
                Divider()
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    var bluetoothState: some View {
        HStack {
            Text("Bluetooth State:")
            Spacer()
            Text(viewModel.state.rawValue)
                .foregroundColor(.green)
        }
        .padding()
    }
    
    
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}
