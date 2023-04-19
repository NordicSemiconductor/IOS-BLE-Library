//
//  NestedItemView.swift
//  Example
//
//  Created by Nick Kibysh on 05/04/2023.
//

import SwiftUI

struct NestedItemView<Content: View>: View {
    let level: UInt
    let content: () -> Content
    
    init(level: UInt, content: @escaping () -> Content) {
        self.level = level
        self.content = content
    }
    
    init<T: NestedStringRepresentable>(item: T) where Content == Text {
        self.level = item.level
        self.content = {
            Text(String(describing: item))
        }
    }
    
    var body: some View {
        HStack {
            ForEach(0..<level, id: \.self) { lv in
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 6)
                    .foregroundColor(.accentColor.opacity(1 - Double(lv) * 0.3))
            }
            Spacer()
            content()
        }
    }
}

struct NestedItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NestedItemView(level: 1) {
                Text("Service")
            }
            NestedItemView(level: 2) {
                Text("Characteristic")
            }
            NestedItemView(level: 3) {
                Text("Characteristic 2")
            }
            NestedItemView(level: 3) {
                Text("Some Text")
            }
            NestedItemView(level: 3) {
                Text("Some Text")
            }
            NestedItemView(level: 2) {
                Text("Some Text")
            }
        }
//        .frame(height: 40)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
