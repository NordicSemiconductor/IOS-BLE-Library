//
//  ItemView.swift
//  Example
//
//  Created by Nick Kibysh on 04/04/2023.
//

import SwiftUI

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

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ItemView(
                image: Image(systemName: "phone"),
                title: "Title",
                value: "Value"
            )
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
}
