//
//  AdvertisementDataView.swift
//  Example
//
//  Created by Nick Kibysh on 02/05/2023.
//

import SwiftUI
import iOS_BLE_Library

extension DeviceDetailsScreen {
    struct AdvertisementDataView: View {
        let data: [(String, String)]
        
        init(data: [(String, String)]) {
            self.data = data
        }
        
        init(advData: AdvertisementData) {
            self.data = advData.readableFormat.map { ($0.title, $0.value) }
        }
        
        var body: some View {
            ForEach(data, id: \.0) {
                ItemView(itemModel: ItemModel(key: $0.0, title: $0.0, value: $0.1))
            }
        }
    }
}

struct AdvertisementDataView_Previews: PreviewProvider {
    typealias AdvertisementDataView = DeviceDetailsScreen.AdvertisementDataView
    
    static var reflectedAdvData: [(String, String)] {
        AdvertisementData.mock.readableFormat
            .map {
                ($0.title, $0.value)
            }
    }
    
    static var previews: some View {
        Form {
            AdvertisementDataView(data: reflectedAdvData)
        }
    }
}
