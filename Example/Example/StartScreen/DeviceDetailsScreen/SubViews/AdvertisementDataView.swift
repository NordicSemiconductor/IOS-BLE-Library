//
//  AdvDataView.swift
//  Example
//
//  Created by Nick Kibysh on 30/03/2023.
//

import SwiftUI
import iOS_BLE_Library

struct AdvertisementDataView: View {
    let advertisementData: AdvertisementData
    
    var body: some View {
        Group {
            ForEach(advertisementData.readableFormat) { item in
                ItemView(title: item.title, value: item.value)
            }
        }
    }
}


struct AdvDataView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AdvertisementDataView(
                advertisementData: .fullMock
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
