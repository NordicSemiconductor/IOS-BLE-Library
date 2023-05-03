//
//  AdvDataView.swift
//  Example
//
//  Created by Nick Kibysh on 30/03/2023.
//

import SwiftUI
import iOS_BLE_Library

struct ItemListView<K: Hashable>: View {
    let itemList: [ItemModel<K>]
    
    var body: some View {
        Group {
            ForEach(itemList) { item in
                ItemView(title: item.title, value: item.value)
            }
        }
    }
}


struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemListView(itemList: AdvertisementData.mock.readableFormat)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
