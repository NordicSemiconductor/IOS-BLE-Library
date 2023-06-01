//
//  ScanResult.swift
//  Example
//
//  Created by Nick Kibysh on 23/03/2023.
//

import SwiftUI
import iOS_BLE_Library
import CoreBluetooth

extension ScannerScreen {
    struct ScanResultView: View {
        let scanResult: ScannerScreen.DisplayResult
        
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
    static let displayResults: [ScannerScreen.DisplayResult] = [
        ScannerScreen.DisplayResult(name: "EdgeImpulse", connectable: true, id: UUID()),
        ScannerScreen.DisplayResult(name: "Weather Station", connectable: false, id: UUID()),
        ScannerScreen.DisplayResult(name: "Blinky", connectable: true, id: UUID())
    ]
    
    static var previews: some View {
        List {
            ForEach(displayResults) {
                ScannerScreen.ScanResultView(scanResult: $0)
            }
        }
    }
}
