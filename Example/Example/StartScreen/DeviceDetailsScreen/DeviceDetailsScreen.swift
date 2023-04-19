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
        VStack {
            VStack {
                ItemListView(itemList: viewModel.advertisementData.readableFormat)
            }
            .padding()
            List {
                ForEach(viewModel.discoveredServices) { service in
                    NestedItemView(item: service)
                    ForEach(service.characteristics) { characteristic in
                        NestedItemView(item: characteristic)
                    }
                }
            }
            Button("Connect") {
                Task {
                    await viewModel.connect()
                }
            }
            .disabled(!viewModel.isConnectable)
            Spacer()
        }
    }
}

struct DeviceDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetailsScreen(viewModel: DeviceDetailsScreen.PreviewViewModel(deviceId: UUID().uuidString))
    }
}

