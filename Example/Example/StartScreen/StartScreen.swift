//
//  StartScreen.swift
//  Example
//
//  Created by Nick Kibysh on 20/01/2023.
//

import SwiftUI
import iOS_Common_Libraries

struct StartScreen: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            Button("Start Scan") {
                Task {
                    viewModel.startScan()
                }
            }
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}
