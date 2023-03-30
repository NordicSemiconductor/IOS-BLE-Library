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
            ForEach(advertisementData.readableFormat, id: \.title) { item in
                ItemView(title: item.title, value: item.value)
            }
        }
    }
}

struct ItemView: View {
    let icon: Image?
    let title: String
    let value: String
    
    init(image: String, title: String, value: String) {
        self.init(image: Image(image), title: title, value: value)
    }
    
    init(systemImage: String, title: String, value: String) {
        self.init(image: Image(systemName: systemImage), title: title, value: value)
    }
    
    init(image: Image? = nil, title: String, value: String) {
        self.icon = image
        self.value = value
        self.title = title
    }
    
    var body: some View {
        HStack {
            self.icon
            Text(self.title)
            Spacer()
            Text(self.value).foregroundColor(.secondary)
        }
    }
}


//struct AdvDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        AdvDataView()
//    }
//}
