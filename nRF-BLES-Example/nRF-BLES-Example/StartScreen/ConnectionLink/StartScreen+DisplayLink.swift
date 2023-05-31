//
//  StartScreen+DisplayLink.swift
//  Example
//
//  Created by Nick Kibysh on 26/04/2023.
//

import SwiftUI

extension StartScreen {
    struct DisplayLink<Content: View>: View {
        let displayData: DisplayResult
        let content: () -> Content
        
        var body: some View {
            NavigationLink(destination: content()) {
                StartScreen.ScanResultView(scanResult: displayData)
            }
        }
    }
}

struct StartScreen_DisplayLink_Previews: PreviewProvider {
    typealias DisplayLink = StartScreen.DisplayLink
    typealias DisplayResult = StartScreen.DisplayResult
    
    static let displayResults: [DisplayResult] = [
        DisplayResult(name: "EdgeImpulse", connectable: true, id: UUID()),
        DisplayResult(name: "Weather Station", connectable: false, id: UUID()),
        DisplayResult(name: "Blinky", connectable: true, id: UUID())
    ]
    
    static var previews: some View {
        List {
            ForEach(displayResults) {
                DisplayLink(displayData: $0, content: { Text("") })
            }
        }
    }
}