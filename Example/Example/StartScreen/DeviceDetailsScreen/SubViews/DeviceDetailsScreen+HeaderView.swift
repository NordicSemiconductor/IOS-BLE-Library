//
//  DeviceDetailsScreen+HeaderView.swift
//  Example
//
//  Created by Nick Kibysh on 02/05/2023.
//

import SwiftUI
import iOS_BLE_Library

extension DeviceDetailsScreen {
    struct HeaderView: View {
        let name: String
        let rssi: RSSI
        let connectable: Bool
        let connected: Bool
        
        var body: some View {
            HStack() {
                RSSIView(rssi: rssi)
                    .frame(width: 60)
                Text(name)
                    .font(.headline)
                Spacer()
                if connectable {
                    if connected {
                        Image(systemName: "link.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "link.circle")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct DeviceDetailsScreen_HeaderView_Previews: PreviewProvider {
    typealias HeaderView = DeviceDetailsScreen.HeaderView
    
    static var previews: some View {
        Form {
            Section("Devices") {
                HeaderView(name: "Device 1", rssi: .good, connectable: true, connected: true)
                HeaderView(name: "Device 2", rssi: .ok, connectable: false, connected: false)
                HeaderView(name: "Device 3", rssi: .bad, connectable: true, connected: false)
                HeaderView(name: "Device 4", rssi: .practicalWorst, connectable: false, connected: false)
                HeaderView(name: "Device 5", rssi: .outOfRange, connectable: false, connected: false)
            }
        }
    }
}
