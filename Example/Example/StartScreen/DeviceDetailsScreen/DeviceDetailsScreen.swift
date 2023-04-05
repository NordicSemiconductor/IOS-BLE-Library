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
                AdvertisementDataView(advertisementData: viewModel.advertisementData)
            }
            .padding()
            Text("\(viewModel.discoveredServices.count)")
            Text(viewModel.serviceName)
//            List {
//                ForEach(viewModel.discoveredServices) { service in
//                    Text(service.name)
//                    ForEach(service.characteristics) { characteristic in
//                        Text(characteristic.name)
//                    }
//                }
//            }
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

//
//struct DeviceDetailsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDetailsScreen(
//            viewModel:
//        )
//    }
//}
//
