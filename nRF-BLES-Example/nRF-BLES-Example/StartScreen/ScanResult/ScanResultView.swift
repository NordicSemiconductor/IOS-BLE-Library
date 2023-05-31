//
//  ScanResult.swift
//  Example
//
//  Created by Nick Kibysh on 23/03/2023.
//

import SwiftUI
import iOS_BLE_Library
import CoreBluetooth

extension StartScreen {
    struct ScanResultView: View {
        let scanResult: StartScreen.DisplayResult
        
        var body: some View {
            HStack {
                Text(scanResult.name)
                Spacer()
                Circle()
                    .fill(scanResult.connectable ? .green : .red)
                    .frame(size: CGSize(width: 10, height: 10))
            }
            .padding()
        }
    }
}

struct StartScreen_ScanResultView_Previews: PreviewProvider {
    static let displayResults: [StartScreen.DisplayResult] = [
        StartScreen.DisplayResult(name: "EdgeImpulse", connectable: true, id: UUID()),
        StartScreen.DisplayResult(name: "Weather Station", connectable: false, id: UUID()),
        StartScreen.DisplayResult(name: "Blinky", connectable: true, id: UUID())
    ]
    
    static var previews: some View {
        List {
            ForEach(displayResults) {
                StartScreen.ScanResultView(scanResult: $0)
            }
        }
    }
}
