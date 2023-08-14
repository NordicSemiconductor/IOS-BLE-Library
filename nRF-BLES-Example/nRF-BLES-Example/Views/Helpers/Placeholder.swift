//
//  Placeholder.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 12/06/2023.
//

import SwiftUI

struct Placeholder<Content: View>: View {
    let systemImage: String
    let title: String
    let message: String?
    
    let action: () -> (Content)
    
    init(systemImage: String, title: String, message: String? = nil, action: @escaping () -> Content) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.action = action
    }
    
    init(systemImage: String, title: String, message: String? = nil) where Content == EmptyView {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.action = {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 300, maxHeight: 300)
                .foregroundColor(.secondary)
            Text(title)
                .foregroundColor(.secondary)
                .font(.title)
            if let message {
                Text(message)
                    .foregroundColor(.secondary)
            }
            
            action()
        }
    }
    
}

struct Placeholder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Placeholder(systemImage: "person", title: "No User", message: "No User Found") {
                Button("Retry") {}
                    .buttonStyle(.borderedProminent)
                    .frame(minWidth: 200)
            }
            
            Placeholder(systemImage: "arrow.up.and.down.and.arrow.left.and.right", title: "Icon")
        }
    }
}
