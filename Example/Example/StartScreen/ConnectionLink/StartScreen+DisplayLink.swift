//
//  StartScreen+DisplayLink.swift
//  Example
//
//  Created by Nick Kibysh on 26/04/2023.
//

import SwiftUI

extension StartScreen {
    struct DisplayLink: View {
        let displayData: DisplayResult
        
        var body: some View {
            NavigationLink {
                Text("")
            } label: {
                StartScreen.ScanResultView(scanResult: displayData)
            }

        }
    }
}

struct StartScreen_DisplayLink_Previews: PreviewProvider {
    static let displayResults: [StartScreen.DisplayResult] = [
        StartScreen.DisplayResult(name: "EdgeImpulse", connectable: true, id: UUID()),
        StartScreen.DisplayResult(name: "Weather Station", connectable: false, id: UUID()),
        StartScreen.DisplayResult(name: "Blinky", connectable: true, id: UUID())
    ]
    
    static var previews: some View {
        List {
            ForEach(displayResults) {
                StartScreen.DisplayLink(displayData: $0)
            }
        }
    }
}
