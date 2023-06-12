//
//  RSSIView.swift
//  Example
//
//  Created by Nick Kibysh on 02/05/2023.
//

import SwiftUI
import iOS_BLE_Library



struct RSSIView: View {
    let rssi: RSSI
    
    var body: some View {
        VStack {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .foregroundColor(rssi.signal.color)
            Text("\(rssi.value) dBm")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct RSSIView_Previews: PreviewProvider {
    static let rssi: [RSSI] = [.good, .ok, .bad, .practicalWorst, .outOfRange]
    
    static var previews: some View {
        List {
            Section {
                ForEach(rssi, id: \.self) {
                    RSSIView(rssi: $0)
                }
            }
        }
    }
}
