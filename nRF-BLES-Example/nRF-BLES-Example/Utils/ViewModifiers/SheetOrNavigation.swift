//
//  SheetOrNavigation.swift
//  nRF-BLES-Example
//
//  Created by Nick Kibysh on 09/06/2023.
//

import SwiftUI

struct PushPresent<T: View>: ViewModifier {
    let presented: Bool
    @Binding var isPresented: Bool
    
    let destination: () -> (T)
    
    func body(content: Content) -> some View {
        if presented {
            content.navigationDestination(isPresented: $isPresented, destination: destination)
        } else {
            content.sheet(isPresented: $isPresented) {
                NavigationView {
                    self.destination()
                }
            }
        }
    }
}

extension View {
    func pushPresent<Content: View>(presented: Bool, isPresented: Binding<Bool>, destination: @escaping () -> (Content)) -> some View {
        modifier(PushPresent(presented: presented, isPresented: isPresented, destination: destination))
    }
}
