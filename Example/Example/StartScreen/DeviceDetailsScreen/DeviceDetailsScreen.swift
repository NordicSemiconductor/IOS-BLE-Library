//
//  DeviceDetailsScreen.swift
//  Example
//
//  Created by Nick Kibysh on 29/03/2023.
//

import SwiftUI

struct DeviceDetailsScreen: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        Text(viewModel.name)
    }
}
/*
struct DeviceDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetailsScreen()
    }
}
*/
